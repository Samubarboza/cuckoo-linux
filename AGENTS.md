# AGENTS.md

## About

Cuckoo Linux is a system based on Arch Linux. It has three parts:

1. An install ISO that works with Secure Boot on any computer.
2. Its own installer, in the terminal.
3. A desktop that is ready from the first boot.

## Structure

- `archiso/` — tool that builds the ISO
- `configs/cuckoo/` — ISO profile
- `desktop/` — desktop package (Hyprland, Waybar, theme)
- `eww/` — eww package (bar popups)
- `greeter/` — login screen package
- `scripts/` — tools to build and test
- `local/` — work notes, not in the repository
- `out/`, `work/`, `vm/` — build output and virtual machine files, not in the repository

Each folder has one job only.

## Workflow

1. One small task at a time: one branch per task, one PR per branch.
2. Before you create or change files, show the plan and wait for approval.
3. If something is not clear, ask first.
4. Stay inside the task. Write down other problems for later.
5. Every change has a short description: what it does and why.
6. Only the repository owner makes commits and pushes.

## Principles

- Short and solid code.
- One script, one job.
- No overengineering: solve the problem of today.
- Clear names for variables, functions and files.
- The same format in all the repository.

## Bash style

- Shebang: `#!/bin/bash`.
- Scripts that run start with `set -euo pipefail`.
- Two spaces for indentation, no tabs.
- Use `[[ ]]` for text and files; use `(( ))` for numbers.
- Always put paths with spaces inside quotes.
- Every script passes `shellcheck` with no warnings.

## Interface

- Simple, elegant design. Nothing extra.
- The same colors, fonts and spacing in all the desktop.

## Security

- Signing keys live outside the repository (`~/cuckoo-keys`). Never read or copy them.
- Only exception: `configs/cuckoo/secureboot/MOK.cer`, a public certificate.
- Commands that work on disks (`dd`, `mkfs`, `wipefs`) need clear approval first.
- Tests run in QEMU. Never install, format or change the host system.
- Only the repository owner runs `reset_disk.sh` and the virtual machine scripts.

## Tests

1. Run `shellcheck` on every changed script.
2. Boot the ISO in QEMU with Secure Boot before every merge.


Run all commands from the repository root.

- `./scripts/build_image.sh` — build the builder image (only when the `Dockerfile` or the GRUB patch changes)
- `./scripts/build_iso.sh` — build the packages and the ISO into `out/`
- `./scripts/reset_disk.sh` — empty the virtual disk
- `./scripts/install_vm.sh` — boot the ISO with Secure Boot and install on the virtual disk
- `./scripts/boot_vm_no_secureboot.sh` — boot the installed system without Secure Boot
- `shfmt -w .` — format the shell scripts
