#!/bin/sh

CONF_DIR="/tmp/SSP"
statusfile="$CONF_DIR/statusfile"
scoresfile="$CONF_DIR/scoresfile"
areconnect="$CONF_DIR/areconnect"
netdpcount="$CONF_DIR/netdpcount"
errorcount="$CONF_DIR/errorcount"
scorecount="$CONF_DIR/scorecount"
dnscqstart="$CONF_DIR/dnscqstart"
socksstart="$CONF_DIR/socksstart"
quickstart="$CONF_DIR/quickstart"
startrules="$CONF_DIR/startrules"
internetcd="$CONF_DIR/internetcd"
ssp_log_file="/tmp/ss-watchcat.log"
ubin_log_file="/tmp/ss-redir.log"
max_log_bytes="100000"
CRON_CONF="/etc/storage/cron/crontabs/$(nvram get http_username)"
ubinlowRAM="65536"

tl_timeout=$(nvram get di_timeout)
timeslimit=$(expr $tl_timeout \* 3)
autorec=$(nvram get ss_watchcat_autorec)
extbpid=$(expr 100000 + $$)
logmark=${extbpid:1}
[ "$(nvram get ss_socks)" == "1" ] && sspubin="ss-local" || sspubin="ss-redir"

count(){
	counts_file="$1"
	[ -e "$counts_file" ] || echo "0" > "$counts_file"
	counts_temp=$(tail -n 1 "$counts_file")
	counts_form=${counts_temp:0}
	if [ "$2" == "+-" ] || [ "$2" == "-+" ]; then
		echo "$3" > "$counts_file"
	elif [ "$2" == "++" ]; then
		form_counts=$(expr $counts_form + $3)
		[ $form_counts -ge $4 ] && echo "$4" > "$counts_file" || echo "$form_counts" > "$counts_file"
	elif [ "$2" == "--" ]; then
		form_counts=$(expr $counts_form - $3)
		[ $form_counts -le $4 ] && echo "$4" > "$counts_file" || echo "$form_counts" > "$counts_file"
	else
		echo "$counts_form"
	fi
}

