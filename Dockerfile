FROM kalilinux/kali-rolling
LABEL org.opencontainers.image.authors="pvn@novarese.net"
ENV LANG en_US.UTF-8
RUN apt-get update && \
	echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/force-unsafe-io && \
	apt-get dist-upgrade -y && \
	apt-get install locales -y && \
	echo "${LANG}" | tr '.' ' ' > /etc/locale.gen && locale-gen && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata && \
	apt-get install debconf-utils -y && \
	echo "locales locales/default_environment_locale select ${LANG}" | debconf-set-selections && \
	echo "locales locales/locales_to_be_generated multiselect ${LANG} UTF-8" | debconf-set-selections && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y locales && \
	apt-get install net-tools screen tmux nano vim psmisc file bzip2 dns-root-data man-db xz-utils procps zsh python3 perl rfkill iw nftables iptables -y --no-install-recommends && \
	rm -rf /etc/dpkg/dpkg.cfg.d/force-unsafe-io

RUN apt-get install adduser -y --no-install-recommends && \
	echo "wireshark-common	wireshark-common/install-setuid	boolean boolean false" | debconf-set-selections && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tshark && \
        apt-get install -y --no-install-recommends ca-certificates unzip wget aircrack-ng iw iproute2 libpcap0.8t64 kmod macchanger reaver bully john cowpatty hcxdumptool hcxtools pixiewps rfkill pciutils usbutils $([ "$(uname -m)" != "armv7l" ] && echo hashcat-utils hashcat pocl-opencl-icd) && \
        wget -nv "https://github.com/kimocoder/wifite2/archive/refs/heads/master.zip" -O /wifite2.zip && \
        wget -nv "https://github.com/vanhoefm/ath_masker/archive/refs/heads/master.zip" -O /root/ath_masker.zip && \
        unzip -d / /wifite2.zip && rm /wifite2.zip && mv /wifite2-master /wifite2 && \
        unzip -d /root/ /root/ath_masker.zip && rm /root/ath_masker.zip && mv /root/ath_masker-master /root/ath_masker && \
        grep -v setuptools /wifite2/requirements.txt > reqs.txt && mv reqs.txt /wifite2/requirements.txt && \
        apt-get purge unzip debconf-utils -y

WORKDIR /wifite2
RUN  apt-get install python3-pip python3-setuptools ca-certificates -y --no-install-recommends && \
        pip3 install --no-cache-dir --break-system-packages -r /wifite2/requirements.txt  && \
        python3 /wifite2/setup.py install && \
        apt-get purge python3-pip ca-certificates -y && \
        apt-get install python3-pkg-resources -y --no-install-recommends && \
        apt-get autoclean && \
        apt-get autoremove -y && \
    	rm -rf /var/lib/dpkg/status-old /var/lib/apt/lists/*

CMD [ "/bin/bash" ]
