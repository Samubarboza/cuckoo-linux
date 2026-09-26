#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Build the container image used to build and test Cuckoo.
# Run it again only when the Dockerfile or the GRUB patch changes.

set -euo pipefail

project_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"

docker build --tag cuckoo-builder "${project_dir}"
