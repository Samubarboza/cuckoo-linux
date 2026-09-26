# Arch Linux container to build the Cuckoo ISO and test it in QEMU
# Nothing is installed on the host system
# Build it from the repository root:
#   docker build -t cuckoo-builder .
FROM archlinux:latest

# First line builds the iso, second line builds our GRUB, third line compiles the login
# screen and eww, fourth line tests the iso in QEMU with Secure Boot
RUN pacman -Syu --noconfirm --needed \
        arch-install-scripts libisoburn squashfs-tools erofs-utils dosfstools e2fsprogs mtools sbsigntools openssl \
        base-devel python \
        rust gtk4 gtk3 gtk-layer-shell libdbusmenu-gtk3 \
        qemu-system-x86 qemu-ui-gtk edk2-ovmf virt-firmware \
    && pacman -Scc --noconfirm

# GRUB with the Cuckoo patch, built by the project script
# The menu font comes from the Arch grub package, which is only downloaded, not installed
COPY scripts/build_grub.sh /opt/cuckoo/scripts/
COPY configs/cuckoo/secureboot/grub-always-use-shim.patch /opt/cuckoo/configs/cuckoo/secureboot/
RUN pacman -Syw --noconfirm grub \
    && install -d /usr/share/grub \
    && bsdtar -xOf /var/cache/pacman/pkg/grub-*.pkg.tar.zst usr/share/grub/unicode.pf2 >/usr/share/grub/unicode.pf2 \
    && /opt/cuckoo/scripts/build_grub.sh \
    && pacman -Scc --noconfirm
ENV PATH="/opt/cuckoo/grub-build/bin:${PATH}"

# namcap checks the PKGBUILD files
RUN pacman -Syu --noconfirm --needed namcap && pacman -Scc --noconfirm

WORKDIR /build
