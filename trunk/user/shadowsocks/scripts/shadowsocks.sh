#!/bin/sh

USBB_DIR=$(find /media/ -name SSP)
SYSB_DIR="/usr/bin"
CONF_DIR="/tmp/SSP"
CRON_CONF="/etc/storage/cron/crontabs/$(nvram get http_username)"
[ -n "$USBB_DIR" ] && EXTB_DIR="$USBB_DIR" || EXTB_DIR="$CONF_DIR"

([ "$EXTB_DIR" == "$USBB_DIR" ] && echo "$(date "+%Y-%m-%d_%H:%M:%S")" > $EXTB_DIR/SSPUSBDIR)&
wait

#$SYSB_DIR/ss-redir -> /var/ss-redir -> $SYSB_DIR/ss-orig-redir or $SYSB_DIR/ssr-redir
ss_redir_bin="$SYSB_DIR/ss-orig-redir"
ssr_redir_bin="$SYSB_DIR/ssr-redir"
redir_bin="ss-redir"
redir_link="/var/ss-redir"
#$SYSB_DIR/ss-local -> /var/ss-local -> $SYSB_DIR/ss-orig-local or $SYSB_DIR/ssr-local
ss_local_bin="$SYSB_DIR/ss-orig-local"
ssr_local_bin="$SYSB_DIR/ssr-local"
local_bin="ss-local"
local_link="/var/ss-local"
#$SYSB_DIR/ss-redir -> /var/ss-redir -> $EXTB_DIR/trojan or $SYSB_DIR/trojan
#$SYSB_DIR/ss-redir -> /var/ss-redir -> $EXTB_DIR/v2ray or $SYSB_DIR/v2ray
#$SYSB_DIR/ss-redir -> /var/ss-redir -> $EXTB_DIR/naive or $SYSB_DIR/naive
v2rp_bin="v2ray-plugin"
v2rp_link="/var/v2ray-plugin"
#$SYSB_DIR/v2ray-plugin -> /var/v2ray-plugin -> $EXTB_DIR/v2ray-plugin or $SYSB_DIR/ss-v2ray-plugin

ubin_log_file="/tmp/ss-redir.log"
statusfile="$CONF_DIR/statusfile"
scoresfile="$CONF_DIR/scoresfile"
areconnect="$CONF_DIR/areconnect"
netdpcount="$CONF_DIR/netdpcount"
errorcount="$CONF_DIR/errorcount"
scorecount="$CONF_DIR/scorecount"
issjfinfor="$CONF_DIR/issjfinfor"
dnscqstart="$CONF_DIR/dnscqstart"
socksstart="$CONF_DIR/socksstart"
rulesstart="$CONF_DIR/rulesstart"
quickstart="$CONF_DIR/quickstart"
startrules="$CONF_DIR/startrules"
internetcd="$CONF_DIR/internetcd"

sspbinname=$(cat /etc/storage/ssp_custom.conf | grep '^sspbinname' | awk -F\| '{print $2}')
autorec=$(nvram get ss_watchcat_autorec)
ss_enable=$(nvram get ss_enable)
ss_type=$(nvram get ss_type)
ssp_type=${ss_type:0} # 0=ss 1=ssr 2=trojan 3=vmess 8=custom 9=auto
ss_mode=$(nvram get ss_mode) # 0=global 1=chnroute 21=gfwlist(diversion rate: Keen) 22=gfwlist(diversion rate: True)
diversion_rate=$(nvram get diversion_rate)
ss_socks=$(nvram get ss_socks)
ss_local_port=$(nvram get ss_local_port)
ss_redir_port=$(expr $ss_local_port + 1)
ss_mtu=$(nvram get ss_mtu)
ss_dns_p=$(nvram get ss_dns_local_port)
ss_dns_s=$(nvram get ss_dns_remote_server)
nodesnum=$(nvram get ss_server_num_x)
dnsfsmip=$(echo "$ss_dns_s" | awk -F: '{print $1}')
dnstcpsp=$(echo "$ss_dns_s" | sed 's/:/~/g')

dnsfslsp="127.0.0.1#$ss_dns_p"
dnschndt="/etc/storage/chnlist/chnlist_domain.txt"
dnschndp="$CONF_DIR/chnlist_domain.txt"
dnschndm="$CONF_DIR/chnlist_domain.md5"
dnsgfwdt="/etc/storage/gfwlist/gfwlist_domain.txt"
dnsgfwdp="$CONF_DIR/gfwlist_domain.txt"
dnsgfwdm="$CONF_DIR/gfwlist_domain.md5"
dnslistc="$CONF_DIR/gfwlist/dnsmasq.conf"
dnsmasqc="/etc/storage/dnsmasq/dnsmasq.conf"

