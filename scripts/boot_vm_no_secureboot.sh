#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Boot the installed Cuckoo system in QEMU, without Secure Boot for now.

set -euo pipefail

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
disk_file="${project_dir}/vm/disco.img"
uefi_vars="${project_dir}/vm/OVMF_VARS_sin_secureboot.fd"

for required_file in "${disk_file}" "${uefi_vars}"; do
  if [[ ! -f ${required_file} ]]; then
    printf 'ERROR: %s was not found.\n' "${required_file}" >&2
    exit 1
  fi
done

docker run --rm --device /dev/kvm \
  --env XDG_RUNTIME_DIR=/tmp/xdg \
  --env WAYLAND_DISPLAY="${WAYLAND_DISPLAY}" \
  --env GDK_BACKEND=wayland \
  --volume "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}:/tmp/xdg/${WAYLAND_DISPLAY}" \
  --volume "${project_dir}/vm:/vm" \
  cuckoo-builder \
  qemu-system-x86_64 -enable-kvm -cpu host -m 4G -machine q35 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \
    -drive if=pflash,format=raw,file=/vm/OVMF_VARS_sin_secureboot.fd \
    -drive if=virtio,format=raw,file=/vm/disco.img \
    -display gtk
