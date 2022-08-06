#!/bin/sh
# $1-5: crontab expr, eg: a/1 a a a a
# $6: script name
CRON_CONF="/etc/storage/cron/crontabs/$(nvram get http_username)"
[ -z "$6" ] && exit 0
cd /etc/storage/
exp=$(echo "$1 $2 $3 $4 $5" | sed 's/a/\*/g')
if [ ! -e "$CRON_CONF" ] || [ -z "$(cat "$CRON_CONF" | grep "$6")" ]; then
	echo "$exp /usr/bin/$6 2>/dev/null" >> $CRON_CONF && exit 1
fi
exit 0
