#!/usr/bin/env bash

# Uncomment the following to debug the script
#set -x

# This is the folder where the source code is available in the VM
COORD_SOURCE=${COORD_SOURCE:-/vagrant}
# The user and group name for building Trip Server
USERNAME=${USERNAME:-vagrant}
GROUPNAME=${GROUPNAME:-${USERNAME}}
USERHOME=${USERHOME:-"/home/${USERNAME}"}

function setup_nginx
{
    if [ ! -e /etc/nginx/sites-available/convert-coords ]; then
	cp ${COORD_SOURCE}/provisioning/nginx/sites-available/convert-coords /etc/nginx/sites-available
	if [ "$USERNAME" != "vagrant" ]; then
	    grep -E '^\s+root /vagrant/dist;' /etc/nginx/sites-available/convert-coords
	    if [ $? -eq 0 ]; then
		sed -i "s~/vagrant/dist~${USERHOME}/convert-coord/dist~" /etc/nginx/sites-available/convert-coords
	    fi
	fi
	if [ -e /etc/nginx/sites-enabled/default ]; then
	    rm -f /etc/nginx/sites-enabled/default
	fi
	ln -fs /etc/nginx/sites-available/convert-coords /etc/nginx/sites-enabled/convert-coords
	systemctl reload nginx
    fi
}

setup_nginx
su - ${USERNAME} -c "cd ${COORD_SOURCE} && npm install"

if [ ! -f ${USERHOME}/dist/index.html ]; then
    su - ${USERNAME} -c "cd ${COORD_SOURCE} && npm run build"
fi

egrep '^export\s+EDITOR' ${USERHOME}/.profile >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "export EDITOR=/usr/bin/vi" >>${USERHOME}/.profile
fi
