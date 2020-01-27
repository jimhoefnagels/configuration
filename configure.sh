#!/bin/bash
git pull
source ~/configuration/environment.txt
source ~/configuration/projects.txt
# configure bash
# -----------------
ln -fs ~/configuration/.dotfiles/.bash_aliases -t ~

# apt install requirements
# -----------------
sudo apt-get update
sudo apt-get upgrade
sudo apt autoremove
# install office packages
sudo apt-get install -y evolution-ews 
# install general tools
sudo apt-get install -y gdebi 
# install python packages
sudo apt-get install -y python-tk python-virtualenv python-pip python-gitlab cython python-dev
# install python3 packages
sudo apt-get install -y python3-tk python3-virtualenv python3-pip python3-gitlab cython python3-dev
# install postgres packages
sudo apt-get install -y postgresql postgresql-server-dev-all 
# other development pakcages
sudo apt-get install -y libldap2-dev libssl-dev libsasl2-dev libffi-dev node-less libcups2-dev libxslt1-dev libxml2-dev libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev

# setup eid software repositories
# -------------------------------
wget  -P ~/Downloads/ ${EIDURL}${EIDDEB}
sudo gdebi ~/Downloads/${EIDDEB}
sudo apt-get update
sudo apt-get install -y eid-viewer eid-mw

#pip install requirements
#sudo pip install setuptools
sudo python3.6 -m pip install --upgrade pip setuptools
sudo python3.6 -m pip install --upgrade ${PYLINTURL}
sudo python3.6 -m pip install --upgrade black

## Configure pylint
# -----------------
sudo cp pylint-odoo /usr/local/bin/
sudo chmod +x /usr/local/bin/pylint-odoo

##SmartGit
# -----------------
if [ ! -f ~/Downloads/${SMARTGITDEB} ]; then
   wget -P ~/Downloads/ ${SMARTGITURL}${SMARTGITDEB}
fi
dpkg -s smartgit 2>/dev/null >/dev/null || sudo gdebi ~/Downloads/${SMARTGITDEB}

# FORTICLIENT
if [ ! -f ~/Downloads/${FORTIDEB} ]; then
   wget -P ~/Downloads/ ${FORTIURL}${FORTIDEB}
fi
if [[ $(dpkg -l openforticlient) == '' ]]; then
   sudo gdebi ~/Downloads/${FORTIDEB}
else
   echo 'Forticlient already installed'
fi

# wget -O - https://repo.fortinet.com/repo/ubuntu/DEB-GPG-KEY | sudo apt-key add - 
# grep repo.fortinet.com /etc/apt/sources.list
# if [[ $? != 0 ]]; then
#    echo "deb [arch=amd64] https://repo.fortinet.com/repo/ubuntu/ /bionic multiverse" | sudo tee -a /etc/apt/sources.list
# fi
# sudo apt-get update
# sudo apt install forticlient

# PyCharm / htop / slack
# -----------------------
for p in ${SNAP}; do 
  if [[ ! "$(snap list)" =~ "${p}" ]]; then
    sudo snap install $p --classic
  else
    echo $p' already installed'
  fi
done

## PostGreSQL
# ------------
sudo -u postgres createuser -s ${USER}

# ssh config
# -----------------
sudo chmod 700 ~/.ssh
ssh-add ~/.ssh/id_rsa
git clone git@gitlab.dynapps.be:tools/ssh-config.git ~/ssh-config
ln -fs ~/ssh-config/config ~/.ssh/config

# Usefull git repos
# ------------------
if [ ! -d /opt/git ]; then
    sudo mkdir /opt/git
    sudo chown $USER.$USER /opt/git
fi
git clone git@gitlab.dynapps.be:Toon.Meynen/monitoring_checks.git /opt/git/monitoring_checks

# ODOO Projects
# --------------
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
#   pip install mr.developer
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
   virtualenv /opt/odoo/buildouts/${cust}/venv/bootstrap3 -p python3
   . /opt/odoo/buildouts/${cust}/venv/bootstrap3/bin/activate
   python bootstrap.py
   deactivate
  # bin/buildout
done

# Install lastpass in firefox
# ---------------------------
if [ ! -f ~/Downloads/lastpass_password_manager-4.19.0.5-fx.xpi ]; then
    cd ~
    ll
    wget -P ~/Downloads/ https://addons.mozilla.org/firefox/downloads/file/1133119/${LPFX}
    firefox ~/Downloads/${LPFX}
fi
# TODO: Odoo debug plugin
# https://addons.mozilla.org/firefox/downloads/file/1034121/odoo_debug-3.5-an+fx.xpi?src=search

# Install Powerline
# -----------------
pip install --user powerline-status
pip install --user powerline-gitstatus
pip install --user git+git://github.com/powerline/powerline
wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
sudo mkdir -p /usr/share/fonts/opentype/powerlinesymbols/
sudo mv PowerlineSymbols.otf /usr/share/fonts/opentype/powerlinesymbols/
fc-cache -vf /usr/share/fonts/opentype/powerlinesymbols/
sudo mv 10-powerline-symbols.conf /usr/share/fontconfig/conf.avail/
ln -fs configuration/.dotfiles/.bashrc ~
ln -fs configuration/.dotfiles/.vimrc ~
powerline-daemon --replace
