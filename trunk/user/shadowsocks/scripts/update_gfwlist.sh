#!/bin/sh

set -b -e -o pipefail
ulimit -t 60

[ "$1" != "force" ] && [ "$(nvram get ss_update_gfwlist)" != "1" ] && exit 0
GFWLIST_URL="$(nvram get gfwlist_url)"

logger -st "SSP[$$]Update" "开始更新黑名单..."
rm -rf /tmp/gfwlist_domain.txt
$(curl -k -s --connect-timeout 5 --retry 3 "$GFWLIST_URL" | \
base64 -d 2>/dev/null | \
sed -n -r '{
/^\[/d;
/^!/d;
/^@@/d;
s/^\|https?:\/\///g;
s/^\|\|//g;
s/\/.*$//g;
s/%.*$//g;
s/^[0-9a-zA-Z]{0,128}\*[0-9a-zA-Z]{0,128}\.//g;
s/\*.*$//g;
s/^\.//g;
s/\.$//g;
/([0-9]{1,3}\.){3}[0-9]{1,3}/d;
/.*\..*/!d;
p
}' | sort -u > /tmp/gfwlist_domain.txt || \
curl -k -s --connect-timeout 5 --retry 3 "$GFWLIST_URL" | \
grep -v '^#' | grep -v '^$' | grep -v '^ipset=\/' | \
grep -v '^include:' | grep -v '^keyword:' | grep -v ':@ads$' | grep -v ':@cn$' | \
sed 's/^domain://g' | sed 's/^full://g' | sed 's/:@.*$//g' | sed 's/@.*$//g' | sed 's/[[:space:]]//g' | \
sed '/^regexp:/ s/$/:/' | sed 's/^regexp:/:/g' | \
sed 's/^server=\///g' | sed 's/\/.*$//g' | sed 's/^\.//g' | \
grep '\.' | sort -u > /tmp/gfwlist_domain.txt) || \
curl -k -s --connect-timeout 5 --retry 3 \
"https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt" | \
base64 -d | \
sed -n -r '{
/^\[/d;
/^!/d;
/^@@/d;
s/^\|https?:\/\///g;
s/^\|\|//g;
s/\/.*$//g;
s/%.*$//g;
s/^[0-9a-zA-Z]{0,128}\*[0-9a-zA-Z]{0,128}\.//g;
s/\*.*$//g;
s/^\.//g;
s/\.$//g;
/([0-9]{1,3}\.){3}[0-9]{1,3}/d;
/.*\..*/!d;
p
}' | sort -u > /tmp/gfwlist_domain.txt

[ ! -d /etc/storage/gfwlist/ ] && mkdir /etc/storage/gfwlist/
[ -s /tmp/gfwlist_domain.txt ] && mv -f /tmp/gfwlist_domain.txt /etc/storage/gfwlist/gfwlist_domain.txt && \
mtd_storage.sh save >/dev/null 2>&1

[ "$(nvram get ss_enable)" == "1" ] && /usr/bin/shadowsocks.sh rednsconf &>/dev/null

logger -st "SSP[$$]Update" "黑名单更新完成"