infor(){
	inforsnum=$(tail -n 1 $CONF_DIR/issjfinfor | awk -F# '{print $1}')
	infortype=$(tail -n 1 $CONF_DIR/issjfinfor | awk -F# '{print $2}')
	inforaddr=$(tail -n 1 $CONF_DIR/issjfinfor | awk -F# '{print $3}')
	inforport=$(tail -n 1 $CONF_DIR/issjfinfor | awk -F# '{print $4}')
	if [ "$1" == "0" ]; then
		[ -n "$inforsnum" ] && echo "$inforsnum@" || echo "null"
	elif [ "$1" == "1" ]; then
		[ -n "$inforsnum$infortype$inforaddr$inforport" ] && \
		echo "$inforsnum@$infortype@$inforaddr:$inforport" || echo "???@???@???:???"
	else
		[ -n "$inforsnum$infortype$inforaddr$inforport" ] && \
		echo "$inforsnum──$(count $scorecount)──$infortype──$inforaddr:$inforport" || \
		echo "???──???──???──???:???"
	fi
}

loger(){
	sed -i '1i\'$(date "+%Y-%m-%d_%H:%M:%S")'_'$logmark''$1'' $ssp_log_file
}

godet(){
	rm -rf $statusfile
	if !(ipset list -n | grep -q 'servers') || !(ipset list -n | grep -q 'private') || \
	!(ipset list -n | grep -q 'gfwlist') || !(ipset list -n | grep -q 'chnlist'); then
		count $errorcount ++ 1 5 && count $areconnect +- 0 && count $startrules +- 1
	fi
	MemTotal=$(cat /proc/meminfo | grep 'MemTotal' | \
	sed 's/[[:space:]]//g' | sed 's/kB//g' | awk -F: '{print $2}')
	ubinmaxMEM=$(expr $MemTotal \* 2)
	[ $ubinmaxMEM -le $ubinlowRAM ] && ubinmaxMEM="$ubinlowRAM"
	for sspubinPID in $(pidof $sspubin); do
		sspubinRSS=$(cat /proc/$sspubinPID/status | grep 'VmRSS' | \
		sed 's/[[:space:]]//g' | sed 's/kB//g' | awk -F: '{print $2}')
		if [ $sspubinRSS -ge $ubinmaxMEM ]; then
			count $errorcount +- 5 && count $areconnect +- 0 && count $startrules +- 1
		fi
	done
	return 0
}

goout(){
	!(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_stop_ssp') && godet
	loger "┌──$(infor)"
	exit 0
}

dndet(){
	if $(tail -n +1 $dnscqstart | grep -q 'dns-forwarder'); then
		$(pidof dns-forwarder &>/dev/null) || $(pidof dns-forwarder &>/dev/null) || \
		$(pidof dns-forwarder &>/dev/null) || $(pidof dns-forwarder &>/dev/null) || \
		$($dnscqstart && loger "├──转发进程中止!!!启动进程" && \
		echo -1000 > /proc/$(pidof dns-forwarder)/oom_score_adj)
	fi
	if $(tail -n +1 $socksstart | grep -q 'ipt2socks'); then
		$(pidof ipt2socks &>/dev/null) || $(pidof ipt2socks &>/dev/null) || \
		$(pidof ipt2socks &>/dev/null) || $(pidof ipt2socks &>/dev/null) || \
		$($socksstart && loger "├──本地代理中止!!!启动进程" && \
		echo -1000 > /proc/$(pidof ipt2socks)/oom_score_adj)
	fi
	$(pidof dnsmasq &>/dev/null) || $(pidof dnsmasq &>/dev/null) || \
	$(pidof dnsmasq &>/dev/null) || $(pidof dnsmasq &>/dev/null) || \
	$(restart_dhcpd && loger "├──解析进程中止!!!启动进程" && \
	echo -1000 > /proc/$(pidof dnsmasq)/oom_score_adj)
	$(pidof $sspubin &>/dev/null) || $(pidof $sspubin &>/dev/null) || \
	$(pidof $sspubin &>/dev/null) || $(pidof $sspubin &>/dev/null) || \
	$($quickstart && loger "├──代理进程中止!!!启动进程" && \
	echo -1000 > /proc/$(pidof $sspubin)/oom_score_adj)
}

daten(){
	dateS=$(date +%S) && [ $dateS -ge 55 ] && echo "daten_stopwatchcat" > $statusfile
	if [ "$1" == "-l" ]; then
		datel=$(expr 60 - $dateS) && echo "$datel"
	elif [ "$1" == "-m" ]; then
		date_M=$(date +%M) && datem=${date_M:1} && echo "$datem"
	else
		!(cat "$statusfile" 2>/dev/null | grep -q 'daten_stopwatchcat') || return 1
	fi
}

score(){
	sed -i '/^'$(infor 0)'/d' $scoresfile
	echo "$(infor 1)#$(count $scorecount)" >> $scoresfile
	sort -u -n -r $scoresfile > $CONF_DIR/scoresfile.tmp && mv -f $CONF_DIR/scoresfile.tmp $scoresfile
	while read line
	do
		nodeinfor=$(echo "$line" | awk -F# '{print $1}')
		nodeisnum=$(echo "$nodeinfor" | awk -F@ '{print $1}')
		nodeitype=$(echo "$nodeinfor" | awk -F@ '{print $2}')
		nodeiarpt=$(echo "$nodeinfor" | awk -F@ '{print $3}')
		nodeiaddr=$(echo "$nodeiarpt" | awk -F: '{print $1}')
		nodeiport=$(echo "$nodeiarpt" | awk -F: '{print $2}')
		nodescore=$(echo "$line" | awk -F# '{print $2}')
		loger "├──节点端口:$nodeiport"
		loger "├──节点地址:$nodeiaddr"
		loger "├──节点类型:$nodeitype"
		loger "├──连接时长:$nodescore"
		[ $nodeinfor == $(infor 1) ] && loger "┣━━当前节点:$nodeisnum" || \
		loger "┣━━历史节点:$nodeisnum"
	done < $scoresfile
	return 0
}

sleeptime(){
	sleep $1
	return $2
}

watchcat_stop_ssp(){
	!(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_stop_ssp') || return 0
	[ $(count $errorcount) -ge 1 ] || return 0
	STO_LOG="发现异常!!!暂时停止代理" && loger "├──$STO_LOG" && logger -st "SSP[$$]WARNING" "$STO_LOG"
	echo "watchcat_stop_ssp" > $statusfile && /usr/bin/shadowsocks.sh stop &>/dev/null && return 1
}

notify_detect_internet(){
	killall -q -SIGUSR2 detect_internet
}

watchcat_start_ssp(){
	$(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_stop_ssp') || return 0
	notify_detect_internet && sleeptime $timeslimit 0 && [ "$(nvram get link_internet)" == "1" ] || return 1
	count $errorcount -- 1 0 && [ $(count $errorcount) -le 0 ] || return 1
	[ "$(nvram get ss_enable)" == "1" ] || /usr/bin/shadowsocks.sh stop &>/dev/null
	!(pidof $sspubin &>/dev/null) || /usr/bin/shadowsocks.sh stop &>/dev/null
	STA_LOG="恢复正常!!!重新启动代理" && loger "├──$STA_LOG" && logger -st "SSP[$$]WARNING" "$STA_LOG"
	count $netdpcount +- 0 && count $errorcount +- 0 && echo "watchcat_start_ssp" > $statusfile
	/usr/bin/shadowsocks.sh start &>/dev/null || return 1
}

reconnection(){
	daten || return 1
	[ "$recyesornot" == "1" ] || sleeptime 1 1 || return 0
	recyesornot="0" && count $scorecount ++ 1 10080
	[ $(count $netdpcount) -ge 1 ] || [ $(nvram get link_internet) -ne 2 ] || sleeptime 1 1 || return 0
	notify_detect_internet && sleeptime $timeslimit 0
	if [ "$(nvram get link_internet)" == "2" ]; then
		count $netdpcount +- 0 && score
	elif [ "$(nvram get link_internet)" == "1" ]; then
		if [ "$autorec" == "1" ]; then
			count $netdpcount ++ 1 9
			if [ $(count $netdpcount) -ge 2 ]; then
				count $errorcount ++ 1 5
				score && count $scorecount +- 0
				watchcat_stop_ssp || watchcat_start_ssp || return 1
			else
				count $scorecount -- 1 0
			fi
		else
			count $netdpcount ++ 1 9
			if [ $(count $netdpcount) -ge 9 ]; then
				count $errorcount ++ 1 5 && count $areconnect +- 0
				score && count $scorecount +- 0
				watchcat_stop_ssp || return 1
			else
				count $scorecount -- 1 0
			fi
		fi
	elif [ "$(nvram get link_internet)" == "0" ]; then
		count $errorcount ++ 1 5 && count $internetcd +- 1
		watchcat_stop_ssp || return 1
	else
		return 0
	fi
}

automaticset(){
	daten && echo "watchcat_automaticset" > $statusfile && inams=10 || inams=61
	recyesornot="1" && bouts=$(daten -l)
	while [ $inams -le $bouts ]; do
		Stime=$(daten -l) && ST=${Stime:0}
		dndetinams=${inams:1}
		if [ "$dndetinams" == "0" ] || [ "$inams" == "$bouts" ]; then
			dndet
		fi
		reconnection || inams=61
		Etime=$(daten -l) && ET=${Etime:0}
		UT=$(expr $ST - $ET)
		inams=$((inams+UT))
	done
}

check_cat_file(){
	$(cat "$CRON_CONF" 2>/dev/null | grep -q "ss-watchcat.sh") && cronboot="1" || cronboot="0"
	[ "$cronboot" == "1" ] || rm -rf $ssp_log_file
	$([ -n "$(tail -n 1 $ssp_log_file)" ] && loger "└──$(infor)") || \
	echo "$(date "+%Y-%m-%d_%H:%M:%S")_$logmark└──$(infor)" > $ssp_log_file
	while [ $(stat -c %s $ssp_log_file) -gt $max_log_bytes ]; do
		sed -i '/'$(tail -n 1 $ssp_log_file | awk -F: '{print $1":"$2}')'/d' $ssp_log_file
	done
	touch $ubin_log_file
	while [ $(stat -c %s $ubin_log_file) -gt $max_log_bytes ]; do
		sed -i '9d' $ubin_log_file
	done
	[ $(daten -l) -ge $(expr $timeslimit \* 2 + 9) ] || return 1
	[ "$cronboot" == "1" ] && return 0 || return 1
}

check_cat_sole(){
	$(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_automaticset') && \
	echo "daten_stopwatchcat" > $statusfile && sleeptime 2 0 && echo "check_cat_sole" > $statusfile
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

