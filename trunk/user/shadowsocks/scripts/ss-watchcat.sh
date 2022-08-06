#!/bin/sh

CONF_DIR="/tmp/SSP"
statusfile="$CONF_DIR/statusfile"
areconnect="$CONF_DIR/areconnect"
netdpcount="$CONF_DIR/netdpcount"
errorcount="$CONF_DIR/errorcount"
quickstart="$CONF_DIR/quickstart"
ssp_log_file="/tmp/ss-watchcat.log"
redir_log_file="/tmp/ss-redir.log"
max_log_bytes="100000"
gfw_domain="https://www.google.com/"
chn_domain="https://www.taobao.com/"
user_agent="Mozilla/5.0 (X11; Linux; rv:74.0) Gecko/20100101 Firefox/74.0"
CRON_CONF="/etc/storage/cron/crontabs/$(nvram get http_username)"
redirmaxRAM="65536"

autorec=$(nvram get ss_watchcat_autorec)
extbpid=$(expr 100000 + $$)
logmark=${extbpid:1}

infor(){
	issjfinfor=$(tail -n 1 $CONF_DIR/issjfinfor)
	[ -n "$issjfinfor" ] && echo "$issjfinfor" || echo "???──???:???──[???]"
}

loger(){
	sed -i '/'$(date "+%Y-%m-%d_%H:%M:%S")'_'$logmark''$1'/d' $ssp_log_file
	sed -i '1i\'$(date "+%Y-%m-%d_%H:%M:%S")'_'$logmark''$1'' $ssp_log_file
}

count(){
	counts_file="$1"
	[ -e "$counts_file" ] || echo "0" > "$counts_file"
	counts_temp=$(tail -n 1 "$counts_file")
	counts_form=${counts_temp:0}
	if [ "$2" = "+-" ] || [ "$2" = "-+" ]; then
		echo "$3" > "$counts_file"
	elif [ "$2" = "++" ]; then
		form_counts=$(expr $counts_form + $3)
		echo "$form_counts" > "$counts_file"
	elif [ "$2" = "--" ]; then
		form_counts=$(expr $counts_form - $3)
		[ $form_counts -le 0 ] && echo "0" > "$counts_file" || echo "$form_counts" > "$counts_file"
	else
		echo "$counts_form"
	fi
}

godet(){
	rm -rf $statusfile
	if !(iptables-save | grep -q "SSP_RULES") || !(ipset list -n | grep -q 'private') || \
	!(ipset list -n | grep -q 'gfwlist') || !(ipset list -n | grep -q 'chnlist'); then
		count $errorcount ++ 1 && count $areconnect +- 0
	fi
	for sspredirPID in $(pidof ss-redir); do
		sspredirRSS=$(cat /proc/$sspredirPID/status | grep 'VmRSS' | \
		sed 's/[[:space:]]//g' | sed 's/kB//g' | awk -F: '{print $2}')
		[ $sspredirRSS -ge $redirmaxRAM ] && count $errorcount +- 5 && count $areconnect +- 0
	done
	return 0
}

