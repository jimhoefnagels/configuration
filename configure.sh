#!/bin/bash
DL='~/Downloads/'
OLD_BUILDOUTS='dynapps'
NEW_BUILDOUTS='demo12 demo11 intracto'
BUILDOUT_ENVS='local testing'
SNAP='pycharm-professional htop setuptools slack'
git pull
#sudo add-apt-repository ppa:bionic-beaver/pycharm
#sudo apt-get update
#sudo apt-get install pycharm

sudo apt-get install -y gdebi python-virtualenv python-pip libxslt1-dev libxml2-dev libtiff5-dev libjpeg8-dev zlib1g-dev \
libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk postgresql postgresql-server-dev-10 python-dev \
libldap2-dev libssl-dev libsasl2-dev cython evolution-ews libffi-dev node-less

sudo pip install setuptools

##SmartGit
if [ ! -f ~/Downloads/smartgit-18_1_1.deb ]; then
   wget -P ~/Downloads/ https://www.syntevo.com/downloads/smartgit/smartgit-18_1_1.deb
fi
if [[ $(dpkg -l smartgit) == '' ]]; then
   sudo gdebi ~/Downloads/smartgit-18_1_1.deb
else
   echo 'Smartgit already installed'
fi

##PyCharm / htop / slack
list=$(snap list)
echo ${list}
for p in ${SNAP}; do 
  echo 'checking '$p' is in '$list
  if [[ ${list} =~ ${p} ]]; then
    echo 'installing '${p}
    sudo snap install $p --classic
  else
    echo $p' already installed'
  fi
done

## PostGreSQL
sudo -u postgres createuser -s ${USER}

##ssh config
chmod 600 ~/.ssh/id.rsa
ssh-add ~/.ssh/id.rsa
git clone git@gitlab.dynapps.be:tools/ssh-config.git ~/ssh-config
ln -fs ~/ssh-config/config ~/.ssh/config

if [ ! -d /opt/odoo ]; then
    sudo mkdir /opt/odoo
    sudo chown $USER.$USER /opt/odoo
    mkdir /opt/odoo/buildouts
fi

for cust in ${OLD_BUILDOUTS}; do
   for env in ${BUILDOUT_ENVS}; do
      echo 'cloning '${env}' of '${cust}
      if [ ! -d /opt/odoo/buildouts/${cust}/${env} ]; then
         git clone -b ${env} git@gitlab.dynapps.be:buildout/${cust}.git /opt/odoo/buildouts/${cust}/${env}
      fi
   done
   cd /opt/odoo/buildouts/${cust}/local/local
   virtualenv /opt/odoo/buildouts/${cust}/virtualenv --no-setuptools
   . /opt/odoo/buildouts/${cust}/virtualenv/bin/activate
   python bootstrap.py
   deactivate
  # bin/buildout
done
for cust in ${NEW_BUILDOUTS}; do
      echo 'cloning '${cust}
      if [ ! -d /opt/odoo/buildouts/${cust}/buildout ]; then
         git clone -b master git@gitlab.dynapps.be:customers/${cust}/buildout.git /opt/odoo/buildouts/${cust}/buildout
      fi
   cd /opt/odoo/buildouts/${cust}/buildout
   ln -s local.cfg buildout.cfg
   virtualenv -p python3 /opt/odoo/buildouts/${cust}/virtualenv --no-setuptools
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
# TODO: Odoo debug plugin
# https://addons.mozilla.org/firefox/downloads/file/1034121/odoo_debug-3.5-an+fx.xpi?src=search
