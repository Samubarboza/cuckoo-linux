#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Build the Cuckoo packages and the ISO inside the builder container.
# The ISO is saved in the out folder of the repository.

set -euo pipefail

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
keys_dir="${CUCKOO_KEYS_DIR:-${HOME}/cuckoo-keys}"

printf 'Building the packages...\n'
docker run --rm \
  --volume "${project_dir}:/project" \
  cuckoo-builder /project/scripts/build_packages.sh

printf 'Cleaning the previous build...\n'
docker run --rm \
  --volume "${project_dir}:/project" \
  cuckoo-builder rm -rf /project/work
rm -f -- "${project_dir}"/out/*.iso
mkdir -p -- "${project_dir}/out" "${project_dir}/work"

printf 'Building the ISO...\n'
docker run --rm --privileged \
  --env owner="$(id -u):$(id -g)" \
  --volume "${project_dir}:/project:ro" \
  --volume "${project_dir}/work:/project/work" \
  --volume "${project_dir}/out:/project/out" \
  --volume "${keys_dir}:/keys:ro" \
  --volume /etc/pacman.d/mirrorlist:/etc/pacman.d/mirrorlist:ro \
  cuckoo-builder \
  bash -c '/project/archiso/mkarchiso -v -r -S /keys -w /project/work -o /project/out /project/configs/cuckoo && chown -R "${owner}" /project/out'
