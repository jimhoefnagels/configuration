#!/bin/bash
DL='~/Downloads/'
OLD_BUILDOUTS=''
NEW_P2BUILDOUTS='dynapps10'
NEW_P3BUILDOUTS='vertical_accounting_v12 dynapps10 demo12 demo11 intracto twerk'
BUILDOUT_ENVS='local testing'
SNAP='pycharm-professional htop setuptools slack'
SMARTGITURL='https://www.syntevo.com/downloads/smartgit/'
SMARTGITDEB='smartgit-18_2_4.deb'
FORTIURL='https://hadler.me/files/'
FORTIDEB='forticlient-sslvpn_4.4.2329-1_amd64.deb'
PYLINTURL='git+https://github.com/oca/pylint-odoo.git'
git pull

# configure bash
ln -fs ~/configuration/.dotfiles/.bash_aliases -t ~

# apt install requirements
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y gdebi python-virtualenv python-pip python-gitlab \
libcups2-dev \
libxslt1-dev libxml2-dev \
libtiff5-dev libjpeg8-dev zlib1g-dev \
libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk postgresql postgresql-server-dev-10 python-dev \
libldap2-dev libssl-dev libsasl2-dev cython evolution-ews libffi-dev node-less

#pip install requirements
#sudo pip install setuptools
sudo pip install --upgrade pip setuptools
sudo pip install --upgrade ${PYLINTURL}

## Configure pylint
sudo cp pylint-odoo /usr/local/bin/
sudo chmod +x /usr/local/bin/pylint-odoo

##SmartGit
if [ ! -f ~/Downloads/${SMARTGITDEB} ]; then
   wget -P ~/Downloads/ ${SMARTGITURL}${SMARTGITDEB}
#fi
#if [[ $(dpkg -l smartgit) == '' ]]; then
   sudo gdebi ~/Downloads/${SMARTGITDEB}
else
   echo 'Smartgit already installed'
fi
## FORTICLIENT
#if [ ! -f ~/Downloads/${FORTIDEB} ]; then
#   wget -P ~/Downloads/ ${FORTIURL}${FORTIDEB}
#fi
#if [[ $(dpkg -l smartgit) == '' ]]; then
#   sudo gdebi ~/Downloads/${FORTIDEB}
#else
#   echo 'Forticlient already installed'
#fi

wget -O - https://repo.fortinet.com/repo/ubuntu/DEB-GPG-KEY | sudo apt-key add - 
grep repo.fortinet.com /etc/apt/sources.list
if [[ $? != 0 ]]; then
    echo "deb [arch=amd64] https://repo.fortinet.com/repo/ubuntu/ /bionic multiverse" | sudo tee -a /etc/apt/sources.list
fi
sudo apt-get update
sudo apt install forticlient

##PyCharm / htop / slack
for p in ${SNAP}; do 
  if [[ ! "$(snap list)" =~ "${p}" ]]; then
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
for cust in ${NEW_P2BUILDOUTS}; do
      echo 'cloning '${cust}
      if [ ! -d /opt/odoo/buildouts/${cust}/buildout ]; then
         git clone -b master git@gitlab.dynapps.be:customers/${cust}/buildout.git /opt/odoo/buildouts/${cust}/buildout
      fi
   cd /opt/odoo/buildouts/${cust}/buildout
   ln -s local.cfg buildout.cfg
   virtualenv -p python2.7 /opt/odoo/buildouts/${cust}/virtualenv --no-setuptools
   . /opt/odoo/buildouts/${cust}/virtualenv/bin/activate
   python bootstrap.py
   deactivate
  # bin/buildout
done
for cust in ${NEW_P3BUILDOUTS}; do
      echo 'cloning '${cust}
      if [ ! -d /opt/odoo/buildouts/${cust}/buildout ]; then
         git clone -b master git@gitlab.dynapps.be:customers/${cust}/buildout.git /opt/odoo/buildouts/${cust}/buildout
      fi
   cd /opt/odoo/buildouts/${cust}/buildout
   ln -s local.cfg buildout.cfg
   virtualenv /opt/odoo/buildouts/${cust}/virtualenv/bootstrap3 -p python3 --no-setuptools
   . /opt/odoo/buildouts/${cust}/virtualenv/bootstrap3/bin/activate
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
