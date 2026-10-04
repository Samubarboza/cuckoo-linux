#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Build the offline repo that travels inside the ISO, so the install needs no internet.
# It compiles yay, downloads the package list with its dependencies, and makes the repo
# database that pacman reads.

set -euo pipefail

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
offline_repo_dir="${project_dir}/configs/cuckoo/isofs/offline-repo"
package_list_file="${project_dir}/configs/cuckoo/airootfs/usr/local/share/cuckoo/offline-packages.txt"
repo_database="${offline_repo_dir}/cuckoo-offline.db.tar.gz"
yay_aur_url="https://aur.archlinux.org/yay.git"
build_user="nobody"

for required_command in makepkg git go pacman repo-add; do
  if ! command -v "${required_command}" &>/dev/null; then
    printf "ERROR: '%s' was not found.\n" "${required_command}" >&2
    exit 1
  fi
done

if [[ ! -f "${package_list_file}" ]]; then
  printf "ERROR: '%s' was not found.\n" "${package_list_file}" >&2
  exit 1
fi

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

# Download every package from the list with its dependencies, without installing them.
# A temporary database keeps the download apart from the builder own pacman state.
download_packages() {
  local temporary_db packages
  temporary_db="$(mktemp -d)"
  trap 'rm -rf -- "${temporary_db}"' RETURN

  mapfile -t packages < <(grep -vE '^[[:space:]]*#|^[[:space:]]*$' "${package_list_file}")

  # --disable-sandbox so pacman can write to our own dbpath and cachedir inside
  # the builder. The download is controlled here, not from an untrusted place.
  pacman -Syw --dbpath "${temporary_db}" --cachedir "${offline_repo_dir}" \
    --disable-sandbox --noconfirm -- "${packages[@]}"
}

printf 'Compiling yay...\n'
build_yay

printf 'Downloading the packages...\n'
download_packages

# The repo uses SigLevel Optional TrustAll, so the signatures are never checked.
# Drop them to halve the file count and make the ISO smaller.
rm -f -- "${offline_repo_dir}"/*.pkg.tar.zst.sig

printf 'Making the repo database...\n'
repo-add -- "${repo_database}" "${offline_repo_dir}"/*.pkg.tar.zst

# Inside Docker this runs as root, so hand the repo back to the project owner
if ((EUID == 0)); then
  chown -R --reference="${project_dir}" -- "${offline_repo_dir}"
fi

printf 'Done! The offline repo is in %s\n' "${offline_repo_dir}"
