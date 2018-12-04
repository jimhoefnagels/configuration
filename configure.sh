#!/bin/bash
DL='~/Downloads/'
git pull
#sudo add-apt-repository ppa:bionic-beaver/pycharm
#sudo apt-get update
#sudo apt-get install pycharm

##SmartGit
sudo apt-get install -y gdebi python-virtualenv python-pip libxslt1-dev libxml2-dev libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk
if [ ! -f ~/Downloads/smartgit-18_1_1.deb ]; then
   wget -P ~/Downloads/ https://www.syntevo.com/downloads/smartgit/smartgit-18_1_1.deb
fi
sudo gdebi ~/Downloads/smartgit-18_1_1.deb

##PyCharm
sudo snap install pycharm-professional --classic
sudo snap install htop

##ssh config
chmod 600 ~/.ssh/id.rsa
ssh-add ~/.ssh/id.rsa
git clone git@gitlab.dynapps.be:tools/ssh-config.git ~/ssh-config
ln -fs ~/.ssh/config ~/ssh-config

if [ ! -d /opt/odoo ]; then
    sudo mkdir /opt/odoo
    sudo chown $USER.$USER /opt/odoo
    mkdir /opt/odoo/buildouts
fi

for cust in dynapps; do
  if [ ! -d /opt/odoo/buildouts/${cust} ]; then
    git clone -b local git@gitlab.dynapps.be:buildout/${cust}.git /opt/odoo/buildouts/${cust}/local
  fi
  cd /opt/odoo/buildouts/${cust}/local/local
  virtualenv /opt/odoo/buildouts/${cust}/virtualenv --no-setuptools
  . /opt/odoo/buildouts/${cust}/virtualenv/bin/activate
  python bootstrap.py
  deactivate
  # bin/buildout
done

# Install lastpass in firefox
if [ ! -f ~/Downloads/lastpass_password_manager-4.19.0.5-fx.xpi ]; then
    cd ~
    ll
    wget -P ~/Downloads/ https://addons.mozilla.org/firefox/downloads/file/1133119/lastpass_password_manager-4.19.0.5-fx.xpi
    firefox ~/Downloads/lastpass_password_manager-4.19.0.5-fx.xpi
fi
