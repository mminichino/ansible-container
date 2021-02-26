#!/bin/bash
#

mkdir /playbooks && \
cd /playbooks && \
git clone https://github.com/mminichino/ansible-playbooks . && \
openssl rand -base64 32 > /playbooks/.vault_password && \
mkdir -p /playbooks/group_vars/all
