#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Stop Claude Code from running any command that touches the signing keys.

set -euo pipefail

if ! command_to_run="$(jq -r '.tool_input.command // empty')"; then
  printf 'Blocked: the command could not be read.\n' >&2
  exit 2
fi

if [[ "${command_to_run}" == *cuckoo-keys* || "${command_to_run}" == *MOK.key* ]]; then
  printf 'Blocked: the signing keys are private. Never read or copy them.\n' >&2
  exit 2
fi
