============
Cuckoo Linux
============

Cuckoo Linux is a Linux distribution based on Arch Linux.

**This project is in development.** It is not ready for daily use. Things can change or break.

Goal
====

- Boot and install on any computer, with Secure Boot on.
- No need to turn off Secure Boot.
- A simple and friendly installer.

What works now
==============

- The live ISO boots with Secure Boot on or off.
- It also boots on old computers with BIOS.

How Secure Boot works
=====================

1. The computer starts ``shim``. Microsoft signed it, so almost all computers trust it.
2. ``shim`` starts GRUB. GRUB is signed with the Cuckoo key.
3. GRUB starts the Linux kernel. The kernel is also signed with the Cuckoo key.

The first time, the computer does not know the Cuckoo key:

1. You see ``Verification failed``. This is normal. Press OK.
2. A blue screen opens.
3. Choose ``Enroll key from disk``, then ``MOK.cer``, ``Continue``, ``Yes`` and ``Reboot``.

You do this only one time on each computer.

Some new computers do not trust ``shim``. On them, turn on "Allow Microsoft 3rd Party UEFI CA" in the firmware settings.

Build the ISO
=============

You need Arch Linux and these packages: ``arch-install-scripts``, ``libisoburn``, ``squashfs-tools``, ``dosfstools``,
``mtools``, ``sbsigntools``, ``openssl``, ``base-devel`` and ``python``.

1. Make your own key. Keep ``MOK.key`` secret, never share it.

   .. code:: sh

      openssl req -new -x509 -newkey rsa:2048 -nodes -keyout MOK.key -out MOK.crt -days 3650 \
          -subj "/CN=My Secure Boot Key/" -addext "extendedKeyUsage=codeSigning"
      openssl x509 -in MOK.crt -outform DER -out configs/cuckoo/secureboot/MOK.cer

2. Build our GRUB. You do this only one time. It goes to the ``grub-build`` folder.

   .. code:: sh

      ./scripts/build_grub.sh

3. Build the ISO. ``-S`` is the folder with ``MOK.key`` and ``MOK.crt``.

   .. code:: sh

      sudo env PATH="$PWD/grub-build/bin:$PATH" ./archiso/mkarchiso -v -S /path/to/key/folder -w work -o out configs/cuckoo

The ISO is in the ``out`` folder.

Credits and license
===================

Cuckoo Linux is a modified copy of `archiso <https://gitlab.archlinux.org/archlinux/archiso>`_.
We added Secure Boot support and the ``cuckoo`` profile.

- ``shimx64.efi`` and ``mmx64.efi`` come from the Fedora 44 package ``shim-x64`` (version 16.1-5), without changes.
  ``shim`` uses a BSD license.
- The GRUB patch uses the same license as GRUB: GPL-3.0-or-later.
- Everything else uses GPL-3.0-or-later, like archiso. See ``LICENSE``.

Cuckoo Linux is not an official Arch Linux or Fedora project.
