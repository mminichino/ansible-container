#!/bin/bash
#
TEMP=$(mktemp)
ADMIN_USER=0
ONTAP_USER=0
HOST_USER=0
ACTION=0

function err_exit {
    if [ -z "$1" ]; then
       echo "Usage: $0 -a | -o | -h"
    else
       echo "$1"
    fi
    exit 1
}

cd /playbooks || err_exit "Can not change directories to /playbooks"

if [ ! -f $TEMP ]; then
   echo "Can not create temp file."
   exit 1
fi

while getopts "aoh" opt
do
  case $opt in
    a)
      ADMIN_USER=1
      ACTION=1
      echo -n "Admin Username: "
      read ADMIN_USERNAME
      echo -n "Admin Password: "
      read -s PASSWORD
      echo ""
      echo -n "Retype Password: "
      read -s CHECK_PASSWORD
      echo ""

      if [ "$PASSWORD" != "$CHECK_PASSWORD" ]; then
         echo "Passwords do not match"
         exit 1
      fi

      ADMIN_PASSWORD=$PASSWORD
      ;;
    o)
      ONTAP_USER=1
      ACTION=1
      echo -n "ONTAP Username: "
      read ONTAP_USERNAME
      echo -n "ONTAP Password: "
      read -s PASSWORD
      echo ""
      echo -n "Retype Password: "
      read -s CHECK_PASSWORD
      echo ""

      if [ "$PASSWORD" != "$CHECK_PASSWORD" ]; then
         echo "Passwords do not match"
         exit 1
      fi

      ONTAP_PASSWORD=$PASSWORD
      ;;
    h)
      HOST_USER=1
      ACTION=1
      echo -n "Host Username: "
      read HOST_USERNAME
      echo -n "Host Password: "
      read -s PASSWORD
      echo ""
      echo -n "Retype Password: "
      read -s CHECK_PASSWORD
      echo ""

      if [ "$PASSWORD" != "$CHECK_PASSWORD" ]; then
         echo "Passwords do not match"
         exit 1
      fi

      HOST_PASSWORD=$PASSWORD
      ;;
    \?)
      err_exit
      ;;
  esac
done

[ $ACTION -eq 0 ] && exit 0

if [ -f group_vars/all/vault.yaml ]; then
   ansible-vault view group_vars/all/vault.yaml 2>&1 > /dev/null
   if [ $? -eq 0 ]; then
      ansible-vault decrypt group_vars/all/vault.yaml
   fi
else
   echo "# Ansible Vault File" > group_vars/all/vault.yaml
fi

if [ $ADMIN_USER -eq 1 ]; then
   sed '/^admin_user:/d' group_vars/all/vault.yaml > $TEMP && cp $TEMP group_vars/all/vault.yaml
   sed '/^admin_password:/d' group_vars/all/vault.yaml > $TEMP && cp $TEMP group_vars/all/vault.yaml
   echo "admin_user: $ADMIN_USERNAME" >> group_vars/all/vault.yaml
   echo "admin_password: $ADMIN_PASSWORD" >> group_vars/all/vault.yaml
fi

if [ $ONTAP_USER -eq 1 ]; then
   sed '/^ontap_user:/d' group_vars/all/vault.yaml > $TEMP && cp $TEMP group_vars/all/vault.yaml
   sed '/^ontap_password:/d' group_vars/all/vault.yaml > $TEMP && cp $TEMP group_vars/all/vault.yaml
   echo "ontap_user: $ONTAP_USERNAME" >> group_vars/all/vault.yaml
   echo "ontap_password: $ONTAP_PASSWORD" >> group_vars/all/vault.yaml
fi

if [ $HOST_USER -eq 1 ]; then
   sed '/^host_user:/d' group_vars/all/vault.yaml > $TEMP && cp $TEMP group_vars/all/vault.yaml
   sed '/^host_password:/d' group_vars/all/vault.yaml > $TEMP && cp $TEMP group_vars/all/vault.yaml
   echo "host_user: $HOST_USERNAME" >> group_vars/all/vault.yaml
   echo "host_password: $HOST_PASSWORD" >> group_vars/all/vault.yaml
fi

ansible-vault encrypt group_vars/all/vault.yaml