[ "$ssp_type" == "0" ] && bin_type="SS"
[ "$ssp_type" == "1" ] && bin_type="SSR"
[ "$ssp_type" == "2" ] && bin_type="Trojan"
[ "$ssp_type" == "3" ] && bin_type="VMess"
[ "$ssp_type" == "4" ] && bin_type="Naive"
[ "$ssp_type" == "8" ] && bin_type="Custom"
[ "$ssp_type" == "9" ] && bin_type="Auto"
[ "$ss_socks" == "1" ] && ssp_ubin="$local_bin" || ssp_ubin="$redir_bin"
[ ! -d "$CONF_DIR/gfwlist" ] && mkdir -p "$CONF_DIR/gfwlist" && echo "3" > $errorcount && echo "0" > $areconnect
[ -e "$EXTB_DIR/$sspbinname" ] && chmod +x $EXTB_DIR/$sspbinname && ssp_custom="$EXTB_DIR/$sspbinname" || ssp_custom="$SYSB_DIR/$sspbinname"
[ -e "$EXTB_DIR/trojan" ] && chmod +x $EXTB_DIR/trojan && ssp_trojan="$EXTB_DIR/trojan" || ssp_trojan="$SYSB_DIR/trojan"
[ -e "$EXTB_DIR/naive" ] && chmod +x $EXTB_DIR/naive && ssp_naive="$EXTB_DIR/naive" || ssp_naive="$SYSB_DIR/naive"
[ -e "$EXTB_DIR/v2ray" ] && chmod +x $EXTB_DIR/v2ray && ssp_v2ray="$EXTB_DIR/v2ray" || ssp_v2ray="$SYSB_DIR/v2ray"
[ -e "$EXTB_DIR/v2ray-plugin" ] && chmod +x $EXTB_DIR/v2ray-plugin && ssp_v2rp="$EXTB_DIR/v2ray-plugin" || ssp_v2rp="$SYSB_DIR/ss-v2ray-plugin"
[ -L /etc/storage/chinadns/chnroute.txt ] && [ ! -e $EXTB_DIR/chnroute.txt ] && \
rm -rf /etc/storage/chinadns/chnroute.txt && tar jxf /etc_ro/chnroute.bz2 -C /etc/storage/chinadns
[ -e $EXTB_DIR/chnroute.txt ] && \
[ $(cat /etc/storage/chinadns/chnroute.txt | wc -l) -ne $(cat $EXTB_DIR/chnroute.txt | wc -l) ] && \
rm -rf /etc/storage/chinadns/chnroute.txt && \
ln -sf $EXTB_DIR/chnroute.txt /etc/storage/chinadns/chnroute.txt

stopp()
{
$(pidof "$1" &>/dev/null) || return 1
killall -q -SIGTERM "$1"
sleep 1
$(pidof "$1" &>/dev/null) || return 0
killall -q -9 "$1"
return 0
}

stop_watchcat()
{
echo "daten_stopwatchcat" > $statusfile
sed -i '/ss-watchcat.sh/d' $CRON_CONF && restart_crond
stopp ss-watchcat.sh
rm -rf $statusfile
rm -rf $netdpcount
rm -rf $errorcount
rm -rf $issjfinfor
return 0
}

stop_socks()
{
rm -rf $socksstart
stopp ipt2socks
logger -st "SSP[$$]$bin_type" "关闭本地代理"
}

stop_rules()
{
rm -rf $rulesstart
stopp ss-rules
logger -st "SSP[$$]$bin_type" "关闭透明代理" && ss-rules -f
}

custom_chnlist()
{
chndnum=$(cat $dnschndt | grep -v '^\.' | wc -l)
chnfnum=${chndnum:0}
cp -rf $dnschndt $dnschndp
md5sum $dnschndp > $dnschndm
sed -i '/^\./d' $dnschndp
for addchn in $(nvram get ss_custom_chnlist | sed 's/,/ /g'); do
  [ "$addchn" != "" ] && $(echo $addchn | grep -v -q '^\.') && echo ".$addchn" >> $dnschndp
done
md5sum -c -s $dnschndm
[ "$?" != "0" ] && rm -rf $dnschndt && cp -rf $dnschndp $dnschndt
rm -rf $dnschndp && rm -rf $dnschndm
if [ $(cat $dnschndt | wc -l) -ge $chnfnum ]; then
  return 0
else
  logger -st "SSP[$$]WARNING" "自定义白名单域名发生错误!恢复默认白名单域名"
  rm -rf $dnschndt && tar jxf /etc_ro/chnlist.bz2 -C /etc/storage/chnlist
  return 0
fi
}

custom_gfwlist()
{
gfwdnum=$(cat $dnsgfwdt | grep -v '^\.' | wc -l)
gfwfnum=${gfwdnum:0}
cp -rf $dnsgfwdt $dnsgfwdp
md5sum $dnsgfwdp > $dnsgfwdm
sed -i '/^\./d' $dnsgfwdp
for addgfw in $(nvram get ss_custom_gfwlist | sed 's/,/ /g'); do
  gfwdomain=$(echo $addgfw | grep -v '^\.' | grep -v '^#')
  [ "$gfwdomain" != "" ] && echo ".$gfwdomain" >> $dnsgfwdp
done
md5sum -c -s $dnsgfwdm
[ "$?" != "0" ] && rm -rf $dnsgfwdt && cp -rf $dnsgfwdp $dnsgfwdt
rm -rf $dnsgfwdp && rm -rf $dnsgfwdm
if [ $(cat $dnsgfwdt | wc -l) -ge $gfwfnum ]; then
  return 0
else
  logger -st "SSP[$$]WARNING" "自定义黑名单域名发生错误!恢复默认黑名单域名"
  rm -rf $dnsgfwdt && tar jxf /etc_ro/gfwlist.bz2 -C /etc/storage/gfwlist
  return 0
fi
}

del_dns_conf()
{
logger -st "SSP[$$]$bin_type" "清除解析规则"
sed -i 's/^### gfwlist related.*/### gfwlist related resolve/g' $dnsmasqc
sed -i 's/^min-cache-ttl=/#min-cache-ttl=/g' $dnsmasqc
sed -i 's:^conf-dir='$CONF_DIR'/gfwlist:#conf-dir='$CONF_DIR'/gfwlist:g' $dnsmasqc
rm -rf $dnslistc
rm -rf $dnscqstart
stopp dns-forwarder
custom_chnlist
custom_gfwlist
}

