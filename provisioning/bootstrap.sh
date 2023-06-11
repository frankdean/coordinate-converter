#!/usr/bin/env bash

# Uncomment the following to debug the script
#set -x

NODE_VERSION="v16.20.0"
NODE_SHA256=dff21020b555cc165a1ac36da7d4f6c810b35409c94e00afc51d5d370aae47ae
NODE_FILENAME="node-${NODE_VERSION}-linux-x64"
NODE_TAR_FILENAME="${NODE_FILENAME}.tar.xz"
NODE_EXTRACT_DIR="${NODE_FILENAME}"
NODE_DOWNLOAD_URL="https://nodejs.org/dist/${NODE_VERSION}/${NODE_TAR_FILENAME}"
DOWNLOAD_CACHE_DIR="/vagrant/provisioning/downloads"

SU_CMD="su vagrant -c"

function install_nodejs
{
    # https://github.com/nodejs/help/wiki/Installation
    NODE_FILENAME="node-${NODE_VERSION}-linux-x64"
    NODE_TAR_FILENAME="${NODE_FILENAME}.tar.xz"
    NODE_EXTRACT_DIR="${NODE_FILENAME}"
    NODE_DOWNLOAD_URL="https://nodejs.org/dist/${NODE_VERSION}/${NODE_TAR_FILENAME}"

    if [ ! -x "/usr/local/lib/nodejs/${NODE_EXTRACT_DIR}/bin/node" ]; then
	# Download the tarball distribution if it does not already exist
	if [ ! -e "${DOWNLOAD_CACHE_DIR}/${NODE_TAR_FILENAME}" ]; then
	    if [ ! -d ${DOWNLOAD_CACHE_DIR} ]; then
		mkdir -p ${DOWNLOAD_CACHE_DIR}
	    fi
	    curl --location --remote-name --output-dir ${DOWNLOAD_CACHE_DIR} $NODE_DOWNLOAD_URL
	fi
	if [ -e "${DOWNLOAD_CACHE_DIR}/$NODE_TAR_FILENAME" ]; then
	    echo "$NODE_SHA256  ${DOWNLOAD_CACHE_DIR}/$NODE_TAR_FILENAME" | shasum -c -
	    if [ $? -ne "0" ]; then
		>&2 echo "Checksum of downloaded file does not match expected value of ${NODE_SHA256}"
		exit 1
	    fi
	    if [ ! -d /usr/local/lib/nodejs ]; then
		mkdir -p /usr/local/lib/nodejs
	    fi
	    tar --no-same-owner --no-same-permissions --xz \
		-xf "${DOWNLOAD_CACHE_DIR}/${NODE_TAR_FILENAME}" \
		-C /usr/local/lib/nodejs
	    if [ -L /usr/local/lib/nodejs/node-current ]; then
		rm -f /usr/local/lib/nodejs/node-current
	    fi
	    ln -sf "/usr/local/lib/nodejs/${NODE_EXTRACT_DIR}" /usr/local/lib/nodejs/node-current
	    if [ -e /vagrant/node_modules ]; then
		cd /vagrant
		rm -rf node_modules
	    fi
	fi
    fi
    egrep '^export\s+PATH.*nodejs' /home/vagrant/.profile >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	echo "export PATH=/usr/local/lib/nodejs/node-current/bin:$PATH" >>/home/vagrant/.profile
    fi
    if [ -x /usr/local/lib/nodejs/node-current/bin/node ] && \
	   [ ! -x /usr/local/lib/nodejs/node-current/lib/node_modules/yarn/bin/yarn ]; then
	PATH="/usr/local/lib/nodejs/node-current/bin:$PATH" \
	    /usr/local/lib/nodejs/node-current/lib/node_modules/npm/bin/npm-cli.js \
	    install -g yarn
    fi
}

##############################################################################
#
# Debian provisioning
#
##############################################################################
if [ -f /etc/debian_version ]; then
    export DEBIAN_FRONTEND=noninteractive
    DEB_OPTIONS="--yes --allow-change-held-packages"
    apt-get update
    apt-get full-upgrade $DEB_OPTIONS

    sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    sed -i -e 's/# es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
    sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    #export LC_ALL=en_GB.utf8
    localedef -i en_GB -c -f UTF-8 -A /usr/share/locale/locale.alias en_GB.UTF-8
    # Set locale to 'none' - locale will default to that of SSH user
    update-locale LANG LANGUAGE

    ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime
    # Other time zones, useful for testing
    #ln -fs /usr/share/zoneinfo/Asia/Kolkata  /etc/localtime # UTC +05:30

    apt-get install -y tzdata
    dpkg-reconfigure tzdata

    apt-get install $DEB_OPTIONS apt-transport-https
    apt-get install $DEB_OPTIONS curl git vim screen nginx-light

    if [ ! -d /etc/apt/keyrings ]; then
	install -m 0755 -d /etc/apt/keyrings
    fi
    if [ ! -e /etc/apt/keyrings/docker.gpg ]; then
	$SU_CMD 'curl -fsSL https://download.docker.com/linux/debian/gpg' | gpg --no-tty --dearmor -o /etc/apt/keyrings/docker.gpg 2>&1 >/dev/null
	chmod a+r /etc/apt/keyrings/docker.gpg
    fi
    if [ ! -e /etc/apt/sources.list.d/docker.list ]; then
	echo \
	    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
	    tee /etc/apt/sources.list.d/docker.list > /dev/null

    fi
    apt-get update
    apt-get install $DEB_OPTIONS docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    adduser vagrant docker >/dev/null
fi

install_nodejs
