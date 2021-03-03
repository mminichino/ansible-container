#!/bin/bash
#
TEMP=$(mktemp)
ADMIN_USER=0
ONTAP_USER=0
HOST_USER=0
ACTION=0
INIT=0

function err_exit {
    if [ -z "$1" ]; then
       echo "Usage: $0 -i | -a | -o | -h"
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

while getopts "aohi" opt
do
  case $opt in
    a)
      ADMIN_USER=1
      ACTION=1
      ;;
    o)
      ONTAP_USER=1
      ACTION=1
      ;;
    h)
      HOST_USER=1
      ACTION=1
      ;;
    i)
      INIT=1
      ACTION=1
      ;;
    \?)
      err_exit
      ;;
  esac
done

[ $ACTION -eq 0 ] && exit 0

if [ "$INIT" -eq 1 ] && [ ! -f group_vars/all/vault.yaml ]; then
   echo -n "Add default accounts to vault? [y/n]: "
   read ANSWER
   if [ "$ANSWER" != "y" ]; then
      exit 0
   fi
fi

if [ -f group_vars/all/vault.yaml ]; then
   echo "Existing Vault Found"
   if [ -f .vault_password ]; then
      ansible-vault view group_vars/all/vault.yaml 2>&1 > /dev/null
      if [ $? -eq 0 ]; then
         ansible-vault decrypt group_vars/all/vault.yaml
      else
         err_exit "[!] Can not decrypt vault with saved password"
      fi
   else
      echo "Saved vault password not found"
      echo -n "Add vault password? [y/n]: "
      read ANSWER
      if [ "$ANSWER" = "y" ]; then
         while true
         do
           echo -n "Vault Password: "
           read -s PASSWORD
           echo ""
           echo -n "Retype Password: "
           read -s CHECK_PASSWORD
           echo ""
           if [ "$PASSWORD" != "$CHECK_PASSWORD" ]; then
              echo "Passwords do not match"
           else
              break
           fi
         done

         echo $PASSWORD > .vault_password
      fi
   fi
   [ "$INIT" -eq 1 ] && exit 0
else
   echo "Preparing Vault Environment"
   openssl rand -base64 32 > /playbooks/.vault_password
   echo "# Ansible Vault File" > group_vars/all/vault.yaml
fi

if [ "$INIT" -eq 1 ]; then
   echo -n "Add admin account? [y/n]: "
   read ANSWER
   if [ "$ANSWER" != "y" ]; then
      ADMIN_USER=0
   else
      ADMIN_USER=1
   fi
fi
if [ $ADMIN_USER -eq 1 ]; then
   echo -n "Admin Username: "
   read ADMIN_USERNAME

   while true
   do
     echo -n "Admin Password: "
     read -s PASSWORD
     echo ""
     echo -n "Retype Password: "
     read -s CHECK_PASSWORD
     echo ""
     if [ "$PASSWORD" != "$CHECK_PASSWORD" ]; then
        echo "Passwords do not match"
     else
        break
     fi
   done

   ADMIN_PASSWORD=$PASSWORD
   sed '/^admin_user:/d' group_vars/all/vault.yaml > $TEMP && cp $TEMP group_vars/all/vault.yaml
   sed '/^admin_password:/d' group_vars/all/vault.yaml > $TEMP && cp $TEMP group_vars/all/vault.yaml
   echo "admin_user: $ADMIN_USERNAME" >> group_vars/all/vault.yaml
   echo "admin_password: $ADMIN_PASSWORD" >> group_vars/all/vault.yaml
fi

if [ "$INIT" -eq 1 ]; then
   echo -n "Add ONTAP account? [y/n]: "
   read ANSWER
   if [ "$ANSWER" != "y" ]; then
      ONTAP_USER=0
   else
      ONTAP_USER=1
   fi
fi
if [ $ONTAP_USER -eq 1 ]; then
   echo -n "ONTAP Username: "
   read ONTAP_USERNAME

   while true
   do
     echo -n "ONTAP Password: "
     read -s PASSWORD
     echo ""
     echo -n "Retype Password: "
     read -s CHECK_PASSWORD
     echo ""
     if [ "$PASSWORD" != "$CHECK_PASSWORD" ]; then
        echo "Passwords do not match"
     else
        break
     fi
   done

   ONTAP_PASSWORD=$PASSWORD
   sed '/^ontap_user:/d' group_vars/all/vault.yaml > $TEMP && cp $TEMP group_vars/all/vault.yaml
   sed '/^ontap_password:/d' group_vars/all/vault.yaml > $TEMP && cp $TEMP group_vars/all/vault.yaml
   echo "ontap_user: $ONTAP_USERNAME" >> group_vars/all/vault.yaml
   echo "ontap_password: $ONTAP_PASSWORD" >> group_vars/all/vault.yaml
fi

if [ "$INIT" -eq 1 ]; then
   echo -n "Add host account? [y/n]: "
   read ANSWER
   if [ "$ANSWER" != "y" ]; then
      HOST_USER=0
   else
      HOST_USER=1
   fi
fi
if [ $HOST_USER -eq 1 ]; then
   echo -n "Host Username: "
   read HOST_USERNAME

   while true
   do
     echo -n "Host Password: "
     read -s PASSWORD
     echo ""
     echo -n "Retype Password: "
     read -s CHECK_PASSWORD
     echo ""
     if [ "$PASSWORD" != "$CHECK_PASSWORD" ]; then
        echo "Passwords do not match"
     else
        break
     fi
   done

   HOST_PASSWORD=$PASSWORD
   sed '/^host_user:/d' group_vars/all/vault.yaml > $TEMP && cp $TEMP group_vars/all/vault.yaml
   sed '/^host_password:/d' group_vars/all/vault.yaml > $TEMP && cp $TEMP group_vars/all/vault.yaml
   echo "host_user: $HOST_USERNAME" >> group_vars/all/vault.yaml
   echo "host_password: $HOST_PASSWORD" >> group_vars/all/vault.yaml
fi

ansible-vault encrypt group_vars/all/vault.yaml