#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Boot the installed Cuckoo system in QEMU with Secure Boot.

set -euo pipefail

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
disk_file="${project_dir}/vm/disco.img"
uefi_vars="${project_dir}/vm/OVMF_VARS.fd"

for required_file in "${disk_file}" "${uefi_vars}"; do
  if [[ ! -f ${required_file} ]]; then
    printf 'ERROR: %s was not found.\n' "${required_file}" >&2
    exit 1
  fi
done

# A TPM 2.0 chip for the virtual machine. It keeps its data in vm/tpm, like a real chip.
tpm_start=()
tpm_options=()
if [[ "${1:-}" != '--no-tpm' ]]; then
  install -d -m 0700 -- "${project_dir}/vm/tpm"
  tpm_start=(bash -c 'swtpm socket --tpm2 --tpmstate dir=/vm/tpm --ctrl type=unixio,path=/tmp/swtpm.sock --daemon && exec "$@"' _)
  tpm_options=(-chardev 'socket,id=tpm,path=/tmp/swtpm.sock' -tpmdev 'emulator,id=tpm0,chardev=tpm' -device 'tpm-tis,tpmdev=tpm0')
fi

docker run --rm -it --device /dev/kvm \
  --env XDG_RUNTIME_DIR=/tmp/xdg \
  --env WAYLAND_DISPLAY="${WAYLAND_DISPLAY}" \
  --env GDK_BACKEND=wayland \
  --volume "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}:/tmp/xdg/${WAYLAND_DISPLAY}" \
  --volume "${project_dir}/vm:/vm" \
  cuckoo-builder \
  "${tpm_start[@]}" qemu-system-x86_64 -enable-kvm -cpu host -m 4G \
  -machine q35,smm=on -global driver=cfi.pflash01,property=secure,value=on \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.secboot.4m.fd \
  -drive if=pflash,format=raw,file=/vm/OVMF_VARS.fd \
  -drive if=virtio,format=raw,file=/vm/disco.img \
  "${tpm_options[@]}" \
  -display gtk \
  -monitor stdio
