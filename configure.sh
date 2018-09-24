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

sudo mkdir /opt/odoo
sudo chown $USER.$USER /opt/odoo
if [ ! -d /opt/odoo/dynapps ]; then
  git clone git@gitlab.dynapps.be:buildout/dynapps.git /opt/odoo/dynapps
fi
