#!/bin/sh

set -e -o pipefail

[ "$1" != "force" ] && [ "$(nvram get ss_update_chnroute)" != "1" ] && exit 0
CHNROUTE_URL="$(nvram get chnroute_url)"
APNIC_URL="http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"
user_agent="Mozilla/5.0 (X11; Linux; rv:74.0) Gecko/20100101 Firefox/74.0"

logger -st "SSP[$$]Update" "开始更新路由表..."

(rm -f /tmp/chnroute.txt
if [ -z "$CHNROUTE_URL" ]; then
	curl -k -s -A "$user_agent" --connect-timeout 5 --retry 3 "$APNIC_URL" | sed '/\*/d' | \
	awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /tmp/chnroute.txt
else
	curl -k -s --connect-timeout 5 --retry 3 -o /tmp/chnroute.txt "$CHNROUTE_URL" && \
	sed -i '/^#/d' /tmp/chnroute.txt && sed -i '/^$/d' /tmp/chnroute.txt
fi
[ ! -d /etc/storage/chinadns/ ] && mkdir /etc/storage/chinadns/
if [ $(cat /tmp/chnroute.txt | wc -l) -le 65536 ]; then
	mv -f /tmp/chnroute.txt /etc/storage/chinadns/chnroute.txt
	mtd_storage.sh save >/dev/null 2>&1
else
	rm -f /etc/storage/chinadns/chnroute.txt && \
	ln -sf /tmp/chnroute.txt /etc/storage/chinadns/chnroute.txt
fi)&

wait

[ "$(nvram get ss_enable)" = "1" ] && echo "daten_stopwatchcat" > /tmp/SSP/sspstatus.tmp && \
/usr/bin/shadowsocks.sh restart &>/dev/null

logger -st "SSP[$$]Update" "路由表更新完成"
