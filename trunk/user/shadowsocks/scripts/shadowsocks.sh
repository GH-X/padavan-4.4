#!/bin/sh

#/usr/bin/ss-redir -> /var/ss-redir -> /usr/bin/ss-orig-redir or /usr/bin/ssr-redir
ss_redir_bin="/usr/bin/ss-orig-redir"
ssr_redir_bin="/usr/bin/ssr-redir"
redir_bin="ss-redir"
redir_link="/var/ss-redir"
#/usr/bin/ss-local -> /var/ss-tunnel -> /usr/bin/ss-orig-tunnel or /usr/bin/ssr-local
ss_tunnel_bin="/usr/bin/ss-orig-tunnel"
ssr_tunnel_bin="/usr/bin/ssr-local"
tunnel_bin="ss-local"
tunnel_link="/var/ss-tunnel"
#/usr/bin/ss-redir -> /var/ss-redir -> /tmp/trojan or /usr/bin/trojan
v2rp_bin="v2ray-plugin"
v2rp_link="/var/v2ray-plugin"
#/usr/bin/v2ray-plugin -> /var/v2ray-plugin -> /tmp/ss-v2ray-plugin or /usr/bin/ss-v2ray-plugin

CONF_DIR="/tmp/SSP"
redir_log_file="/tmp/ss-redir.log"
statusfile="$CONF_DIR/statusfile"
areconnect="$CONF_DIR/areconnect"
netdpcount="$CONF_DIR/netdpcount"
errorcount="$CONF_DIR/errorcount"
issjfinfor="$CONF_DIR/issjfinfor"
quickstart="$CONF_DIR/quickstart"
CRON_CONF="/etc/storage/cron/crontabs/$(nvram get http_username)"

autorec=$(nvram get ss_watchcat_autorec)
ss_enable=$(nvram get ss_enable)
ss_type=$(nvram get ss_type)
ssp_type=${ss_type:0} # 0=ss 1=ssr 2=trojan 9=auto
ss_mode=$(nvram get ss_mode) # 0=global 1=chnroute 2=gfwlist
ss_local_port=$(nvram get ss_local_port)
ss_mtu=$(nvram get ss_mtu)
ss_tunnel_mtu=$(nvram get ss-tunnel_mtu)
ss_timeout=$(nvram get ss_timeout)
ss_dns_p=$(nvram get ss_dns_local_port)
ss_dns_s=$(nvram get ss_dns_remote_server)
nodesnum=$(nvram get ss_server_num_x)
dnsfsmip=$(echo "$ss_dns_s" | awk -F: '{print $1}')
dnstcpsp=$(echo "$ss_dns_s" | sed 's/:/~/g')

dnsfslsp="127.0.0.1#$ss_dns_p"
dnsgfwdt="/etc/storage/gfwlist/gfwlist_domain.txt"
dnsgfwdp="$CONF_DIR/gfwlist_domain.txt"
dnsgfwdm="$CONF_DIR/gfwlist_domain.md5"
dnsgfwdc="$CONF_DIR/gfwlist/dnsmasq.conf"
dnsmasqc="/etc/storage/dnsmasq/dnsmasq.conf"

[ "$ssp_type" = "0" ] && bin_type="SS"
[ "$ssp_type" = "1" ] && bin_type="SSR"
[ "$ssp_type" = "2" ] && bin_type="Trojan"
[ "$ssp_type" = "9" ] && bin_type="Auto"
[ "$bin_type" = "Trojan" -o "$bin_type" = "Auto" ] && [ "$(nvram get ss-tunnel_enable)" = "1" ] && nvram set ss-tunnel_enable=0
[ "$(nvram get dns_forwarder_enable)" = "1" ] && [ "$(nvram get ss-tunnel_enable)" = "1" ] && nvram set ss-tunnel_enable=0
[ ! -d "$CONF_DIR/gfwlist" ] && mkdir -p "$CONF_DIR/gfwlist" && echo "1" > $errorcount && echo "0" > $areconnect
[ -e /tmp/trojan ] && chmod +x /tmp/trojan && ssp_trojan="/tmp/trojan" || ssp_trojan="/usr/bin/trojan"
[ -e /tmp/ss-v2ray-plugin ] && chmod +x /tmp/ss-v2ray-plugin && ssp_v2rp="/tmp/ss-v2ray-plugin" || ssp_v2rp="/usr/bin/ss-v2ray-plugin"
[ -L /etc/storage/chinadns/chnroute.txt ] && [ ! -e /tmp/chnroute.txt ] && \
rm -rf /etc/storage/chinadns/chnroute.txt && tar jxf /etc_ro/chnroute.bz2 -C /etc/storage/chinadns

