#!/bin/bash
#
TEMP=$(mktemp)
GROUP="hosts"

function err_exit() {
    if [ -z "$1" ]; then
       echo "Usage: $0 [ -g group ] -i IP -n hostname"
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

while getopts "i:n:g:" opt
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
    \?)
      err_exit
      ;;
  esac
done

if [ -z "$IP_ADDRESS" -o -z "$HOST_NAME" ]; then
   err_exit
fi

if [ ! -f /playbooks/production ]; then
   touch /playbooks/production
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

sed "/^\[$GROUP\]/a $HOST_NAME ansible_ssh_user='{{ host_user }}' ansible_ssh_pass='{{ host_password }}' ansible_become_pass='{{ host_password }}' ansible_host=$IP_ADDRESS" production > $TEMP
cp $TEMP production
