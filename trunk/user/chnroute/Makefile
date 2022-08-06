url = http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest
THISDIR = $(shell pwd)

all :
	( if [ ! -f chnroute.bz2 ];then \
		wget -t8 -4 --timeout=8 -U Mozilla -O route.txt.tmp '$(url)' && sed -i '/\*/d' route.txt.tmp && \
		awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $$4, 32-log($$5)/log(2)) }' < route.txt.tmp > chnroute.txt && \
		rm -f route.txt.tmp && \
		tar jcf chnroute.bz2 chnroute.txt ;\
	fi )

romfs:
	chmod -R +x ./scripts
	$(ROMFSINST) $(THISDIR)/scripts/ /usr/bin/
	$(ROMFSINST) -d $(THISDIR)/chnroute.bz2 /etc_ro/chnroute.bz2

clean :
	rm -f chnroute.*