del_json_file()
{
logger -st "SSP[$$]$bin_type" "清除配置文件"
rm -rf $CONF_DIR/*.json
rm -rf $CONF_DIR/*-jsonlist
rm -rf $CONF_DIR/Nodes-list
rm -rf $CONF_DIR/Nodes-list.md5
return 0
}

turn_json_file()
{
[ -e "$CONF_DIR/Nodes-list.md5" ] && rm -rf $CONF_DIR/Nodes-list && for i in $(seq 1 $nodesnum); do
  j=$(expr $i - 1)
  node_type=$(nvram get ss_server_type_x$j)      # 0  1   2
  server_addr=$(nvram get ss_server_addr_x$j)    # SS SSR Trojan
  server_port=$(nvram get ss_server_port_x$j)    # SS SSR Trojan
  server_key=$(nvram get ss_server_key_x$j)      # SS SSR Trojan
  server_sni=$(nvram get ss_server_sni_x$j)      # SS     Trojan
  ss_method=$(nvram get ss_method_x$j)           # SS SSR
  ss_protocol=$(nvram get ss_protocol_x$j)       #    SSR
  ss_proto_param=$(nvram get ss_proto_param_x$j) #    SSR
  ss_obfs=$(nvram get ss_obfs_x$j)               # SS SSR
  ss_obfs_param=$(nvram get ss_obfs_param_x$j)   # SS SSR
  echo "$i#$node_type#$server_addr#$server_port#$server_key#$server_sni#$ss_method#$ss_protocol#$ss_proto_param#$ss_obfs#$ss_obfs_param" >> $CONF_DIR/Nodes-list
done && md5sum -c -s $CONF_DIR/Nodes-list.md5 || return 1
[ "$(cat $CONF_DIR/$bin_type-jsonlist 2>/dev/null | wc -l)" != "1" ] || return 0
[ "$(tail -n 1 $areconnect 2>/dev/null)" = "1" ] || return 0
logger -st "SSP[$$]$bin_type" "更换配置文件"
turn_temp=$(tail -n 1 $CONF_DIR/$bin_type-jsonlist)
turn_json=${turn_temp:0}
sed -i '/'$turn_json'/d' $CONF_DIR/$bin_type-jsonlist
sed -i '1i\'$turn_json'' $CONF_DIR/$bin_type-jsonlist
return 0
}

gen_json_file()
{
[ $nodesnum -ge 1 ] || stop_ssp "请到[节点设置]添加服务器"
turn_json_file || del_json_file
[ "$autorec" = "1" ] && echo "1" > $areconnect || echo "0" > $areconnect
if [ ! -e "$CONF_DIR/Nodes-list.md5" ]; then
  logger -st "SSP[$$]$bin_type" "创建配置文件"
  for i in $(seq 1 $nodesnum); do
    j=$(expr $i - 1)
    node_type=$(nvram get ss_server_type_x$j)      # 0  1   2
    server_addr=$(nvram get ss_server_addr_x$j)    # SS SSR Trojan
    server_port=$(nvram get ss_server_port_x$j)    # SS SSR Trojan
    server_key=$(nvram get ss_server_key_x$j)      # SS SSR Trojan
    server_sni=$(nvram get ss_server_sni_x$j)      # SS     Trojan
    ss_method=$(nvram get ss_method_x$j)           # SS SSR
    ss_protocol=$(nvram get ss_protocol_x$j)       #    SSR
    ss_proto_param=$(nvram get ss_proto_param_x$j) #    SSR
    ss_obfs=$(nvram get ss_obfs_x$j)               # SS SSR
    ss_obfs_param=$(nvram get ss_obfs_param_x$j)   # SS SSR
    echo "$i#$node_type#$server_addr#$server_port#$server_key#$server_sni#$ss_method#$ss_protocol#$ss_proto_param#$ss_obfs#$ss_obfs_param" >> $CONF_DIR/Nodes-list
    [ "$node_type" = "0" ] && server_type="SS"
    [ "$node_type" = "1" ] && server_type="SSR"
    [ "$node_type" = "2" ] && server_type="Trojan"
    if [ "$server_type" = "SS" ]; then
      if [ "$ss_obfs" = "v2ray_plugin_websocket" ] && [ "$server_sni" == "" ]; then
        ss_pm="v2rp-HTTP" && ss_plugin="$v2rp_bin" && ss_plugin_opts=""
      elif [ "$ss_obfs" = "v2ray_plugin_websocket" ] && [ "$server_sni" != "" ]; then
        ss_pm="v2rp-TLS" && ss_plugin="$v2rp_bin" && ss_plugin_opts="tls;host=$server_sni"
      elif [ "$ss_obfs" = "v2ray_plugin_quic" ] && [ "$server_sni" != "" ]; then
        ss_pm="v2rp-QUIC" && ss_plugin="$v2rp_bin" && ss_plugin_opts="mode=quic;host=$server_sni"
      else
        ss_pm="null" && ss_plugin="" && ss_plugin_opts=""
      fi
      r_json_file="$i-$server_type-redir.json"
      [ "$ss_pm" != "v2rp-QUIC" ] && t_json_file="$i-$server_type-tunnel.json" || t_json_file="null"
      echo "$server_addr#$server_port#$r_json_file#$t_json_file#$ss_pm" >> $CONF_DIR/SS-jsonlist
      echo "$server_addr#$server_port#$r_json_file#$t_json_file#$ss_pm" >> $CONF_DIR/Auto-jsonlist
	    cat > "$CONF_DIR/$r_json_file" << EOF
{
    "server": "$server_addr",
    "server_port": $server_port,
    "password": "$server_key",
    "method": "$ss_method",
    "plugin": "$ss_plugin",
    "plugin_opts": "$ss_plugin_opts",
    "plugin_args": "$ss_obfs_param",
    "timeout": $ss_timeout,
    "local_address": "0.0.0.0",
    "local_port": $ss_local_port,
    "mtu": $ss_mtu
}

EOF
      [ "$ss_pm" != "v2rp-QUIC" ] && cat > "$CONF_DIR/$t_json_file" << EOF
{
    "server": "$server_addr",
    "server_port": $server_port,
    "password": "$server_key",
    "method": "$ss_method",
    "plugin": "$ss_plugin",
    "plugin_opts": "$ss_plugin_opts",
    "plugin_args": "$ss_obfs_param",
    "timeout": $ss_timeout,
    "local_address": "0.0.0.0",
    "local_port": $ss_dns_p,
    "mtu": $ss_tunnel_mtu
}

EOF
    elif [ "$server_type" = "SSR" ]; then
      r_json_file="$i-$server_type-redir.json"
      t_json_file="$i-$server_type-tunnel.json"
      echo "$server_addr#$server_port#$r_json_file#$t_json_file#null" >> $CONF_DIR/SSR-jsonlist
      echo "$server_addr#$server_port#$r_json_file#$t_json_file#null" >> $CONF_DIR/Auto-jsonlist
	    cat > "$CONF_DIR/$r_json_file" << EOF
{
    "server": "$server_addr",
    "server_port": $server_port,
    "password": "$server_key",
    "method": "$ss_method",
    "timeout": $ss_timeout,
    "protocol": "$ss_protocol",
    "protocol_param": "$ss_proto_param",
    "obfs": "$ss_obfs",
    "obfs_param": "$ss_obfs_param",
    "local_address": "0.0.0.0",
    "local_port": $ss_local_port,
    "mtu": $ss_mtu
}

EOF
      cat > "$CONF_DIR/$t_json_file" <<EOF
{
    "server": "$server_addr",
    "server_port": $server_port,
    "password": "$server_key",
    "method": "$ss_method",
    "timeout": $ss_timeout,
    "protocol": "$ss_protocol",
    "protocol_param": "$ss_proto_param",
    "obfs": "$ss_obfs",
    "obfs_param": "$ss_obfs_param",
    "local_address": "0.0.0.0",
    "local_port": $ss_dns_p,
    "mtu": $ss_tunnel_mtu
}

EOF
    elif [ "$server_type" = "Trojan" ]; then
      if [ "$server_sni" = "" ]; then
        verifyhostname="false"
      else
        verifyhostname="true"
      fi
      r_json_file="$i-$server_type-redir.json"
      echo "$server_addr#$server_port#$r_json_file#null#null" >> $CONF_DIR/Trojan-jsonlist
      echo "$server_addr#$server_port#$r_json_file#null#null" >> $CONF_DIR/Auto-jsonlist
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
        "verify": false,
        "verify_hostname": $verifyhostname,
        "sni": "$server_sni"
    }
}

EOF
    fi
  done
  md5sum $CONF_DIR/Nodes-list > $CONF_DIR/Nodes-list.md5
fi
[ "$bin_type" = "Auto" ] || \
$(cat $CONF_DIR/$bin_type-jsonlist 2>/dev/null | grep -q "$bin_type-redir") || \
stop_ssp "请到[节点设置]添加 $bin_type 服务器"
ssp_server_addr=$(tail -n 1 $CONF_DIR/$bin_type-jsonlist | awk -F# '{print $1}')
ssp_server_port=$(tail -n 1 $CONF_DIR/$bin_type-jsonlist | awk -F# '{print $2}')
redir_json_file=$(tail -n 1 $CONF_DIR/$bin_type-jsonlist | awk -F# '{print $3}')
tunnel_json_file=$(tail -n 1 $CONF_DIR/$bin_type-jsonlist | awk -F# '{print $4}')
ssp_plugin_mode=$(tail -n 1 $CONF_DIR/$bin_type-jsonlist | awk -F# '{print $5}')
ssp_server_type=$(echo "$redir_json_file" | awk -F- '{print $2}')
if [ "$ssp_server_type" = "SS" ]; then
  if [ "$ssp_plugin_mode" != "null" ]; then
    [ -x "$ssp_v2rp" ] && ln -sf $ssp_v2rp $v2rp_link || stop_ssp "请上传 ss-v2ray-plugin 文件到 /tmp/"
  fi
  if [ "$ssp_plugin_mode" = "v2rp-QUIC" ]; then
    [ "$(nvram get ss-tunnel_enable)" = "1" ] && nvram set ss-tunnel_enable=0
    [ "$(nvram get ss_udp)" = "1" ] && nvram set ss_udp=0
  else
    ln -sf $ss_tunnel_bin $tunnel_link
  fi
  ln -sf $ss_redir_bin $redir_link
elif [ "$ssp_server_type" = "SSR" ]; then
  ln -sf $ssr_redir_bin $redir_link && ln -sf $ssr_tunnel_bin $tunnel_link
elif [ "$ssp_server_type" = "Trojan" ]; then
  [ -x "$ssp_trojan" ] && ln -sf $ssp_trojan $redir_link || stop_ssp "请上传 trojan 文件到 /tmp/"
fi
[ -n "$ssp_server_type" ] && [ -n "$ssp_server_addr" ] && [ -n "$ssp_server_port" ] && \
[ -n "$redir_json_file" ] && return 0 || return 1
}

custom_gfwlist()
{
gfwdnum=$(cat $dnsgfwdt | grep -v '^\.' | wc -l)
gfwfnum=${gfwdnum:0}
cp -rf $dnsgfwdt $dnsgfwdp
md5sum $dnsgfwdp > $dnsgfwdm
sed -i '/^\./d' $dnsgfwdp
for addgfw in $(nvram get ss_custom_gfwlist); do
  [ "$addgfw" != "" ] && $(echo $addgfw | grep -v -q '^\.') && echo ".$addgfw" >> $dnsgfwdp
done
md5sum -c -s $dnsgfwdm
[ "$?" != "0" ] && rm -rf $dnsgfwdt && cp -rf $dnsgfwdp $dnsgfwdt
rm -rf $dnsgfwdp && rm -rf $dnsgfwdm
if [ $(cat $dnsgfwdt | wc -l) -ge $gfwfnum ]; then
  return 0
else
  logger -st "SSP[$$]WARNING" "自定义黑名单域名发生错误!恢复默认黑名单域名"
  rm -rf $dnsgfwdt && tar jxf /etc_ro/gfwlist.bz2 -C /etc/storage/gfwlist
  return 1
fi
}

del_dns_conf()
{
logger -st "SSP[$$]$bin_type" "清除解析规则"
sed -i 's/^### gfwlist related.*/### gfwlist related resolve/g' $dnsmasqc
sed -i 's/^min-cache-ttl=/#min-cache-ttl=/g' $dnsmasqc
sed -i 's/^conf-dir=/#conf-dir=/g' $dnsmasqc
sed -i 's:^gfwlist='$dnsgfwdt':#gfwlist='$dnsgfwdt':g' $dnsmasqc
rm -rf $dnsgfwdc
killall -q -9 dns-forwarder
killall -q -9 $tunnel_bin
restart_dhcpd
}

