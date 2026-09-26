#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Check the PKGBUILD files with namcap inside the builder container.

set -euo pipefail

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"

docker run --rm \
  --volume "${project_dir}:/project:ro" \
  cuckoo-builder bash -c 'namcap /project/*/PKGBUILD'
