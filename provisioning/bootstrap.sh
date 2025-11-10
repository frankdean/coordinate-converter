#!/usr/bin/env bash

# Uncomment the following to debug the script
#set -x

# This is the folder where the source code is available in the VM
COORD_SOURCE=${COORD_SOURCE:-/vagrant}
# The user and group name for building Trip Server
USERNAME=${USERNAME:-vagrant}
GROUPNAME=${GROUPNAME:-${USERNAME}}
USERHOME=${USERHOME:-"/home/${USERNAME}"}
PROCESSOR="$(uname -p)"
ARCH="$(arch)"
echo $ARCH

# https://nodejs.org/dist/latest-v22.x/SHASUMS256.txt
NODE_VERSION="v22.21.0"
if [ "$PROCESSOR" != "unknown" ]; then
    NODE_ARCH=x64
    NODE_SHA256=262b84b02f7e2bc017d4bdb81fec85ca0d6190a5cd0781d2d6e84317c08871f8
elif [ "$ARCH" == "aarch64" ]; then
    NODE_ARCH=arm64
    NODE_SHA256=5180e74f2cdea6142548bd827249da32c0e86ba2581d6241e2f2761f957b9ed1
else
    NODE_SHA256=262b84b02f7e2bc017d4bdb81fec85ca0d6190a5cd0781d2d6e84317c08871f8
    NODE_ARCH=x64
fi
NODE_FILENAME="node-${NODE_VERSION}-linux-${NODE_ARCH}"
NODE_TAR_FILENAME="${NODE_FILENAME}.tar.gz"
NODE_EXTRACT_DIR="${NODE_FILENAME}"
NODE_DOWNLOAD_URL="https://nodejs.org/dist/${NODE_VERSION}/${NODE_TAR_FILENAME}"
DOWNLOAD_CACHE_DIR="${COORD_SOURCE}/provisioning/downloads"

echo "Source folder: ${COORD_SOURCE}"
echo "Username: ${USERNAME}"
echo "Groupname: ${USERNAME}:${GROUPNAME}"

SU_CMD="su $USERNAME -c"

function install_nodejs
{
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
	    tar --no-same-owner --no-same-permissions --gunzip \
		-xf "${DOWNLOAD_CACHE_DIR}/${NODE_TAR_FILENAME}" \
		-C /usr/local/lib/nodejs
	    if [ -L /usr/local/lib/nodejs/node-current ]; then
		rm -f /usr/local/lib/nodejs/node-current
	    fi
	    ln -sf "/usr/local/lib/nodejs/${NODE_EXTRACT_DIR}" /usr/local/lib/nodejs/node-current
	    if [ -e ${COORD_SOURCE}/node_modules ]; then
		cd ${COORD_SOURCE}
		rm -rf node_modules
	    fi
	fi
    fi
    egrep '^export\s+PATH.*nodejs' ${USERHOME}/.profile >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	echo "export PATH=/usr/local/lib/nodejs/node-current/bin:$PATH" >>${USERHOME}/.profile
    fi
    # if [ -x /usr/local/lib/nodejs/node-current/bin/node ] && \
    # 	   [ ! -x /usr/local/lib/nodejs/node-current/lib/node_modules/yarn/bin/yarn ]; then
    # 	PATH="/usr/local/lib/nodejs/node-current/bin:$PATH" \
    # 	    /usr/local/lib/nodejs/node-current/lib/node_modules/npm/bin/npm-cli.js \
    # 	    install -g yarn
    # fi

    # Upgrade npm to latest available version
    if [ -x /usr/local/lib/nodejs/node-current/bin/node ]; then
	PATH="/usr/local/lib/nodejs/node-current/bin:$PATH" \
	    /usr/local/lib/nodejs/node-current/lib/node_modules/npm/bin/npm-cli.js \
	    install -g npm
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

    # apt-get install $DEB_OPTIONS nodejs npm
fi

install_nodejs
