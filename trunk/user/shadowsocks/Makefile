THISDIR = $(shell pwd)

SRC_SS_NAME=shadowsocks-libev-3.3.5
#https://github.com/shadowsocks/shadowsocks-libev.git

SRC_SSR_NAME=shadowsocksr-libev-master
ARCHIVE_SSR_NAME=shadowsocksr-libev-master-e2373d7
#https://github.com/shadowsocksr-backup/shadowsocksr-libev.git

CACERT_NAME=cacert.pem
CACERT_PURL=https://curl.se/ca
CACERT_URL=$(CACERT_PURL)/$(CACERT_NAME)
CACERT_DIR=cacerts

GFWLIST_NAME=gfwlist_domain.txt
GFWLIST_PURL=https://cokebar.github.io/gfwlist2dnsmasq
GFWLIST_URL=$(GFWLIST_PURL)/$(GFWLIST_NAME)
GFWLIST_DIR=gfwlist

all: cacert_dl gfwlist_dl extract_test config_test
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS),y)
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_SSR_NAME)
endif
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_SS_NAME)

cacert_dl:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS),y)
	( if [ ! -d $(CACERT_DIR) ]; then \
		mkdir -p $(CACERT_DIR) && cd $(CACERT_DIR) && \
		wget -q -t5 --timeout=20 --no-check-certificate $(CACERT_URL) && \
		tar jcf cacerts.bz2 $(CACERT_NAME); \
	else \
		cd $(CACERT_DIR) && tar jcf cacerts.bz2 $(CACERT_NAME); \
	fi )
endif

gfwlist_dl:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS),y)
	( if [ ! -d $(GFWLIST_DIR) ]; then \
		mkdir -p $(GFWLIST_DIR) && cd $(GFWLIST_DIR) && \
		wget -q -t5 --timeout=20 --no-check-certificate $(GFWLIST_URL) && \
		tar jcf gfwlist.bz2 $(GFWLIST_NAME); \
	else \
		cd $(GFWLIST_DIR) && tar jcf gfwlist.bz2 $(GFWLIST_NAME); \
	fi )
endif

ifeq ($(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS),y)
extract_test: extract_ssr_test extract_ss_test
else
extract_test: extract_ss_test
endif

extract_ssr_test:
	( if [ ! -d $(SRC_SSR_NAME) ]; then \
		unzip -qq $(ARCHIVE_SSR_NAME).zip ; \
	fi )

extract_ss_test:
	( if [ ! -d $(SRC_SS_NAME) ]; then \
		tar xf $(SRC_SS_NAME).tar.gz ; \
	fi )

ifeq ($(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS),y)
config_test: config_ssr config_ss
else
config_test: config_ss
endif

config_ss:
	( if [ -f ./ss_config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure_ss && touch ss_config_done; \
	fi )

config_ssr:
	( if [ -f ./ssr_config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure_ssr && touch ssr_config_done; \
	fi )

configure_ssr:
	( cd $(SRC_SSR_NAME) ; \
	ac_cv_prog_PCRE_CONFIG="$(STAGEDIR)/bin/pcre-config" \
	./configure \
		--prefix=/usr \
		--disable-documentation \
		--disable-ssp \
		--disable-assert \
		--enable-system-shared-lib \
		--with-crypto-library=mbedtls \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

configure_ss:
	( cd $(SRC_SS_NAME) ; \
	ac_cv_prog_PCRE_CONFIG="$(STAGEDIR)/bin/pcre-config" \
	./configure \
		--prefix=/usr \
		--disable-documentation \
		--disable-ssp \
		--disable-assert \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean: clean_ssr clean_ss
	rm -f ssr_config_done ss_config_done
	rm -rf $(GFWLIST_DIR)

clean_ssr:
	( if [ -f $(SRC_SSR_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_SSR_NAME) clean ; \
	fi )

clean_ss:
	( if [ -f $(SRC_SS_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_SS_NAME) distclean ; \
	fi )

romfs:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS),y)
	chmod -R +x scripts/
	$(ROMFSINST) $(THISDIR)/scripts/shadowsocks.sh /usr/bin/shadowsocks.sh
	$(ROMFSINST) $(THISDIR)/scripts/ss-rules /usr/bin/ss-rules
	$(ROMFSINST) $(THISDIR)/scripts/ss-watchcat.sh /usr/bin/ss-watchcat.sh
	$(ROMFSINST) $(THISDIR)/scripts/update_gfwlist.sh /usr/bin/update_gfwlist.sh
	$(ROMFSINST) $(THISDIR)/gfwlist/gfwlist.bz2 /etc_ro/gfwlist.bz2
	$(ROMFSINST) $(THISDIR)/cacerts/cacerts.bz2 /etc_ro/cacerts.bz2
	$(ROMFSINST) -p +x $(THISDIR)/$(SRC_SSR_NAME)/src/ss-redir /usr/bin/ssr-redir
	$(ROMFSINST) -p +x $(THISDIR)/$(SRC_SSR_NAME)/src/ss-local /usr/bin/ssr-local
	$(ROMFSINST) -p +x $(THISDIR)/$(SRC_SS_NAME)/src/ss-redir /usr/bin/ss-orig-redir
	$(ROMFSINST) -p +x $(THISDIR)/$(SRC_SS_NAME)/src/ss-tunnel /usr/bin/ss-orig-tunnel
	$(ROMFSINST) -p +x $(THISDIR)/$(SRC_SS_NAME)/src/ss-local /usr/bin/ss-orig-local
	ln -sf /var/ss-redir $(ROMFSDIR)/usr/bin/ss-redir
	ln -sf /var/ss-tunnel $(ROMFSDIR)/usr/bin/ss-local
	ln -sf /var/v2ray-plugin $(ROMFSDIR)/usr/bin/v2ray-plugin
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SSSERVER),y)
	$(ROMFSINST) -p +x $(THISDIR)/$(SRC_SS_NAME)/src/ss-server /usr/bin/ss-server
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SSV2RP),y)
	$(ROMFSINST) -p +x $(THISDIR)/ss-v2ray-plugin /usr/bin/ss-v2ray-plugin
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SSVMESS),y)
	$(ROMFSINST) -p +x $(THISDIR)/v2ray /usr/bin/v2ray
endif
