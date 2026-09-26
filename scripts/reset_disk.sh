#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Empty the virtual disk so the next install starts from zero.

set -euo pipefail

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
disk_file="${project_dir}/vm/disco.img"
disk_size="10G"

mkdir -p -- "${project_dir}/vm"
truncate --size 0 -- "${disk_file}"
truncate --size "${disk_size}" -- "${disk_file}"

printf 'The virtual disk is empty: %s\n' "${disk_file}"
