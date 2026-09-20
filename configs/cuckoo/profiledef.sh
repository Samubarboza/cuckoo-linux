#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="cuckoo"
iso_label="CUCKOO_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Cuckoo Linux <https://github.com/Samubarboza/cuckoo-linux>"
iso_application="Cuckoo Linux Live/Rescue DVD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="cuckoo"
bootmodes=('bios.syslinux'
           'uefi.shim-grub')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86,arm64' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/cuckoo-configurator"]="0:0:755"
  ["/usr/local/bin/cuckoo-hardware"]="0:0:755"
  ["/usr/local/share/cuckoo/hardware/"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)
