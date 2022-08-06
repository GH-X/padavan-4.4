#!/bin/sh

set -e -o pipefail

[ "$1" != "force" ] && [ "$(nvram get ss_update_gfwlist)" != "1" ] && exit 0
GFWLIST_URL="$(nvram get gfwlist_url)"

logger -st "SSP[$$]Update" "开始更新黑名单..."

rm -f /tmp/gfwlist_domain.txt
curl -k -s --connect-timeout 5 --retry 3 \
${GFWLIST_URL:-"https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt"} | \
base64 -d | \
sed -n '{
s/^||\?//g;
s/https\?:\/\///g;
s/^\.//g;
s/\*.*//g;
s/\/.*//g;
s/%.*//g;
/^!.*/d;
/^@.*/d;
/^\[.*/d;
/\.$/d;
/^[^\.]*$/d;
/^[0-9\.]*$/d;
/^$/d;
/^#.*/d;
p
}' | sort -u >> /tmp/gfwlist_domain.txt

[ ! -d /etc/storage/gfwlist/ ] && mkdir /etc/storage/gfwlist/
mv -f /tmp/gfwlist_domain.txt /etc/storage/gfwlist/gfwlist_domain.txt

mtd_storage.sh save >/dev/null 2>&1

[ "$(nvram get ss_enable)" = "1" ] && /usr/bin/shadowsocks.sh rednsconf &>/dev/null

logger -st "SSP[$$]Update" "黑名单更新完成"
