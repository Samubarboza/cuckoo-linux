#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Build the cuckoo-desktop package and leave it inside the cuckoo profile.

set -e -u

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
desktop_dir="${project_dir}/desktop"
output_dir="${project_dir}/configs/cuckoo/airootfs/usr/local/share/cuckoo/packages"
build_user="nobody"

temporary_dir="$(mktemp -d)"
trap 'rm -rf -- "${temporary_dir}"' EXIT

for required_command in makepkg fakeroot; do
    if ! command -v "${required_command}" &>/dev/null; then
        printf "ERROR: '%s' was not found. Install 'base-devel'.\n" "${required_command}" >&2
        exit 1
    fi
done

if [[ ! -f "${desktop_dir}/PKGBUILD" ]]; then
    printf "ERROR: '%s/PKGBUILD' was not found.\n" "${desktop_dir}" >&2
    exit 1
fi

printf 'Building the cuckoo-desktop package...\n'
cp -r -- "${desktop_dir}/." "${temporary_dir}/"

# makepkg refuses to run as root, so a plain user does it in a copy of the folder
if (( EUID == 0 )); then
    chown -R "${build_user}:" -- "${temporary_dir}"
    setpriv --reuid "${build_user}" --regid "${build_user}" --clear-groups \
        env HOME="${temporary_dir}" PATH="${PATH}" \
        bash -c "cd '${temporary_dir}' && makepkg --clean"
else
    (cd "${temporary_dir}" && makepkg --clean)
fi

rm -rf -- "${output_dir}"
install -d -m 0755 -- "${output_dir}"
install -m 0644 -- "${temporary_dir}"/*.pkg.tar.zst "${output_dir}/"

printf 'Done! The package is in %s\n' "${output_dir}"
