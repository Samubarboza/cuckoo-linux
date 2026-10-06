#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# After Claude Code edits a shell script, check it like the commit hook does.

set -euo pipefail

edited_file="$(jq -r '.tool_input.file_path // empty')"
relative_path="${edited_file#"${CLAUDE_PROJECT_DIR}"/}"
cd "${CLAUDE_PROJECT_DIR}"

# Only the scripts that the commit hook checks, so the archiso files stay out
if [[ -z "${relative_path}" ]] || ! shfmt -f . | grep -xF -- "${relative_path}" >/dev/null; then
  exit 0
fi

check_output="$(
  shfmt -d -- "${relative_path}" 2>&1 || true
  shellcheck --format=gcc -- "${relative_path}" 2>&1 || true
)"

if [[ -n "${check_output}" ]]; then
  printf 'Fix these problems in %s:\n%s\n' "${relative_path}" "${check_output}" >&2
  exit 2
fi
