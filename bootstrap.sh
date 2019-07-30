#!/bin/bash

DATE=`date '+%Y-%m-%d %H:%M:%S'`
DIRECTORY=`pwd`
OPC_DIRECTORY=`userscripts`

cd /home/opc
mkdir $OPC_DIRECTORY

if [ ! $(ls -A install.test) ]; then
    # install stuff
    sudo yum -y install ansible

    echo "[info] docker has been installed"
    cat <<-EOF > playbook.yml
---

# Install locally newest docker and start it as a service
- name: run the playbook tasks on the localhost
  connection: local
  hosts: localhost
  become: yes
  tasks:

  - name: Install pip
    yum:
        name: python-pip
        state: latest

  - name: Install docker
    yum:
        name: docker-ce
        state: latest

  - name: Enable docker as service
    systemd:
      name: docker
      enabled: yes

  - name: Start docker as service
    systemd:
      name: docker
      state: started
EOF

  sudo yum -y install yum-utils python-pip
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum -y install docker-ce docker-compose

  sudo firewall-cmd --permanent --add-port=80/tcp
  sudo firewall-cmd --permanent --add-port=443/tcp
  sudo firewall-cmd --reload

# https://geraldonit.com/2017/08/14/disable-selinux-on-oracle-linux/
# setenforce 0
# vim /etc/sysconfig/selinux  --> SELINUX=permissive
  sudo setenforce 0
  sudo sed  -i 's/\(^SELINUX=\).*/\1permissive/' /etc/sysconfig/selinux

ansible-playbook playbook.yml


else
    #stop files still remain
    echo "[info] installation has been previously completed"
fi


echo "script activated $DATE, $DIRECTORY" >> install.test

