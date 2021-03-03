#!/bin/bash
#

mkdir /playbooks && \
cd /playbooks && \
git clone https://github.com/mminichino/ansible-playbooks . && \
[ ! -d /playbooks/group_vars/all ] && mkdir -p /playbooks/group_vars/all