get_dns_conf()
{
logger -st "SSP[$$]$bin_type" "创建解析规则"
grep -v '^#' $dnsgfwdt | grep -v '^$' | sed 's/^\.//g' | awk '{printf("server=/%s/'$2'\n", $1, $1 )}' >> $dnslistc
if [ "$ss_mode" == "21" ] || [ "$ss_mode" == "22" ]; then
  grep -v '^#' $dnsgfwdt | grep -v '^$' | sed 's/^\.//g' | awk '{printf("ipset=/%s/gfwlist\n", $1, $1 )}' >> $dnslistc
  grep -v '^#' $dnschndt | grep -v '^$' | sed 's/^\.//g' | awk '{printf("ipset=/%s/chnlist\n", $1, $1 )}' >> $dnslistc
fi
[ -e "$CONF_DIR/Serveraddr-noip" ] && cat $CONF_DIR/Serveraddr-noip | awk '{printf("ipset=/%s/servers\n", $1, $1 )}' >> $dnslistc
for addgfw in $(nvram get ss_custom_gfwlist | sed 's/,/ /g'); do
  dnsspoofing=$(echo $addgfw | grep '^#' | sed 's/#//g')
  if [ "$dnsspoofing" != "" ]; then
    sed -i '/'$dnsspoofing'/d' $dnslistc
    echo "server=/$dnsspoofing/$2" >> $dnslistc
    echo "ipset=/$dnsspoofing/chnlist" >> $dnslistc
  fi
done
sed -i 's/^### gfwlist related.*/### gfwlist related resolve by '$1' '$2'/g' $dnsmasqc
sed -i 's/^#min-cache-ttl=/min-cache-ttl=/g' $dnsmasqc
[ -e "$dnslistc" ] && sed -i 's:^#conf-dir='$CONF_DIR'/gfwlist:conf-dir='$CONF_DIR'/gfwlist:g' $dnsmasqc
return 0
}

gen_dns_conf()
{
del_dns_conf
if [ "$1" != "0" ] && [ "$(nvram get dns_forwarder_enable)" == "1" ]; then
  get_dns_conf dns-forwarder "$dnsfslsp"
  cat > "$dnscqstart" << EOF
#!/bin/sh

start-stop-daemon -S -b -N 0 -x dns-forwarder -- -b 0.0.0.0 -p $ss_dns_p -s $ss_dns_s
EOF
elif [ "$1" != "0" ] && [ "$(nvram get dns_forwarder_enable)" == "0" ]; then
  get_dns_conf dnsmasq-tcpdns "$dnstcpsp"
fi
[ -e "$dnscqstart" ] && chmod +x $dnscqstart && $dnscqstart
restart_dhcpd
}

