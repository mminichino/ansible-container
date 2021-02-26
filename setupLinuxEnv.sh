#!/bin/bash
#

dnf -y install epel-release && \
dnf -y install sshpass openssh-clients sudo which openssl && \
dnf -y install ansible && \
dnf -y install python3-pip git && \
pip3 install --upgrade pip && \
pip3 install netapp-lib && \
ansible-galaxy collection install netapp.ontap && \
ansible-galaxy collection install netapp.storagegrid && \
ansible-galaxy collection install netapp.elementsw && \
ansible-galaxy collection install netapp.aws && \
ansible-galaxy collection install netapp.azure && \
alternatives --set python /usr/bin/python3
