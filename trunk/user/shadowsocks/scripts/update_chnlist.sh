#!/bin/sh

set -b -e -o pipefail
ulimit -t 60

[ "$1" != "force" ] && [ "$(nvram get ss_update_chnlist)" != "1" ] && exit 0
CHNLIST_URL="$(nvram get chnlist_url)"

logger -st "SSP[$$]Update" "开始更新白名单..."
rm -rf /tmp/chnlist_domain.txt
curl -k -s --connect-timeout 5 --retry 3 "$CHNLIST_URL" | \
grep -v '^#' | grep -v '^$' | grep -v '^ipset=\/' | \
grep -v '^include:' | grep -v '^keyword:' | grep -v ':@ads$' | grep -v ':@!cn$' | \
sed 's/^domain://g' | sed 's/^full://g' | sed 's/:@.*$//g' | sed 's/@.*$//g' | sed 's/[[:space:]]//g' | \
sed '/^regexp:/ s/$/:/' | sed 's/^regexp:/:/g' | \
sed 's/^server=\///g' | sed 's/\/.*$//g' | sed 's/^\.//g' | \
grep '\.' | sort -u > /tmp/chnlist_domain.txt || \
curl -k -s --connect-timeout 5 --retry 3 \
"https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf" | \
awk -F/ '{print $2}' | sort -u > /tmp/chnlist_domain.txt

[ ! -d /etc/storage/chnlist/ ] && mkdir /etc/storage/chnlist/
[ -s /tmp/chnlist_domain.txt ] && mv -f /tmp/chnlist_domain.txt /etc/storage/chnlist/chnlist_domain.txt && \
mtd_storage.sh save >/dev/null 2>&1

[ "$(nvram get ss_enable)" == "1" ] && /usr/bin/shadowsocks.sh rednsconf &>/dev/null

logger -st "SSP[$$]Update" "白名单更新完成"

