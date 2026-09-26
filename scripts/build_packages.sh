#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Build the Cuckoo packages and leave them inside the cuckoo profile.

set -e -u

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
package_dirs=("desktop" "greeter" "eww")
output_dir="${project_dir}/configs/cuckoo/airootfs/usr/local/share/cuckoo/packages"
build_user="nobody"

for required_command in makepkg fakeroot cargo pkg-config; do
  if ! command -v "${required_command}" &>/dev/null; then
    printf "ERROR: '%s' was not found. Install 'base-devel' and 'rust'.\n" "${required_command}" >&2
    exit 1
  fi
done

# The greeter links against gtk4 and eww against gtk3, so these have to be here to compile.
# Each pair is the name pkg-config knows and the Arch package that brings it.
for required_library in gtk4:gtk4 gtk+-3.0:gtk3 gtk-layer-shell-0:gtk-layer-shell dbusmenu-gtk3-0.4:libdbusmenu-gtk3; do
  if ! pkg-config --exists "${required_library%%:*}"; then
    printf "ERROR: %s was not found. Install '%s'.\n" "${required_library%%:*}" "${required_library#*:}" >&2
    exit 1
  fi
done

for package_dir in "${package_dirs[@]}"; do
  if [[ ! -f "${project_dir}/${package_dir}/PKGBUILD" ]]; then
    printf "ERROR: '%s/%s/PKGBUILD' was not found.\n" "${project_dir}" "${package_dir}" >&2
    exit 1
  fi
done

rm -rf -- "${output_dir}"
install -d -m 0755 -- "${output_dir}"

for package_dir in "${package_dirs[@]}"; do
  printf 'Building the %s package...\n' "${package_dir}"

  temporary_dir="$(mktemp -d)"
  trap 'rm -rf -- "${temporary_dir}"' EXIT
  cp -r -- "${project_dir}/${package_dir}/." "${temporary_dir}/"

  # makepkg refuses to run as root, so a plain user does it in a copy of the folder.
  # --nodeps because the packages run on the installed system, not on this one.
  if ((EUID == 0)); then
    chown -R "${build_user}:" -- "${temporary_dir}"
    setpriv --reuid "${build_user}" --regid "${build_user}" --clear-groups \
      env HOME="${temporary_dir}" PATH="${PATH}" \
      bash -c "cd '${temporary_dir}' && makepkg --clean --nodeps"
  else
    (cd "${temporary_dir}" && makepkg --clean --nodeps)
  fi

  install -m 0644 -- "${temporary_dir}"/*.pkg.tar.zst "${output_dir}/"
  rm -rf -- "${temporary_dir}"
done

# Inside Docker this runs as root, so hand the packages back to the project owner
if ((EUID == 0)); then
  chown -R --reference="${project_dir}" -- "${output_dir}"
fi

printf 'Done! The packages are in %s\n' "${output_dir}"