del_json_file()
{
logger -st "SSP[$$]$bin_type" "清除配置文件"
rm -rf $CONF_DIR/*.md5
rm -rf $CONF_DIR/*.json
rm -rf $CONF_DIR/*-jsonlist
rm -rf $CONF_DIR/Nodes-list
rm -rf $CONF_DIR/Serveraddr-isip
rm -rf $CONF_DIR/Serveraddr-noip
return 0
}

del_score_file()
{
rm -rf $scoresfile
rm -rf $scorecount
return 0
}

stop_redir()
{
(stopp $redir_bin && logger -st "SSP[$$]$bin_type" "关闭代理进程")&
(stopp $local_bin && logger -st "SSP[$$]$bin_type" "关闭代理进程")&
(stopp $v2rp_bin && logger -st "SSP[$$]$bin_type" "关闭插件进程")&
(rm -rf $quickstart)&
wait
return 0
}

notify_detect_internet()
{
killall -q -SIGUSR2 detect_internet
}

stop_ssp()
{
[ -n "$1" ] && nvram set ss_enable=0 && logger -st "SSP[$$]WARNING" "$1"
if [ "$ss_enable" == "0" ]; then
  stop_watchcat
  stop_socks
  stop_rules
  gen_dns_conf 0
  del_json_file
  del_score_file
  rm -rf $areconnect
  rm -rf $startrules
  rm -rf $internetcd
elif [ "$(tail -n 1 $internetcd 2>/dev/null)" == "1" ]; then
  $(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_stop_ssp') || stop_watchcat
  stop_socks
  stop_rules
  gen_dns_conf 0
  del_json_file
  del_score_file
  rm -rf $areconnect
  rm -rf $startrules
  rm -rf $internetcd
else
  $(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_stop_ssp') || stop_watchcat
fi
stop_redir
notify_detect_internet
return 0
}

turn_json_file()
{
[ -e "$CONF_DIR/ssp_custom.md5" ] && md5sum -c -s $CONF_DIR/ssp_custom.md5 || return 1
[ -e "$CONF_DIR/Nodes-list.md5" ] && rm -rf $CONF_DIR/Nodes-list && for i in $(seq 1 $nodesnum); do
  j=$(expr $i - 1)
  node_type=$(nvram get ss_server_type_x$j)      # 0  1   2      3     4
  server_addr=$(nvram get ss_server_addr_x$j)    # SS SSR Trojan VMess Naive
  server_port=$(nvram get ss_server_port_x$j)    # SS SSR Trojan VMess Naive
  server_key=$(nvram get ss_server_key_x$j)      # SS SSR Trojan VMess Naive
  server_sni=$(nvram get ss_server_sni_x$j)      #        Trojan VMess
  ss_method=$(nvram get ss_method_x$j)           # SS SSR        VMess
  ss_protocol=$(nvram get ss_protocol_x$j)       #    SSR        VMess Naive
  ss_proto_param=$(nvram get ss_proto_param_x$j) #    SSR        VMess
  ss_obfs=$(nvram get ss_obfs_x$j)               # SS SSR        VMess
  ss_obfs_param=$(nvram get ss_obfs_param_x$j)   # SS SSR        VMess
  echo "$i#$node_type#$server_addr#$server_port#$server_key#$server_sni#$ss_method#$ss_protocol#$ss_proto_param#$ss_obfs#$ss_obfs_param" >> $CONF_DIR/Nodes-list
done && md5sum -c -s $CONF_DIR/Nodes-list.md5 || return 1
[ "$(cat $CONF_DIR/$bin_type-jsonlist 2>/dev/null | wc -l)" != "1" ] || return 0
[ "$(tail -n 1 $areconnect 2>/dev/null)" == "1" ] || return 0
logger -st "SSP[$$]$bin_type" "更换配置文件" && echo "0" > $scorecount
turn_temp=$(tail -n 1 $CONF_DIR/$bin_type-jsonlist)
turn_json=${turn_temp:0}
sed -i '/'$turn_json'/d' $CONF_DIR/$bin_type-jsonlist
sed -i '1i\'$turn_json'' $CONF_DIR/$bin_type-jsonlist
return 0
}

addr_isip_noip()
{
addr_isip=$(echo "$1" | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}")
addr_noip=$(echo "$1" | grep -E -v "^([0-9]{1,3}\.){3}[0-9]{1,3}")
if [ "$addr_isip" == "$1" ]; then
  [ ! -e "$CONF_DIR/Serveraddr-isip" ] || echo -e ",\c" >> $CONF_DIR/Serveraddr-isip
  echo -e "$addr_isip\c" >> $CONF_DIR/Serveraddr-isip
elif [ "$addr_noip" == "$1" ]; then
  echo "$addr_noip" >> $CONF_DIR/Serveraddr-noip
fi
}

gen_json_file()
{
[ "$bin_type" == "Custom" ] || [ $nodesnum -ge 1 ] || $(stop_ssp "请到[节点设置]添加服务器" && return 1) || exit 1
confoptarg=$(cat /etc/storage/ssp_custom.conf | grep '^confoptarg' | awk -F\| '{print $2}')
serveraddr=$(cat /etc/storage/ssp_custom.conf | grep '^serveraddr' | awk -F\| '{print $2}')
serverport=$(cat /etc/storage/ssp_custom.conf | grep '^serverport' | awk -F\| '{print $2}')
turn_json_file || del_json_file
[ "$autorec" == "1" ] && echo "1" > $areconnect || echo "0" > $areconnect
if [ ! -e "$CONF_DIR/Nodes-list.md5" ]; then
  echo "1" > $startrules
  logger -st "SSP[$$]$bin_type" "创建配置文件"
  for i in $(seq 1 $nodesnum); do
    j=$(expr $i - 1)
    node_type=$(nvram get ss_server_type_x$j)      # 0  1   2      3     4
    server_addr=$(nvram get ss_server_addr_x$j)    # SS SSR Trojan VMess Naive
    server_port=$(nvram get ss_server_port_x$j)    # SS SSR Trojan VMess Naive
    server_key=$(nvram get ss_server_key_x$j)      # SS SSR Trojan VMess Naive
    server_sni=$(nvram get ss_server_sni_x$j)      #        Trojan VMess
    ss_method=$(nvram get ss_method_x$j)           # SS SSR        VMess
    ss_protocol=$(nvram get ss_protocol_x$j)       #    SSR        VMess Naive
    ss_proto_param=$(nvram get ss_proto_param_x$j) #    SSR        VMess
    ss_obfs=$(nvram get ss_obfs_x$j)               # SS SSR        VMess
    ss_obfs_param=$(nvram get ss_obfs_param_x$j)   # SS SSR        VMess
    addr_isip_noip $server_addr
    echo "$i#$node_type#$server_addr#$server_port#$server_key#$server_sni#$ss_method#$ss_protocol#$ss_proto_param#$ss_obfs#$ss_obfs_param" >> $CONF_DIR/Nodes-list
    [ "$node_type" == "0" ] && server_type="SS"
    [ "$node_type" == "1" ] && server_type="SSR"
    [ "$node_type" == "2" ] && server_type="Trojan"
    [ "$node_type" == "3" ] && server_type="VMess"
    [ "$node_type" == "4" ] && server_type="Naive"
    if [ "$server_type" == "SS" ]; then
      if [ "$ss_obfs" == "v2ray_plugin_websocket" ]; then
        ss_pm="v2rp-WEBS" && ss_plugin="$v2rp_bin"
      elif [ "$ss_obfs" == "v2ray_plugin_quic" ]; then
        ss_pm="v2rp-QUIC" && ss_plugin="$v2rp_bin"
      else
        ss_pm="null" && ss_plugin=""
      fi
      if [ "$ss_pm" == "null" ]; then
        ss_popts=""
        ss_pargs=""
      else
        if $(echo "$ss_obfs_param" | grep -q ","); then
          ss_popts=$(echo "$ss_obfs_param" | awk -F, '{print $1}')
          ss_pargs=$(echo "$ss_obfs_param" | awk -F, '{print $2}')
        else
          ss_popts="$ss_obfs_param"
          ss_pargs=""
        fi
      fi
      r_json_file="$i-$server_type-redir.json"
      l_json_file="$r_json_file"
      echo "$server_addr#$server_port#$r_json_file#$l_json_file#$ss_pm" >> $CONF_DIR/SS-jsonlist
      echo "$server_addr#$server_port#$r_json_file#$l_json_file#$ss_pm" >> $CONF_DIR/Auto-jsonlist
	    cat > "$CONF_DIR/$r_json_file" << EOF
{
    "server": "$server_addr",
    "server_port": $server_port,
    "password": "$server_key",
    "method": "$ss_method",
    "plugin": "$ss_plugin",
    "plugin_opts": "$ss_popts",
    "plugin_args": "$ss_pargs",
    "timeout": 60,
    "local_address": "0.0.0.0",
    "local_port": $ss_local_port,
    "mtu": $ss_mtu
}

EOF
    elif [ "$server_type" == "SSR" ]; then
      r_json_file="$i-$server_type-redir.json"
      l_json_file="$r_json_file"
      echo "$server_addr#$server_port#$r_json_file#$l_json_file#null" >> $CONF_DIR/SSR-jsonlist
      echo "$server_addr#$server_port#$r_json_file#$l_json_file#null" >> $CONF_DIR/Auto-jsonlist
	    cat > "$CONF_DIR/$r_json_file" << EOF
{
    "server": "$server_addr",
    "server_port": $server_port,
    "password": "$server_key",
    "method": "$ss_method",
    "timeout": 60,
    "protocol": "$ss_protocol",
    "protocol_param": "$ss_proto_param",
    "obfs": "$ss_obfs",
    "obfs_param": "$ss_obfs_param",
    "local_address": "0.0.0.0",
    "local_port": $ss_local_port,
    "mtu": $ss_mtu
}

EOF
    elif [ "$server_type" == "Trojan" ]; then
      if [ "$server_sni" == "" ]; then
        verifyhostname="false"
      else
        verifyhostname="true"
      fi
      r_json_file="$i-$server_type-redir.json"
      l_json_file="$i-$server_type-local.json"
      echo "$server_addr#$server_port#$r_json_file#$l_json_file#null" >> $CONF_DIR/Trojan-jsonlist
      echo "$server_addr#$server_port#$r_json_file#$l_json_file#null" >> $CONF_DIR/Auto-jsonlist
      cat > "$CONF_DIR/$r_json_file" << EOF
{
    "run_type": "nat",
    "local_addr": "0.0.0.0",
    "local_port": $ss_local_port,
    "remote_addr": "$server_addr",
    "remote_port": $server_port,
    "password": [
        "$server_key"
    ],
    "log_level": 2,
    "ssl": {
        "verify": $verifyhostname,
        "verify_hostname": $verifyhostname,
        "sni": "$server_sni"
    }
}

EOF
      cat > "$CONF_DIR/$l_json_file" << EOF
{
    "run_type": "client",
    "local_addr": "0.0.0.0",
    "local_port": $ss_local_port,
    "remote_addr": "$server_addr",
    "remote_port": $server_port,
    "password": [
        "$server_key"
    ],
    "log_level": 2,
    "ssl": {
        "verify": $verifyhostname,
        "verify_hostname": $verifyhostname,
        "sni": "$server_sni"
    }
}

EOF
    elif [ "$server_type" == "Naive" ]; then
      r_json_file="$i-$server_type-redir.json"
      l_json_file="$i-$server_type-local.json"
      echo "$server_addr#$server_port#$r_json_file#$l_json_file#null" >> $CONF_DIR/Naive-jsonlist
      echo "$server_addr#$server_port#$r_json_file#$l_json_file#null" >> $CONF_DIR/Auto-jsonlist
      cat > "$CONF_DIR/$r_json_file" << EOF
{
  "listen": "redir://0.0.0.0:$ss_local_port",
  "proxy": "$ss_protocol://$server_key@$server_addr:$server_port",
  "log": "$ubin_log_file"
}

EOF
      cat > "$CONF_DIR/$l_json_file" << EOF
{
  "listen": "socks://0.0.0.0:$ss_local_port",
  "proxy": "$ss_protocol://$server_key@$server_addr:$server_port",
  "log": "$ubin_log_file"
}

EOF
    elif [ "$server_type" == "VMess" ]; then
      if $(echo "$server_key" | grep -q ","); then
        server_uid=$(echo "$server_key" | awk -F, '{print $1}')
        server_aid=$(echo "$server_key" | awk -F, '{print $2}')
      else
        server_uid="$server_key"
        server_aid="0"
      fi
      r_json_file="$i-$server_type-redir.json"
      l_json_file="$i-$server_type-local.json"
      echo "$server_addr#$server_port#$r_json_file#$l_json_file#null" >> $CONF_DIR/VMess-jsonlist
      echo "$server_addr#$server_port#$r_json_file#$l_json_file#null" >> $CONF_DIR/Auto-jsonlist
      cat > "$CONF_DIR/$r_json_file" << EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "redir",
      "port": $ss_local_port,
      "listen": "0.0.0.0",
      "protocol": "dokodemo-door",
      "settings": {
        "network": "tcp",
        "followRedirect": true
      },
      "streamSettings": {
        "sockopt": {
          "tcpFastOpen": false,
          "tproxy": "redirect"
        }
      },
      "sniffing": {
        "enabled": false,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
EOF
      cat > "$CONF_DIR/$l_json_file" << EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "socks",
      "port": $ss_local_port,
      "listen": "0.0.0.0",
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true
      },
      "streamSettings": {
        "sockopt": {
          "tcpFastOpen": false,
          "tproxy": "redirect"
        }
      },
      "sniffing": {
        "enabled": false,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
EOF
      tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
  "outbounds": [
    {
      "tag": "proxy",
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "$server_addr",
            "port": $server_port,
            "users": [
              {
                "id": "$server_uid",
                "alterId": $server_aid,
                "security": "$ss_method"
              }
            ]
          }
        ]
      },
EOF
      if [ "$ss_protocol" == "tcp" ] && [ "$ss_obfs" == "none" ]; then
        tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "streamSettings": {
        "network": "tcp"
      },
EOF
      elif [ "$ss_protocol" == "tcp" ] && [ "$ss_obfs" == "http" ]; then
        tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "streamSettings": {
        "network": "tcp",
        "tcpSettings": {
          "header": {
            "type": "http",
            "request": {
              "version": "1.1",
              "method": "GET",
              "path": [
                "$ss_proto_param"
              ],
              "headers": {
EOF
        if $(echo "$ss_obfs_param" | grep -q ","); then
          host1=$(echo "$ss_obfs_param" | awk -F, '{print $1}')
          host2=$(echo "$ss_obfs_param" | awk -F, '{print $2}')
          tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
                "Host": [
                  "$host1",
                  "$host2"
                ],
EOF
        else
          tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
                "Host": [
                  "$ss_obfs_param"
                ],
EOF
        fi
        tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
                "User-Agent": [
                  "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.75 Safari/537.36",
                  "Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_2 like Mac OS X) AppleWebKit/601.1 (KHTML, like Gecko) CriOS/53.0.2785.109 Mobile/14A456 Safari/601.1.46"
                ],
                "Accept-Encoding": [
                  "gzip, deflate"
                ],
                "Connection": [
                  "keep-alive"
                ],
                "Pragma": "no-cache"
              }
            }
          }
        }
      },
EOF
      elif [ "$ss_protocol" == "tcp_tls" ]; then
        if [ "$server_sni" != "" ]; then
          server_name="$server_sni"
          allow_insecure="false"
        else
          server_name="$ss_obfs_param"
          allow_insecure="true"
        fi
        if [ "$ss_obfs_param" == "" ]; then
          tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "streamSettings": {
        "network": "tcp",
        "security": "tls"
      },
EOF
        elif [ "$ss_obfs_param" != "" ]; then
          tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "allowInsecure": $allow_insecure,
          "serverName": "$server_name"
        }
      },
EOF
        fi
      elif [ "$ss_protocol" == "ws" ]; then
        if [ "$ss_proto_param" == "" ] && [ "$ss_obfs_param" == "" ]; then
          tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "streamSettings": {
        "network": "ws"
      },
EOF
        elif [ "$ss_proto_param" != "" ] && [ "$ss_obfs_param" == "" ]; then
          tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "$ss_proto_param"
        }
      },
EOF
        elif [ "$ss_proto_param" == "" ] && [ "$ss_obfs_param" != "" ]; then
          tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "headers": {
            "Host": "$ss_obfs_param"
          }
        }
      },
EOF
        elif [ "$ss_proto_param" != "" ] && [ "$ss_obfs_param" != "" ]; then
          tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "$ss_proto_param",
          "headers": {
            "Host": "$ss_obfs_param"
          }
        }
      },
EOF
        fi
      elif [ "$ss_protocol" == "ws_tls" ]; then
        if [ "$server_sni" != "" ]; then
          server_name="$server_sni"
          allow_insecure="false"
        else
          server_name="$ss_obfs_param"
          allow_insecure="true"
        fi
        if [ "$ss_proto_param" == "" ] && [ "$ss_obfs_param" == "" ]; then
          tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "streamSettings": {
        "network": "ws",
        "security": "tls"
      },
EOF
        elif [ "$ss_proto_param" != "" ] && [ "$ss_obfs_param" == "" ]; then
          tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "wsSettings": {
          "path": "$ss_proto_param"
        }
      },
EOF
        elif [ "$ss_proto_param" == "" ] && [ "$ss_obfs_param" != "" ]; then
          tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "allowInsecure": $allow_insecure,
          "serverName": "$server_name"
        },
        "wsSettings": {
          "headers": {
            "Host": "$ss_obfs_param"
          }
        }
      },
EOF
        elif [ "$ss_proto_param" != "" ] && [ "$ss_obfs_param" != "" ]; then
          tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "allowInsecure": $allow_insecure,
          "serverName": "$server_name"
        },
        "wsSettings": {
          "path": "$ss_proto_param",
          "headers": {
            "Host": "$ss_obfs_param"
          }
        }
      },
EOF
        fi
      fi
      tee -a -i "$CONF_DIR/$r_json_file" "$CONF_DIR/$l_json_file" << EOF
      "mux": {
        "enabled": true,
        "concurrency": 1
      }
    }
  ]
}

EOF
    fi
  done
  addr_isip_noip $serveraddr
  r_json_file="0-$sspbinname-redir.json"
  l_json_file="$r_json_file"
  cat /etc/storage/ssp_custom.conf | grep -v '^#' | grep -v '^sspbinname' | grep -v '^confoptarg' | \
  grep -v '^serveraddr' | grep -v '^serverport' >> $CONF_DIR/$r_json_file
  echo "$serveraddr#$serverport#$r_json_file#$l_json_file#null" > $CONF_DIR/Custom-jsonlist
  md5sum /etc/storage/ssp_custom.conf > $CONF_DIR/ssp_custom.md5
  md5sum $CONF_DIR/Nodes-list > $CONF_DIR/Nodes-list.md5
fi
[ "$bin_type" == "Custom" ] || [ "$bin_type" == "Auto" ] || \
$(cat $CONF_DIR/$bin_type-jsonlist 2>/dev/null | grep -q "$bin_type-redir") || \
$(stop_ssp "请到[节点设置]添加 $bin_type 服务器" && return 1) || exit 1
ssp_server_addr=$(tail -n 1 $CONF_DIR/$bin_type-jsonlist | awk -F# '{print $1}')
ssp_server_port=$(tail -n 1 $CONF_DIR/$bin_type-jsonlist | awk -F# '{print $2}')
redir_json_file=$(tail -n 1 $CONF_DIR/$bin_type-jsonlist | awk -F# '{print $3}')
local_json_file=$(tail -n 1 $CONF_DIR/$bin_type-jsonlist | awk -F# '{print $4}')
ssp_plugin_mode=$(tail -n 1 $CONF_DIR/$bin_type-jsonlist | awk -F# '{print $5}')
ssp_server_snum=$(echo "$redir_json_file" | awk -F- '{print $1}')
[ "$bin_type" == "Custom" ] && ssp_server_type="Custom" || \
ssp_server_type=$(echo "$redir_json_file" | awk -F- '{print $2}')
if [ "$ssp_server_type" == "SS" ]; then
  if [ "$ssp_plugin_mode" != "null" ]; then
    $([ -x "$ssp_v2rp" ] && ln -sf $ssp_v2rp $v2rp_link) || \
    $(stop_ssp "请上传 v2ray-plugin 可执行文件到 $EXTB_DIR/" && return 1) || exit 1
  fi
  ln -sf $ss_redir_bin $redir_link
  ln -sf $ss_local_bin $local_link
elif [ "$ssp_server_type" == "SSR" ]; then
  ln -sf $ssr_redir_bin $redir_link
  ln -sf $ssr_local_bin $local_link
elif [ "$ssp_server_type" == "Trojan" ]; then
  $([ -x "$ssp_trojan" ] && ln -sf $ssp_trojan $redir_link && ln -sf $ssp_trojan $local_link) || \
  $(stop_ssp "请上传 trojan 可执行文件到 $EXTB_DIR/" && return 1) || exit 1
elif [ "$ssp_server_type" == "Naive" ]; then
  $([ -x "$ssp_naive" ] && ln -sf $ssp_naive $redir_link && ln -sf $ssp_naive $local_link) || \
  $(stop_ssp "请上传 naive 可执行文件到 $EXTB_DIR/" && return 1) || exit 1
elif [ "$ssp_server_type" == "VMess" ]; then
  $([ -x "$ssp_v2ray" ] && ln -sf $ssp_v2ray $redir_link && ln -sf $ssp_v2ray $local_link) || \
  $(stop_ssp "请上传 v2ray 可执行文件到 $EXTB_DIR/" && return 1) || exit 1
elif [ "$ssp_server_type" == "Custom" ]; then
  $([ -x "$ssp_custom" ] && ln -sf $ssp_custom $redir_link && ln -sf $ssp_custom $local_link) || \
  $(stop_ssp "请上传 $sspbinname 可执行文件到 $EXTB_DIR/" && return 1) || exit 1
fi
$([ -n "$ssp_server_snum" ] && [ -n "$ssp_server_type" ] && \
[ -n "$ssp_server_addr" ] && [ -n "$ssp_server_port" ] && \
[ -n "$redir_json_file" ] && return 0) || $(stop_ssp "创建配置文件出错" && return 1) || exit 1
}

start_socks()
{
[ "$ssp_ubin" == "$local_bin" ] || return 1
[ ! -e "$socksstart" ] || return 0
cat > "$socksstart" << EOF
#!/bin/sh

start-stop-daemon -S -b -N 0 -x ipt2socks -- -s 0.0.0.0 -p $ss_local_port -b 0.0.0.0 -l $ss_redir_port -R
EOF
chmod +x $socksstart && logger -st "SSP[$$]$bin_type" "开启本地代理" && $socksstart
}

sip_addr()
{
if [ -e "$CONF_DIR/Serveraddr-isip" ]; then
  serverisip=$(tail -n 1 $CONF_DIR/Serveraddr-isip)
else
  serverisip=0
fi
echo " -s $serverisip"
}

sip_port()
{
if [ "$ssp_ubin" == "$local_bin" ]; then
  echo " -i $ss_redir_port"
else
  echo " -i $ss_local_port"
fi
}

gfw_list()
{
if [ "$ss_mode" == "0" ] || [ ! -e "$EXTB_DIR/GFWblackip.conf" ]; then # global or not GFWblackip.conf
  echo ""
elif [ "$ss_mode" == "1" ]; then # chnroute
  echo ""
elif [ "$ss_mode" == "21" ] || [ "$ss_mode" == "22" ]; then # gfwlist
  echo " -g $EXTB_DIR/GFWblackip.conf"
fi
}

chn_list()
{
if [ "$ss_mode" == "0" ]; then # global
  echo ""
elif [ "$ss_mode" == "1" ]; then # chnroute
  echo " -c /etc/storage/chinadns/chnroute.txt"
elif [ "$ss_mode" == "21" ] || [ "$ss_mode" == "22" ]; then # gfwlist
  echo ""
fi
}

chnexp_list()
{
if [ "$ss_mode" == "0" ] || [ ! -e "$EXTB_DIR/CHNwhiteip.conf" ]; then # global or not CHNwhiteip.conf
  echo ""
elif [ "$ss_mode" == "1" ]; then # chnroute
  echo " -e $EXTB_DIR/CHNwhiteip.conf"
elif [ "$ss_mode" == "21" ] || [ "$ss_mode" == "22" ]; then # gfwlist
  echo ""
fi
}

black_ip()
{
[ "$ss_mode" != "0" ] && echo " -b $dnsfsmip" || echo ""
}

white_ip()
{
addchn=$(nvram get ss_custom_chnroute | sed 's/[[:space:]]/,/g')
[ "$ss_mode" != "0" ] && [ "$addchn" != "" ] && echo " -w $addchn" || echo ""
}

agent_mode()
{
if [ "$ss_mode" == "0" ]; then # global
  echo " -a 0"
elif [ "$ss_mode" == "1" ]; then # chnroute
  echo " -a 1"
elif [ "$ss_mode" == "21" ]; then # gfwlist(diversion rate: Keen)
  echo " -a 21"
elif [ "$ss_mode" == "22" ]; then # gfwlist(diversion rate: True)
  echo " -a 22"
fi
}

agent_pact()
{
echo " -t"
}

conffile()
{
if [ "$ssp_ubin" == "$local_bin" ]; then
  echo "$CONF_DIR/$local_json_file"
else
  echo "$CONF_DIR/$redir_json_file"
fi
}

opt_arg()
{
if [ "$ssp_server_type" == "Custom" ] && [ "$confoptarg" != "" ]; then
  echo " $confoptarg"
elif [ "$ssp_server_type" == "Naive" ]; then
  echo " $(conffile)"
elif [ "$ssp_server_type" == "VMess" ]; then
  echo " run -c $(conffile)"
else
  echo " -c $(conffile)"
fi
}

udp_ext()
{
if [ "$ssp_ubin" == "$local_bin" ] && [ "$ssp_server_type" == "SS" -o "$ssp_server_type" == "SSR" ]; then
  echo " -u"
else
  echo ""
fi
}

start_rules()
{
[ $(tail -n +1 "$startrules" 2>/dev/null) -eq 1 ] || return 0
cat > "$rulesstart" << EOF
#!/bin/sh

killall -q -9 ss-rules
ss-rules\
$(sip_addr)\
$(sip_port)\
$(gfw_list)\
$(chn_list)\
$(chnexp_list)\
$(black_ip)\
$(white_ip)\
$(agent_mode)\
$(agent_pact)
EOF
chmod +x $rulesstart && logger -st "SSP[$$]$bin_type" "开启透明代理" && $rulesstart
SREC="$?"
$([ "$SREC" == "0" ] && echo "0" > $startrules && gen_dns_conf && del_score_file && return 0) || \
$([ "$SREC" == "1" ] && restart_firewall && gen_dns_conf && del_score_file && return 0) || \
$(echo "1" > $startrules && return $SREC)
}

start_redir()
{
cat > "$quickstart" << EOF
#!/bin/sh

conffile="$(conffile)"
export SSL_CERT_FILE='/etc/storage/cacerts/cacert.pem'
nohup $ssp_ubin$(opt_arg)$(udp_ext) &>$ubin_log_file &
EOF
chmod +x $quickstart && logger -st "SSP[$$]$bin_type" "启动代理进程" && $quickstart
$(sleep 1 && pidof $ssp_ubin &>/dev/null) || $(sleep 1 && pidof $ssp_ubin &>/dev/null)
[ "$?" == "1" ] && echo "1" > $areconnect && return 1 || return 0
}

ncron()
{
!(cat "$CRON_CONF" 2>/dev/null | grep -q "ss-watchcat.sh") && \
sed -i '/ss-watchcat.sh/d' $CRON_CONF && \
echo "*/$1 * * * * nohup $SYSB_DIR/ss-watchcat.sh 2>/dev/null &" >> $CRON_CONF || return 1
}

