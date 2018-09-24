#!/bin/bash
git pull
#sudo add-apt-repository ppa:bionic-beaver/pycharm
#sudo apt-get update
#sudo apt-get install pycharm
##SmartGit
sudo apt-get install gdebi -y
wget https://www.syntevo.com/downloads/smartgit/smartgit-18_1_1.deb
sudo gdebi smartgit-18_1_1.deb
##PyCharm
sudo snap install pycharm-professional --classic
