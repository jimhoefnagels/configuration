#!/bin/bash
git pull
#sudo add-apt-repository ppa:bionic-beaver/pycharm
#sudo apt-get update
#sudo apt-get install pycharm
##SmartGit
sudo apt-get install gdebi -y
sudo apt-get install python-virtualenv -y
if [ ! -f smartgit-18_1_1.deb ]; then
   wget https://www.syntevo.com/downloads/smartgit/smartgit-18_1_1.deb
fi
sudo gdebi smartgit-18_1_1.deb
##PyCharm
sudo snap install pycharm-professional --classic
##ssh config
chmod 600 ~/.ssh/id.rsa
ssh-add ~/.ssh/id.rsa
git clone git@gitlab.dynapps.be:tools/ssh-config.git
ln -s ~/.ssh/config ssh-config/config

sudo mkdir /opt/odoo
sudo chown $USER.$USER /opt/odoo
mkdir /opt/odoo/buildouts
for cust in dynapps; do
  if [ ! -d /opt/odoo/buildouts/${cust} ]; then
    git clone -b local git@gitlab.dynapps.be:buildout/${cust}.git /opt/odoo/buildouts/${cust}/local
  fi
  cd /opt/odoo/buildouts/${cust}/local
  virtualenv /opt/odoo/buildouts/${cust}/virtualenv --no-setuptools
  /opt/odoo/buildouts/${cust}/virtualenv/bin/activate
  python bootstrap.py
done