dcron()
{
$(cat "$CRON_CONF" 2>/dev/null | grep "ss-watchcat.sh" | grep -q -v "/$1") && \
sed -i '/ss-watchcat.sh/d' $CRON_CONF && \
echo "*/$1 * * * * nohup $SYSB_DIR/ss-watchcat.sh 2>/dev/null &" >> $CRON_CONF || return 1
}

scron()
{
ncron $1 || dcron $1
[ "$?" == "0" ] && restart_crond
return 0
}

start_ssp()
{
ulimit -n 65536
[ $(tail -n +1 "$errorcount" 2>/dev/null) -ge 1 ] && scron 1 && exit 0
$(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_start_ssp') || stop_watchcat
gen_json_file
start_socks || stop_socks
start_redir || $(echo "1" > $errorcount && logger -st "SSP[$$]WARNING" "启动代理进程出错")
start_rules || $(echo "1" > $errorcount && logger -st "SSP[$$]WARNING" "开启透明代理出错")
echo "$ssp_server_snum#$ssp_server_type#$ssp_server_addr#$ssp_server_port" > $issjfinfor
[ $(tail -n +1 "$errorcount" 2>/dev/null) -ge 1 ] && scron 1 && exit 0
sleep 1 && pidof ss-watchcat.sh &>/dev/null && STA_LOG="重启完成" || $SYSB_DIR/ss-watchcat.sh
logger -st "SSP[$(pidof $ssp_ubin)]$ssp_server_type" "节点$ssp_server_snum[$ssp_server_addr:$ssp_server_port]${STA_LOG:=成功启动}" && scron 1
notify_detect_internet
return 0
}

case "$1" in
stop)
  stop_ssp
  ;;
start)
  start_ssp
  ;;
restart)
  stop_ssp
  start_ssp
  ;;
rednsconf)
  gen_dns_conf
  ;;
*)
  echo "Usage: $0 { stop | start | restart | rednsconf }"
  exit 1
  ;;
esac

