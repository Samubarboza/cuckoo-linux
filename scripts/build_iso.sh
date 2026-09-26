#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Build the Cuckoo packages and the ISO inside the builder container.
# The ISO is saved in the out folder of the builder directory.

set -euo pipefail

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
builder_dir="${CUCKOO_BUILDER_DIR:-${HOME}/Desktop/cuckoo-builder}"
keys_dir="${CUCKOO_KEYS_DIR:-${HOME}/cuckoo-keys}"

printf 'Building the packages...\n'
docker run --rm \
  --volume "${project_dir}:/project" \
  cuckoo-builder /project/scripts/build_packages.sh

printf 'Cleaning the previous build...\n'
docker run --rm \
  --volume "${builder_dir}:/build" \
  cuckoo-builder rm -rf /build/work
rm -f -- "${builder_dir}"/out/*.iso

printf 'Building the ISO...\n'
docker run --rm --privileged \
  --env owner="$(id -u):$(id -g)" \
  --volume "${project_dir}:/project:ro" \
  --volume "${keys_dir}:/keys:ro" \
  --volume "${builder_dir}:/build" \
  --volume /etc/pacman.d/mirrorlist:/etc/pacman.d/mirrorlist:ro \
  cuckoo-builder \
  bash -c '/project/archiso/mkarchiso -v -r -S /keys -w /build/work -o /build/out /project/configs/cuckoo && chown -R "${owner}" /build/out'
