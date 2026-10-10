.. code:: text

     ██████╗██╗   ██╗ ██████╗██╗  ██╗ ██████╗  ██████╗
    ██╔════╝██║   ██║██╔════╝██║ ██╔╝██╔═══██╗██╔═══██╗
    ██║     ██║   ██║██║     █████╔╝ ██║   ██║██║   ██║
    ██║     ██║   ██║██║     ██╔═██╗ ██║   ██║██║   ██║
    ╚██████╗╚██████╔╝╚██████╗██║  ██╗╚██████╔╝╚██████╔╝
     ╚═════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝

============
Cuckoo Linux
============

Cuckoo Linux is a Linux system based on Arch Linux.

- An install ISO that works with Secure Boot on any computer.
- Its own installer, in the terminal.
- A desktop that is ready from the first boot.

**This project is in development.**

Packages
========

Our packages:

- ``cuckoo-desktop`` — the desktop
- ``cuckoo-greeter`` — the login screen

Programs:

- **Base:** linux, linux-firmware, grub, efibootmgr, btrfs-progs, zram-generator, networkmanager, pipewire, bluez, power-profiles-daemon, sudo, git, nano, python
- **Desktop:** hyprland, quickshell, swaybg, alacritty, greetd, plymouth, swaync, hyprlock, hypridle, papirus-icon-theme
- **Editor:** zed
- **Terminal:** starship, atuin, zsh, tmux, curl, openssh, htop, ripgrep, fzf
- **Containers:** docker, docker-compose
- **Kubernetes:** kubectl, k9s, helm
- **Network:** bind, iproute2, openbsd-netcat, mtr, nmap, tcpdump
- **Build:** base-devel
- **Package managers:** pacman, yay

The installer also adds the video drivers for your computer.

Run and test
============

You need Docker, KVM and a Wayland session.

1. Make your own key. Do this one time. Keep ``MOK.key`` secret.

   .. code:: sh

      mkdir -p ~/cuckoo-keys
      openssl req -new -x509 -newkey rsa:2048 -nodes -keyout ~/cuckoo-keys/MOK.key \
          -out ~/cuckoo-keys/MOK.crt -days 3650 \
          -subj "/CN=My Secure Boot Key/" -addext "extendedKeyUsage=codeSigning"
      openssl x509 -in ~/cuckoo-keys/MOK.crt -outform DER -out configs/cuckoo/secureboot/MOK.cer

2. Build the builder image. Do this again only when the ``Dockerfile`` or the GRUB patch changes.

   .. code:: sh

      ./scripts/build_image.sh

3. Build the packages and the ISO. The ISO goes to ``out/``.

   .. code:: sh

      ./scripts/build_iso.sh

4. Empty the virtual disk.

   .. code:: sh

      ./scripts/reset_disk.sh

5. Start the ISO with Secure Boot and install on the virtual disk.

   .. code:: sh

      ./scripts/install_vm.sh

6. Start the installed system. Secure Boot is off for now, because the installed system is not signed yet.

   .. code:: sh

      ./scripts/boot_vm_no_secureboot.sh

The scripts need two files in ``vm/``: ``OVMF_VARS.fd`` and ``OVMF_VARS_sin_secureboot.fd``.

Check the code
==============

You need ``shfmt`` 3.13.1, ``shellcheck`` 0.11.0 and ``gitleaks`` 8.30.1.

.. code:: sh

   git config core.hooksPath .githooks
   shfmt -f . | xargs shellcheck
   ./scripts/check_packages.sh

The first line turns on the checks before every commit. Do it one time after cloning.

License
=======

Cuckoo Linux is a modified copy of `archiso <https://gitlab.archlinux.org/archlinux/archiso>`_.
It uses GPL-3.0-or-later. See ``LICENSE``.
``shimx64.efi`` and ``mmx64.efi`` come from Fedora, without changes. They use a BSD license.
The power menu icons come from `Lucide <https://lucide.dev>`_ (ISC license) and `Feather <https://feathericons.com>`_ (MIT license).

Cuckoo Linux is not an official Arch Linux or Fedora project.