get_dns_conf()
{
custom_gfwlist
[ "$1" != "dnsmasq-tcp" ] && grep -v '^#' $dnsgfwdt | grep -v '^$' | awk '{printf("server=/%s/'$dnsfslsp'\n", $1, $1 )}' >> $dnsgfwdc
[ "$1" != "dnsmasq-tcp" ] && grep -v '^#' $dnsgfwdt | grep -v '^$' | awk '{printf("ipset=/%s/gfwlist\n", $1, $1 )}' >> $dnsgfwdc
sed -i 's/^### gfwlist related.*/### gfwlist related resolve by '$1' '$2'/g' $dnsmasqc
sed -i 's/^#min-cache-ttl=/min-cache-ttl=/g' $dnsmasqc
[ "$1" != "dnsmasq-tcp" ] && sed -i 's/^#conf-dir=/conf-dir=/g' $dnsmasqc
[ "$1" == "dnsmasq-tcp" ] && sed -i 's:^#gfwlist='$dnsgfwdt'.*:gfwlist='$dnsgfwdt'@'$dnstcpsp':g' $dnsmasqc
return 0
}

gen_dns_conf()
{
logger -st "SSP[$$]$bin_type" "创建解析规则"
if [ "$(nvram get dns_forwarder_enable)" = "1" ]; then
  get_dns_conf dns-forwarder "$dnsfslsp"
  start-stop-daemon -S -b -x dns-forwarder -- -b "0.0.0.0" -p "$ss_dns_p" -s "$ss_dns_s"
elif [ "$(nvram get ss-tunnel_enable)" = "1" ]; then
  get_dns_conf ss-tunnel "$dnsfslsp"
  sh -c "$tunnel_bin -u -c $CONF_DIR/$tunnel_json_file -L $ss_dns_s &"
else
  get_dns_conf dnsmasq-tcp "$dnstcpsp"
fi
restart_dhcpd
}

