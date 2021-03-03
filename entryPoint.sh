#!/bin/sh
#
/usr/bin/ansible --version

echo ""
echo "Welcome to the NetApp Ansible Sample Library Container"
echo "Please take a moment to answer some simple setup questions"
echo ""

if [ -x /tools/addAdminAccounts.sh ]; then
   /tools/addAdminAccounts.sh -i
else
  echo "Warning: can not execute account add script."
fi

if [ -x /tools/addHost.sh ]; then
   /tools/addHost.sh -p
else
   echo "Warning: can not execute host add script."
fi

echo ""
exec /bin/bash
