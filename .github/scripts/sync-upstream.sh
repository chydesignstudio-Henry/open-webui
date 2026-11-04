#!/usr/bin/env bash
# 把 fork 的預設分支與上游預設分支合併。
# 只使用 merge-upstream。不要加 --force，也不要改 git ref。
set -euo pipefail

repo="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"

if [[ -z "${SYNC_TOKEN:-}" ]]; then
  echo "::error::沒有可用的 token。"
  exit 1
fi

meta="$(gh api "repos/${repo}")"
is_fork="$(jq -r '.fork' <<<"${meta}")"
parent="$(jq -r '.parent.full_name // empty' <<<"${meta}")"
fork_branch="$(jq -r '.default_branch' <<<"${meta}")"
upstream_branch="$(jq -r '.parent.default_branch // empty' <<<"${meta}")"

if [[ "${is_fork}" != "true" || -z "${parent}" || -z "${fork_branch}" ]]; then
  echo "::error::${repo} 不是 fork，或 API 沒有 parent／default branch，無法同步。"
  exit 1
fi

echo "Fork: ${repo} @ ${fork_branch}"
echo "Upstream: ${parent} @ ${upstream_branch}"
echo "merge-upstream 會把上游預設分支併入 fork 的 ${fork_branch}。不使用 --force。"

tmp="$(mktemp)"
trap 'rm -f "${tmp}" "${tmp}.err"' EXIT

set +e
GH_TOKEN="${SYNC_TOKEN}" gh api \
  --method POST \
  --include \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "repos/${repo}/merge-upstream" \
  -f "branch=${fork_branch}" >"${tmp}" 2>"${tmp}.err"
set -e

http_status="$(awk 'NR==1 { print $2; exit }' "${tmp}")"
body="$(awk 'BEGIN { p = 0 } { sub(/\r$/, "") } p { print } $0 == "" { p = 1 }' "${tmp}")"
message="$(printf '%s' "${body}" | jq -r '.message // empty' 2>/dev/null || true)"
merge_type="$(printf '%s' "${body}" | jq -r '.merge_type // empty' 2>/dev/null || true)"
err_text="$(cat "${tmp}.err" 2>/dev/null || true)"

echo "merge-upstream HTTP ${http_status:-unknown}"
if [[ -n "${merge_type}" ]]; then
  echo "merge_type: ${merge_type}"
fi
if [[ -n "${message}" ]]; then
  echo "message: ${message}"
fi
if [[ -n "${err_text}" ]]; then
  printf '%s\n' "${err_text}"
fi

run_url="${GITHUB_SERVER_URL:-https://github.com}/${repo}/actions/runs/${GITHUB_RUN_ID:-0}"

ensure_label() {
  gh label create "upstream-sync" \
    --repo "${repo}" \
    --color "B60205" \
    --description "上游自動同步失敗，需要人工處理" \
    >/dev/null 2>&1 || true
}

close_sync_issues() {
  ensure_label
  local numbers number
  numbers="$(gh issue list --repo "${repo}" --state open --label "upstream-sync" --limit 50 --json number --jq '.[].number')"
  if [[ -z "${numbers}" ]]; then
    return 0
  fi
  while IFS= read -r number; do
    [[ -z "${number}" ]] && continue
    gh issue close "${number}" --repo "${repo}" --reason completed --comment "$(cat <<EOF
上游已成功合併到 \`${fork_branch}\`（merge_type: \`${merge_type:-unknown}\`）。這次沒有強制推送，fork 自己的檔案仍在。

執行紀錄：${run_url}
EOF
)"
  done <<<"${numbers}"
}

open_or_update_issue() {
  local title="$1"
  local kind="$2"
  local detail="${message}"
  if [[ -z "${detail}" ]]; then
    detail="$(printf '%s\n' "${err_text}" | head -n 1)"
  fi
  if [[ -z "${detail}" ]]; then
    detail="（API 沒有訊息）"
  fi
  detail="${detail//$'\n'/ }"
  detail="${detail//$'\r'/ }"

  ensure_label
  local body existing number
  body="$(cat <<EOF
自動同步上游失敗。**沒有**強制推送，也沒有捨棄這個 fork 自己新增或修改的檔案；\`${fork_branch}\` 維持失敗前的內容。

| 項目 | 值 |
| --- | --- |
| Fork | \`${repo}\` |
| Fork 預設分支 | \`${fork_branch}\` |
| 上游 | \`${parent}\` |
| 上游預設分支 | \`${upstream_branch:-unknown}\` |
| 結果 | ${kind} |
| HTTP | \`${http_status:-unknown}\` |
| API 訊息 | ${detail} |

請在本機把上游 \`${parent}\` 的 \`${upstream_branch:-預設分支}\` 合併進 \`${fork_branch}\`，解決衝突後推上 merge commit。不要使用 \`git push --force\` 或 \`gh repo sync --force\`。

若錯誤是 workflow 權限（\`GITHUB_TOKEN\` 不能建立或更新 \`.github/workflows\` 底下的檔案），請在這個儲存庫新增 Actions secret \`UPSTREAM_SYNC_TOKEN\`：

- classic PAT：\`repo\` 與 \`workflow\`
- fine-grained PAT：只限這個儲存庫，Contents 與 Workflows 皆為讀寫

工作流程會優先使用 \`UPSTREAM_SYNC_TOKEN\`，沒有設定時才用 \`GITHUB_TOKEN\`。

執行紀錄：${run_url}
EOF
)"

  existing="$(gh issue list --repo "${repo}" --state open --label "upstream-sync" --limit 50 --json number,title)"
  number="$(printf '%s' "${existing}" | jq -r --arg t "${title}" '[.[] | select(.title == $t) | .number] | first // empty')"
  if [[ -n "${number}" ]]; then
    gh issue comment "${number}" --repo "${repo}" --body "${body}"
    echo "已在既有 issue #${number} 留言。"
  else
    gh issue create --repo "${repo}" --title "${title}" --label "upstream-sync" --body "${body}"
    echo "已開啟新 issue：${title}"
  fi
}

if [[ "${http_status}" == "200" ]]; then
  echo "同步完成（${merge_type:-unknown}）：${message}"
  if ! close_sync_issues; then
    echo "::warning::同步已成功，但無法關閉舊的 upstream-sync issue。"
  fi
  exit 0
fi

kind="其他錯誤"
title="上游同步失敗：${parent} → ${repo}:${fork_branch}"
combined="${message}"$'\n'"${err_text}"
if [[ "${http_status}" == "409" ]] || grep -qi 'merge conflict' <<<"${combined}"; then
  kind="合併衝突"
  title="上游同步衝突：${repo}:${fork_branch} 無法併入 ${parent}"
elif grep -Eqi 'workflow' <<<"${combined}" && grep -Eqi 'scope|permission' <<<"${combined}"; then
  kind="workflow 權限不足"
  title="上游同步失敗：權杖無法更新 workflow 檔（${parent}）"
fi

echo "::error::${kind}（HTTP ${http_status:-unknown}）。沒有覆寫 ${fork_branch}。"
if ! open_or_update_issue "${title}" "${kind}"; then
  echo "::warning::同步失敗，且無法建立或更新 issue。請看上面的 Actions 紀錄。"
fi
exit 1