gfw_list()
{
if [ "$ss_mode" = "0" ]; then # global
  echo ""
elif [ "$ss_mode" = "1" ]; then # chnroute
  echo " -g $CONF_DIR/GFWblackip.conf"
elif [ "$ss_mode" = "2" ]; then # gfwlist
  echo " -g $CONF_DIR/GFWblackip.conf"
fi
}

chn_list()
{
if [ "$ss_mode" = "0" ]; then # global
  echo ""
elif [ "$ss_mode" = "1" ]; then # chnroute
  echo " -c /etc/storage/chinadns/chnroute.txt"
elif [ "$ss_mode" = "2" ]; then # gfwlist
  echo " -c /etc/storage/chinadns/chnroute.txt"
fi
}

chnexp_list()
{
if [ "$ss_mode" = "0" ]; then # global
  echo ""
elif [ "$ss_mode" = "1" ]; then # chnroute
  echo " -e $CONF_DIR/CHNwhiteip.conf"
elif [ "$ss_mode" = "2" ]; then # gfwlist
  echo " -e $CONF_DIR/CHNwhiteip.conf"
fi
}

black_ip()
{
echo " -b $dnsfsmip"
}

white_ip()
{
addchn=$(nvram get ss_custom_chnroute | sed 's/[[:space:]]/,/g')
[ "$addchn" != "" ] && echo " -w $addchn" || echo ""
}

agent_mode()
{
if [ "$ss_mode" = "0" ]; then # global
  echo " -a 0"
elif [ "$ss_mode" = "1" ]; then # chnroute
  echo " -a 1"
elif [ "$ss_mode" = "2" ]; then # gfwlist
  echo " -a 2"
fi
}

agent_pact()
{
if [ "$(nvram get ss_udp)" = "1" ]; then
  echo " -m"
else
  echo " -t"
fi
}

udp_ext()
{
if [ "$(nvram get ss_udp)" = "1" ] && [ "$ssp_server_type" = "SS" -o "$ssp_server_type" = "SSR" ]; then
  echo " -u"
else
  echo ""
fi
}

stop_rules()
{
killall -q -9 ss-rules
logger -st "SSP[$$]$bin_type" "关闭透明代理" && ss-rules -f && \
!(iptables-save | grep -q "SSP_") && !(ipset list -n | grep -q 'private') && \
!(ipset list -n | grep -q 'gfwlist') && !(ipset list -n | grep -q 'chnlist') && \
logger -st "SSP[$$]$bin_type" "透明代理已经关闭"
}

start_rules()
{
logger -st "SSP[$$]$bin_type" "开启透明代理"
ss-rules\
 -s $(tail -n 1 $CONF_DIR/$bin_type-jsonlist | awk -F# '{print $1}')\
 -i "$ss_local_port"\
$(gfw_list)\
$(chn_list)\
$(chnexp_list)\
$(black_ip)\
$(white_ip)\
$(agent_mode)\
$(agent_pact)
}

stop_redir()
{
(killall -q -9 $redir_bin && logger -st "SSP[$$]$bin_type" "关闭代理进程" && sleep 1 && \
!(pidof $redir_bin &>/dev/null) && logger -st "SSP[$$]$bin_type" "代理进程已经关闭")&
(killall -q -9 $v2rp_bin && logger -st "SSP[$$]$bin_type" "关闭插件进程" && sleep 1 && \
!(pidof $v2rp_bin &>/dev/null) && logger -st "SSP[$$]$bin_type" "插件进程已经关闭")&
wait
return 0
}

start_redir()
{
cat > "$quickstart" << EOF
#!/bin/sh

nohup $redir_bin -c "$CONF_DIR/$redir_json_file"$(udp_ext) &>$redir_log_file &
EOF
chmod +x $quickstart
logger -st "SSP[$$]$bin_type" "启动代理进程" && \
nohup $redir_bin -c "$CONF_DIR/$redir_json_file"$(udp_ext) &>$redir_log_file &
$(sleep 1 && pidof $redir_bin &>/dev/null) || $(sleep 1 && pidof $redir_bin &>/dev/null)
[ "$?" = "1" ] && echo "1" > $areconnect && return 1 || return 0
}

stop_watchcat()
{
sed -i '/ss-watchcat.sh/d' $CRON_CONF && restart_crond
echo "daten_stopwatchcat" > $statusfile && sleep 2 && logger -st "SSP[$$]$bin_type" "关闭地址集合自动配置"
killall -q -9 ss-watchcat.sh
rm -rf $statusfile
rm -rf $netdpcount
rm -rf $errorcount
rm -rf $issjfinfor
return 0
}

ncron()
{
!(cat "$CRON_CONF" 2>/dev/null | grep -q "ss-watchcat.sh") && \
sed -i '/ss-watchcat.sh/d' $CRON_CONF && \
echo "*/$1 * * * * nice -n -9 nohup /usr/bin/ss-watchcat.sh 2>/dev/null &" >> $CRON_CONF || return 1
}

dcron()
{
$(cat "$CRON_CONF" 2>/dev/null | grep "ss-watchcat.sh" | grep -v -q "/$1") && \
sed -i '/ss-watchcat.sh/d' $CRON_CONF && \
echo "*/$1 * * * * nice -n -9 nohup /usr/bin/ss-watchcat.sh 2>/dev/null &" >> $CRON_CONF || return 1
}

scron()
{
ncron $1 || dcron $1
[ "$?" = "0" ] && restart_crond
return 0
}

stop_ssp()
{
$([ "$ss_enable" = "0" ] && stop_watchcat) || \
$(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_stop_ssp') || stop_watchcat
del_dns_conf
if [ "$ss_enable" = "0" ]; then
  stop_rules
  del_json_file
  custom_gfwlist
  rm -rf $areconnect
fi
stop_redir
if [ -e "$CONF_DIR/amsallexp.set" ] || [ -e "$CONF_DIR/amsallexp.txt" ]; then
  cat $CONF_DIR/amsallexp.set $CONF_DIR/amsallexp.txt 2>/dev/null | sort -u >> $CONF_DIR/amsallexp.tmp && \
  rm -rf $CONF_DIR/amsallexp.set && rm -rf $CONF_DIR/amsallexp.txt && \
  mv -f $CONF_DIR/amsallexp.tmp $CONF_DIR/amsallexp.txt
fi
rm -rf $quickstart
[ -n "$1" ] && logger -st "SSP[$$]WARNING" "$1"
return 0
}

start_ssp()
{
ulimit -n 65536
[ $(tail -n +1 "$errorcount" 2>/dev/null) -ge 1 ] && scron 1 && exit 0
$(cat "$statusfile" 2>/dev/null | grep -q 'watchcat_start_ssp') || stop_watchcat
logger -st "SSP[$$]$bin_type" "开始启动" && gen_json_file || $(echo "1" > $errorcount && logger -st "SSP[$$]WARNING" "创建配置文件出错")
start_redir || $(echo "1" > $errorcount && logger -st "SSP[$$]WARNING" "启动代理进程出错")
start_rules || $(echo "1" > $errorcount && logger -st "SSP[$$]WARNING" "开启透明代理出错")
gen_dns_conf || $(echo "1" > $errorcount && logger -st "SSP[$$]WARNING" "创建解析规则出错")
echo "$ssp_server_type──$ssp_server_addr:$ssp_server_port──[$redir_json_file]" > $issjfinfor
[ $(tail -n +1 "$errorcount" 2>/dev/null) -ge 1 ] && scron 1 && exit 0
sleep 1 && pidof ss-watchcat.sh &>/dev/null && STA_LOG="重启完成" || /usr/bin/ss-watchcat.sh
logger -st "SSP[$(pidof $redir_bin)]$ssp_server_type" "$ssp_server_addr:$ssp_server_port [$redir_json_file] ${STA_LOG:=成功启动}" && scron 1
echo "1" > $netdpcount
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
  del_dns_conf
  gen_dns_conf
  ;;
*)
  echo "Usage: $0 { stop | start | restart | rednsconf }"
  exit 1
  ;;
esac
