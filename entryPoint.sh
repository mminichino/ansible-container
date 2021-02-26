#!/bin/sh
#
/usr/bin/ansible --version

echo ""
echo "Welcomne to the NetApp Ansible Sample Library Container"
echo "Please take a moment to answer some simple setup questions"
echo ""

if [ -x /tools/addAdminAccounts.sh ]; then
   while true; do
      /tools/addAdminAccounts.sh -a -o -h
      if [ $? -eq 0 ]; then
         break
      fi
   done
else
  echo "Warning: can not execute account add script."
fi

if [ -x /tools/addHost.sh ]; then
   while true; do

   echo -n "Add host? [y/n]: "
   read ANSWER

   if [ "$ANSWER" = "y" ]; then
      echo -n "Host Name: "
      read HOST_NAME
      echo -n "IP Address: "
      read IP_ADDRESS
      echo -n "Group Name [hosts]: "
      read GROUP_NAME
      [ -z "$GROUP_NAME" ] && GROUP_NAME="hosts"
      /tools/addHost.sh -g $GROUP_NAME -n $HOST_NAME -i $IP_ADDRESS
     if [ $? -eq 0 ]; then
        echo "[i] Host $HOST_NAME added."
     fi
   else
      break
   fi

   done
else
   echo "Warning: can not execute host add script."
fi

echo ""
exec /bin/bash
