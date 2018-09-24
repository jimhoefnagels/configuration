#!/bin/bash
git pull
#sudo add-apt-repository ppa:bionic-beaver/pycharm
#sudo apt-get update
#sudo apt-get install pycharm
##SmartGit
sudo apt-get install gdebi -y
if [ ! -f smartgit-18_1_1.deb ]; then
   wget https://www.syntevo.com/downloads/smartgit/smartgit-18_1_1.deb
fi
sudo gdebi smartgit-18_1_1.deb
##PyCharm
sudo snap install pycharm-professional --classic
##ssh config
chmod 600 id.rsa
ssh-add id.rsa
git clone git@gitlab.dynapps.be:tools/ssh-config.git
ln -s ~/.ssh/config ssh-config/config

sudo mkdir /opt/odoo
sudo chown $USER.$USER /opt/odoo
mkdir /opt/odoo/buildouts
if [ ! -d /opt/odoo/buildouts/dynapps ]; then
  git clone -b local git@gitlab.dynapps.be:buildout/dynapps.git /opt/odoo/buildouts/dynapps/local
  cd /opt/odoo/buildouts/dynapps/local
fi
