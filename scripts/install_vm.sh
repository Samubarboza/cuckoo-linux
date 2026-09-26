#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Boot the ISO in QEMU with Secure Boot to install Cuckoo on the virtual disk.

set -euo pipefail

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
iso_files=("${project_dir}"/out/cuckoo-*.iso)
uefi_vars="${project_dir}/vm/OVMF_VARS.fd"

if [[ ! -f ${iso_files[0]} ]]; then
  printf 'ERROR: no ISO found in %s/out. Run scripts/build_iso.sh first.\n' "${project_dir}" >&2
  exit 1
fi

if [[ ! -f ${uefi_vars} ]]; then
  printf 'ERROR: %s was not found.\n' "${uefi_vars}" >&2
  exit 1
fi

iso_name="$(basename -- "${iso_files[0]}")"

docker run --rm --device /dev/kvm \
  --env XDG_RUNTIME_DIR=/tmp/xdg \
  --env WAYLAND_DISPLAY="${WAYLAND_DISPLAY}" \
  --env GDK_BACKEND=wayland \
  --volume "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}:/tmp/xdg/${WAYLAND_DISPLAY}" \
  --volume "${project_dir}/vm:/vm" \
  --volume "${project_dir}/out:/out:ro" \
  cuckoo-builder \
  qemu-system-x86_64 -enable-kvm -cpu host -m 4G \
  -machine q35,smm=on -global driver=cfi.pflash01,property=secure,value=on \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.secboot.4m.fd \
  -drive if=pflash,format=raw,file=/vm/OVMF_VARS.fd \
  -drive "if=none,id=pendrive,format=raw,readonly=on,file=/out/${iso_name}" \
  -device qemu-xhci -device usb-storage,drive=pendrive,bootindex=0 \
  -drive if=none,id=disco,format=raw,file=/vm/disco.img \
  -device virtio-blk-pci,drive=disco,bootindex=1 \
  -display gtk
