#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Build GRUB 2.14 with the Cuckoo patch into the grub-build folder of the project.
# Nothing is installed on the system.

set -e -u

grub_version="2.14"
grub_download_url="https://ftp.gnu.org/gnu/grub/grub-${grub_version}.tar.xz"
grub_download_sha256="bc8d3c73535b8838d8c8e2654d73edc4e6ae8c8acdb45d5df5dc9a1547446d43"

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
grub_patch_file="${project_dir}/configs/cuckoo/secureboot/grub-always-use-shim.patch"
grub_build_dir="${project_dir}/grub-build"
system_grub_font="/usr/share/grub/unicode.pf2"

temporary_dir="$(mktemp -d)"
trap 'rm -rf -- "${temporary_dir}"' EXIT

for required_command in curl sha256sum tar patch make gcc bison flex python3; do
    if ! command -v "${required_command}" &>/dev/null; then
        printf "ERROR: '%s' was not found. Install 'base-devel' and 'python'.\n" "${required_command}" >&2
        exit 1
    fi
done

printf 'Downloading GRUB %s...\n' "${grub_version}"
curl -fL -o "${temporary_dir}/grub.tar.xz" "${grub_download_url}"
if ! printf '%s  %s\n' "${grub_download_sha256}" "${temporary_dir}/grub.tar.xz" | sha256sum -c --quiet; then
    printf 'ERROR: the GRUB download is not the expected file.\n' >&2
    exit 1
fi

printf 'Building GRUB with the Cuckoo patch...\n'
tar -xf "${temporary_dir}/grub.tar.xz" -C "${temporary_dir}"
cd "${temporary_dir}/grub-${grub_version}"
patch -p1 <"${grub_patch_file}"
./configure --quiet --prefix="${grub_build_dir}" --with-platform=efi --target=x86_64 --disable-werror
make --quiet -j"$(nproc)"
rm -rf -- "${grub_build_dir}"
make --quiet install >/dev/null

# The menu font is not built here, so take it from the Arch grub package when it exists
if [[ -f "${system_grub_font}" ]]; then
    install -m 0644 -- "${system_grub_font}" "${grub_build_dir}/share/grub/"
else
    printf "WARNING: '%s' was not found. The GRUB menu will use a simple font.\n" "${system_grub_font}" >&2
fi

printf 'Done! GRUB is in %s\n' "${grub_build_dir}"
