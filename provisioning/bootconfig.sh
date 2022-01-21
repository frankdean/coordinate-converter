#!/usr/bin/env bash

# Uncomment the following to debug the script
#set -x

if [ "$DEV" == "y" ]; then
	egrep '^export\s+CHROME_BIN' /home/vagrant/.profile >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "export CHROME_BIN=/usr/bin/chromium" >>/home/vagrant/.profile
	fi
fi
egrep '^export\s+EDITOR' /home/vagrant/.profile >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "export EDITOR=/usr/bin/vi" >>/home/vagrant/.profile
fi