goout(){
	!(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_stop_ssp') && godet
	loger "┌──$(infor)"
	exit 0
}

dndet(){
	$(pidof dnsmasq &>/dev/null) || $(sleep 1 && pidof dnsmasq &>/dev/null) || \
	$(restart_dhcpd && loger "├──解析进程中止!!!启动进程")
	$(pidof ss-redir &>/dev/null) || $(sleep 1 && pidof ss-redir &>/dev/null) || \
	$($quickstart && loger "├──代理进程中止!!!启动进程")
	!(cat "$statusfile" 2>/dev/null | grep -q 'daten_stopwatchcat') || return 1
}

daten(){
	dateS=$(date +%S) && [ $dateS -ge 55 ] && echo "daten_stopwatchcat" > $statusfile
	if [ "$1" = "-l" ]; then
		datel=$(expr $2 - $dateS) && echo "$datel"
	elif [ "$1" = "-m" ]; then
		date_M=$(date +%M) && datem=${date_M:1} && echo "$datem"
	else
		return 0
	fi
}

scout(){
	[ "$3" = "0" ] && keywords='HTTP/1.1 200 OK' && extraoptions='-L -I'
	[ "$3" = "1" ] && keywords='^<!DOCTYPE' && extraoptions='-L'
	curl "$1" $extraoptions -k -s --connect-timeout $2 --max-time $2 --speed-time $2 \
	--speed-limit 1 -A "$user_agent" | grep -q -s -i "$keywords" || return 1
}

watchcat_stop_ssp(){
	!(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_stop_ssp') || return 0
	[ $(count $errorcount) -ge 1 ] || return 0
	STO_LOG="发现异常!!!暂时停止代理" && loger "├──$STO_LOG" && logger -st "SSP[$$]WARNING" "$STO_LOG"
	echo "watchcat_stop_ssp" > $statusfile && /usr/bin/shadowsocks.sh stop &>/dev/null && return 1
}

watchcat_start_ssp(){
	$(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_stop_ssp') || return 0
	count $errorcount -- 1 && [ $(count $errorcount) -le 0 ] || return 1
	scout "$chn_domain" 4 0 || scout "$chn_domain" 4 1 || return 1
	[ "$(nvram get ss_enable)" = "1" ] || /usr/bin/shadowsocks.sh stop &>/dev/null
	!(pidof ss-redir &>/dev/null) || /usr/bin/shadowsocks.sh stop &>/dev/null
	STA_LOG="恢复正常!!!重新启动代理" && loger "├──$STA_LOG" && logger -st "SSP[$$]watchcat" "$STA_LOG"
	count $netdpcount +- 0 && count $errorcount +- 0 && echo "watchcat_start_ssp" > $statusfile
	/usr/bin/shadowsocks.sh start &>/dev/null || return 1
}

amsgetnotset(){
	if $(tail -n +1 /tmp/syslog.log | grep -q 'ipnotset'); then
		tail -n +1 /tmp/syslog.log | grep 'ipnotset' >> $CONF_DIR/amsnotset.tmp || return 1
		cat $CONF_DIR/amsnotset.tmp | sed 's/ DST=/-/g' | sed 's/ LEN=/-/g' | \
		awk -F- '{print $2}' >> $CONF_DIR/amsallexp.tmp && rm -rf $CONF_DIR/amsnotset.tmp || return 1
		for addr in $(cat $CONF_DIR/amsallexp.tmp); do
			if [ $(grep -o "$addr" $CONF_DIR/amsallexp.tmp | wc -l) -ge 2 ]; then
				$(ipset list chnlist | grep -q "$addr") && ipset del chnlist $addr &>/dev/null
				$(ipset list gfwlist | grep -v -q "$addr") && ipset add gfwlist $addr &>/dev/null
				sed -i '/'$addr'/d' $CONF_DIR/CHNwhiteip.conf
				sed -i '/'$addr'/d' $CONF_DIR/GFWblackip.conf
				echo $addr >> $CONF_DIR/GFWblackip.conf
				sed -i '/'$addr'/d' $CONF_DIR/amsallexp.tmp
				sed -i '/'$addr'/d' $CONF_DIR/amsallexp.set
				sed -i '/'$addr'/d' $CONF_DIR/amsallexp.txt
				sed -i '/ DST='$addr'/d' /tmp/syslog.log
			fi
		done
	fi
	[ $(cat $CONF_DIR/amsallexp.txt 2>/dev/null | wc -l) -ge 1 ] && \
	cat $CONF_DIR/amsallexp.txt >> $CONF_DIR/amsallexp.tmp
	rm -rf $CONF_DIR/amsallexp.txt
	[ $(cat $CONF_DIR/amsallexp.tmp 2>/dev/null | wc -l) -ge 1 ] && \
	mv -f $CONF_DIR/amsallexp.tmp $CONF_DIR/amsallexp.txt
	rm -rf $CONF_DIR/amsallexp.tmp
	return 0
}

reconnection(){
	[ "$recyesornot" = "1" ] && [ $(daten -l 60) -ge 25 ] || return 0
	[ "$(daten -m)" = "0" ] || \
	$([ "$autorec" = "1" ] && [ "$(daten -m)" = "5" ]) || \
	$([ "$autorec" = "1" ] && [ $(count $netdpcount) -ge 1 ]) || return 0
	dndet || return 1
	recyesornot="0"
	scout "$gfw_domain" 4 0 || scout "$gfw_domain" 4 1
	if [ "$?" = "0" ]; then
		loger "├──连接正常" && count $netdpcount +- 0 || return 1
	elif [ "$?" = "1" ]; then
		scout "$chn_domain" 4 0 || scout "$chn_domain" 4 1
		if [ "$?" = "0" ]; then
			if [ "$autorec" = "1" ]; then
				count $netdpcount ++ 1
				[ $(count $netdpcount) -ge 3 ] && count $errorcount ++ 1
				watchcat_stop_ssp || return 1
			else
				count $netdpcount ++ 1
				[ $(count $netdpcount) -ge 9 ] && count $errorcount ++ 1 && count $areconnect +- 0
				watchcat_stop_ssp || return 1
			fi
		elif [ "$?" = "1" ]; then
			count $errorcount ++ 1 && count $areconnect +- 0
			watchcat_stop_ssp || return 1
		else
			return 1
		fi
	else
		return 1
	fi
}

automaticset(){
	!(cat "$statusfile" 2>/dev/null | grep -q 'daten_stopwatchcat') && \
	echo "watchcat_automaticset" > $statusfile && inams=0 || inams=50
	bouts=$(daten -l 50) && dndet || inams=50
	recyesornot="1"
	while [ $inams -lt $bouts ]; do
		amsgetnotset || inams=50
		[ $(cat $CONF_DIR/amsallexp.txt 2>/dev/null | wc -l) -ge 1 ] && \
		for ip in $(cat $CONF_DIR/amsallexp.txt 2>/dev/null); do
			$(ping -c 1 -s 36 -W 1 -w 1 -q $ip | grep -q '1 packets received')
			if [ "$?" = "0" ]; then
				$(ipset list gfwlist | grep -q "$ip") && ipset del gfwlist $ip &>/dev/null
				$(ipset list chnlist | grep -v -q "$ip") && ipset add chnlist $ip &>/dev/null
				sed -i '/'$ip'/d' $CONF_DIR/GFWblackip.conf
				sed -i '/'$ip'/d' $CONF_DIR/CHNwhiteip.conf
				echo $ip >> $CONF_DIR/CHNwhiteip.conf
				sed -i '/'$ip'/d' $CONF_DIR/amsallexp.set
				echo $ip >> $CONF_DIR/amsallexp.set
			else
				$(ipset list chnlist | grep -q "$ip") && ipset del chnlist $ip &>/dev/null
				$(ipset list gfwlist | grep -v -q "$ip") && ipset add gfwlist $ip &>/dev/null
				sed -i '/'$ip'/d' $CONF_DIR/CHNwhiteip.conf
				sed -i '/'$ip'/d' $CONF_DIR/GFWblackip.conf
				echo $ip >> $CONF_DIR/GFWblackip.conf
				sed -i '/'$ip'/d' $CONF_DIR/amsallexp.set
			fi
			sed -i '/'$ip'/d' $CONF_DIR/amsallexp.txt
			sed -i '/ DST='$ip'/d' /tmp/syslog.log
			bouts=$(daten -l 50) && dndet || break
		done
		sleep 1 && reconnection || inams=50
		bouts=$(daten -l 50) && dndet || inams=50
	done
}

check_cat_file(){
	$(cat "$CRON_CONF" 2>/dev/null | grep -q "ss-watchcat.sh") && cronboot="1" || cronboot="0"
	[ "$cronboot" = "1" ] || rm -rf $ssp_log_file
	$([ -e $ssp_log_file ] && [ -n $(tail -n 1 $ssp_log_file) ] && loger "└──$(infor)") || \
	echo "$(date "+%Y-%m-%d_%H:%M:%S")_$logmark└──$(infor)" > $ssp_log_file
	[ $(stat -c %s $ssp_log_file) -lt $max_log_bytes ] || \
	sed -i '/'$(tail -n 1 $ssp_log_file | awk -F: '{print $1}')'/d' $ssp_log_file
	touch $redir_log_file && [ $(stat -c %s $redir_log_file) -lt $max_log_bytes ] || \
	echo "$(date "+%Y-%m-%d_%H:%M:%S")_$logmark───日志文件过大!清空日志文件" > $redir_log_file
	[ "$cronboot" = "1" ] || return 1
	return 0
}

check_cat_sole(){
	$(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_automaticset') && \
	echo "daten_stopwatchcat" > $statusfile && sleep 2 && echo "check_cat_sole" > $statusfile
	for watchcatPID in $(pidof ss-watchcat.sh); do
		[ "$watchcatPID" != "$$" ] && kill -9 $watchcatPID
	done
	return 0
}

check(){
	echo -1000 > /proc/$$/oom_score_adj
	ulimit -t 60
	check_cat_file || goout || return 1
	check_cat_sole
	watchcat_stop_ssp || goout || return 1
	watchcat_start_ssp || goout || return 1
	automaticset || goout || return 1
	goout
}

check
