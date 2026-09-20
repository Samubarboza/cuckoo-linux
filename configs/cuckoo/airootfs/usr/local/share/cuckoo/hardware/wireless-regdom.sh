#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Set the wireless region from the timezone of the system.
# Without it, Wi-Fi can be slow or miss some networks.

set -e -u

regdom_file="/etc/conf.d/wireless-regdom"
zone_table="/usr/share/zoneinfo/zone.tab"

[[ -f "${regdom_file}" && -f "${zone_table}" && -L /etc/localtime ]] || exit 0

# The region is already set, keep it
if grep -q '^WIRELESS_REGDOM=' "${regdom_file}"; then
    exit 0
fi

timezone="$(readlink -f /etc/localtime)"
timezone="${timezone#/usr/share/zoneinfo/}"
country_code="$(awk -v timezone="${timezone}" '$3 == timezone { print $1; exit }' "${zone_table}")"

if [[ ! "${country_code}" =~ ^[A-Z]{2}$ ]]; then
    printf 'The country of the timezone is unknown, the wireless region is not set.\n'
    exit 0
fi

printf 'WIRELESS_REGDOM="%s"\n' "${country_code}" >>"${regdom_file}"
printf 'Wireless region set to %s.\n' "${country_code}"
