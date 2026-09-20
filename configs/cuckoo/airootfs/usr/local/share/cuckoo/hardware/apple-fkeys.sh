#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Make F1, F2 and the other F keys work as F keys on Apple style keyboards.

set -e -u

hid_apple_file="/etc/modprobe.d/hid_apple.conf"

# The file is already there, keep it
[[ -f "${hid_apple_file}" ]] && exit 0

install -d -m 0755 -- /etc/modprobe.d
printf 'options hid_apple fnmode=2\n' >"${hid_apple_file}"
printf 'F keys set to work as F keys on Apple style keyboards.\n'
