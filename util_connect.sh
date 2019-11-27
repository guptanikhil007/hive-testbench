#!/bin/bash

# Connects the headnode to worker nodes without needing password to ssh

which sshpass &> /dev/null || sudo apt-get -y -qq install sshpass
which pdsh &> /dev/null || sudo apt-get -y -qq install pdsh

# Here we check if a keypair already exists in the default location. If not, we create one.
if [[ ! -e ~/.ssh/id_rsa ]]; then
    echo "Generating keys\n"
    ssh-keygen -f ~/.ssh/id_rsa -P ""
fi

for slave in `cat /etc/hadoop/conf/slaves`; do
    #echo "ssh-copy-id on $slave"
    sshpass -p Deploy@321 ssh-copy-id -o StrictHostKeyChecking=no $slave
done

pdsh -R ssh -w ^/etc/hadoop/conf/slaves sudo apt-get -y -qq install linux-tools-common sysstat gawk
