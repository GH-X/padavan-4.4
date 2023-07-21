#!/bin/sh

stop_iappd()
{
$(pidof ralinkiappd &>/dev/null) || return 1
killall -q -SIGTERM ralinkiappd
sleep 1
$(pidof ralinkiappd &>/dev/null) || return 0
killall -q -9 ralinkiappd
return 0
}

start_iappd()
{
ifconfig | grep '^ra' | awk '{print $1}' > /tmp/iappdRAUP
raupnum=$(cat /tmp/iappdRAUP | wc -l)
[ "$raupnum" == "0" ] && logger -st "iappd[$$]" "wireless network is not enabled!!!" && exit 1
cat > "/tmp/iappdRUNP" << EOF
#!/bin/sh

EOF
num=0
while read RAUP; do
  num=$((num+1))
  [ "$num" == "1" ] && echo -e "ralinkiappd -wi $RAUP\c" >> /tmp/iappdRUNP
  [ "$num" != "1" ] && echo -e " -wi $RAUP\c" >> /tmp/iappdRUNP
  [ "$num" == "$raupnum" ] && echo -e " -d 0 &\c" >> /tmp/iappdRUNP && echo "" >> /tmp/iappdRUNP
  sysctl -wq net.ipv4.neigh.$RAUP.base_reachable_time_ms=10000
  sysctl -wq net.ipv4.neigh.$RAUP.delay_first_probe_time=1
done < /tmp/iappdRAUP
sysctl -wq net.ipv4.neigh.br0.base_reachable_time_ms=10000
sysctl -wq net.ipv4.neigh.br0.delay_first_probe_time=1
sysctl -wq net.ipv4.neigh.eth2.base_reachable_time_ms=10000
sysctl -wq net.ipv4.neigh.eth2.delay_first_probe_time=1
iptables -A INPUT -i br0 -p tcp --dport 3517 -j ACCEPT
iptables -A INPUT -i br0 -p udp --dport 3517 -j ACCEPT 
chmod +x /tmp/iappdRUNP && /tmp/iappdRUNP
rm -rf /tmp/iappdRAUP
rm -rf /tmp/iappdRUNP
}

case "$1" in
stop)
  stop_iappd
  ;;
start)
  start_iappd
  ;;
restart)
  stop_iappd
  start_iappd
  ;;
*)
  echo "Usage: $0 {stop|start|restart}"
  exit 1
  ;;
esac
