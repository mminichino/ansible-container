#!/bin/bash
#
TEMP=$(mktemp)
PROMPT=0
GROUP="hosts"

function err_exit() {
    if [ -z "$1" ]; then
       echo "Usage: $0 [ -p ] | [ -g group ] -i IP -n hostname"
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

while getopts "i:n:g:p" opt
do
  case $opt in
    i)
      IP_ADDRESS=$OPTARG
      ;;
    n)
      HOST_NAME=$OPTARG
      ;;
    g)
      GROUP=$OPTARG
      ;;
    p)
      PROMPT=1
      ;;
    \?)
      err_exit
      ;;
  esac
done

if [ ! -f /playbooks/production ]; then
   touch /playbooks/production
else
   if [ "$PROMPT" -eq 1 ]; then
      echo "[i] Existing inventory file found"
      exit 0
   fi
fi

while true
do

if [ "$PROMPT" -eq 1 ]; then
   echo -n "Add host? [y/n]: "
   read ANSWER

   if [ "$ANSWER" = "y" ]; then
      echo -n "Host Name: "
      read HOST_NAME
      echo -n "IP Address: "
      read IP_ADDRESS
      echo -n "Group Name [hosts]: "
      read GROUP
      [ -z "$GROUP" ] && GROUP="hosts"
   else
      break
   fi
fi

if [ -z "$IP_ADDRESS" -o -z "$HOST_NAME" ]; then
   err_exit
fi

grep -Fxq "[$GROUP]" production
if [ $? -eq 1 ]; then
   echo "[$GROUP]" >> production
fi

grep -q "^$HOST_NAME" production
if [ $? -eq 0 ]; then
   echo "[!] Host $HOST_NAME already exists, skipping."
   exit 1
fi

sed "/^\[$GROUP\]/a $HOST_NAME ansible_ssh_user='{{ host_user }}' ansible_ssh_pass='{{ host_password }}' ansible_become_pass='{{ host_password }}' ansible_host=$IP_ADDRESS" production > $TEMP || err_exit "Can not add host"
cp $TEMP production || err_exit "Can not add host"

echo "[i] Host $HOST_NAME added."
[ "$PROMPT" -eq 0 ] && exit 0

done