#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Build the offline repo that travels inside the ISO, so the install needs no internet.
# For now it only compiles yay. Downloading the packages and making the repo database
# come later.

set -euo pipefail

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
offline_repo_dir="${project_dir}/configs/cuckoo/airootfs/usr/local/share/cuckoo/offline-repo"
yay_aur_url="https://aur.archlinux.org/yay.git"
build_user="nobody"

for required_command in makepkg git go; do
  if ! command -v "${required_command}" &>/dev/null; then
    printf "ERROR: '%s' was not found. Install 'base-devel', 'git' and 'go'.\n" "${required_command}" >&2
    exit 1
  fi
done

rm -rf -- "${offline_repo_dir}"
install -d -m 0755 -- "${offline_repo_dir}"

# makepkg refuses to run as root, so a plain user builds yay in a temporary copy.
# --nodeps because its build tools are already in the builder image.
build_yay() {
  local temporary_dir
  temporary_dir="$(mktemp -d)"
  trap 'rm -rf -- "${temporary_dir}"' RETURN

  git clone --depth 1 -- "${yay_aur_url}" "${temporary_dir}/yay"

  if ((EUID == 0)); then
    chown -R "${build_user}:" -- "${temporary_dir}"
    setpriv --reuid "${build_user}" --regid "${build_user}" --clear-groups \
      env HOME="${temporary_dir}" PATH="${PATH}" \
      bash -c "cd '${temporary_dir}/yay' && makepkg --clean --nodeps"
  else
    (cd "${temporary_dir}/yay" && makepkg --clean --nodeps)
  fi

  install -m 0644 -- "${temporary_dir}"/yay/*.pkg.tar.zst "${offline_repo_dir}/"
}

printf 'Compiling yay...\n'
build_yay

# Inside Docker this runs as root, so hand the repo back to the project owner
if ((EUID == 0)); then
  chown -R --reference="${project_dir}" -- "${offline_repo_dir}"
fi

printf 'Done! yay is in %s\n' "${offline_repo_dir}"
