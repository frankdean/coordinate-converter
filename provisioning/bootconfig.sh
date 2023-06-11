#!/usr/bin/env bash

# Uncomment the following to debug the script
#set -x

function setup_nginx
{
    if [ ! -e /etc/nginx/sites-available/convert-coords ]; then
	cp /vagrant/provisioning/nginx/sites-available/convert-coords /etc/nginx/sites-available
	if [ -e /etc/nginx/sites-enabled/default ]; then
	    rm -f /etc/nginx/sites-enabled/default
	fi
	ln -fs /etc/nginx/sites-available/convert-coords /etc/nginx/sites-enabled/convert-coords
	systemctl restart nginx
    fi
}

setup_nginx
su - vagrant -c 'cd /vagrant && yarn install'

egrep '^export\s+EDITOR' /home/vagrant/.profile >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "export EDITOR=/usr/bin/vi" >>/home/vagrant/.profile
fi
