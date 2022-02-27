#!/bin/bash

echo 'change sshd_config to allow public key authentication & relaod sshd...'
sed -i 's/\#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/\#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
#sed -i 's/\#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd