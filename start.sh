#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "We don't support NO-ROOT so please use root user so you can do anything unlimited"
  exit
fi

setup_rclone=false
setup_ngrok=false

DIR_GD=/content/drive
DIR_RCLONE=/root/.config/rclone

SET_PASS=$1
SET_RCLONE=$2
SET_NGROK=$3
SET_SERVER_GD=$4
SET_INSTALL=$5

if [ -z "$SET_PASS" ]
then
 read -p "Set Password Root: " SET_PASS
fi
echo "======================="
echo "Set password root to $SET_PASS and login?"
echo "======================="
echo -e "$SET_PASS\n$SET_PASS\n" | passwd
echo "======================="
echo "Install Packages Base"
echo "======================="
apt update
apt upgrade -y
apt-get upgrade -y
apt-get install -y git make gcc libpcap-dev libsqlite3-dev curl unzip zip
apt autoremove 
pip3 install --upgrade pip
# apt install libpcap-dev libsqlite3-dev echo $SET_PASS | sudo -S 
echo "======================="
echo "Setup Folder Base"
echo "======================="
mkdir -p /content/
cd /content/
echo "======================="
echo "Setup Rclone"
echo "======================="
if [ -z "$SET_RCLONE" ]
then
 read -p "Rclone config file: " SET_RCLONE
fi
if [ -z "$SET_RCLONE" ]
then 
 echo "Rclone Skip"
else
 echo "Install Rclone"
 curl https://rclone.org/install.sh | bash -s beta
 echo "Rclone: Download file $SET_RCLONE"
 mkdir -p "$DIR_RCLONE/"
 wget -O "$DIR_RCLONE/rclone.conf" $SET_RCLONE
 echo "Rclone: Mount"
 if [ -z "$SET_SERVER_GD" ]
 then
  read -p "Server?: " SET_SERVER_GD
 fi 
 DIR_GD_ROOT="$DIR_GD/$SET_SERVER_GD/"
 mkdir -p $DIR_GD_ROOT
 echo "Rclone: UnMount $DIR_GD_ROOT"
 fusermount -uz $DIR_GD_ROOT
 echo "Rclone: Set Folder Server to $DIR_GD_ROOT"
 rclone mount $SET_SERVER_GD:/ $DIR_GD_ROOT --allow-other --daemon
 ZDIRT="${DIR_GD_ROOT}.cache/"
 if [ -d "$ZDIRT" ] 
 then
  echo "Found folder cache: $ZDIRT" 
 else
  echo "Error: Directory $ZDIRT does not exists."
  mkdir -p $ZDIRT
 fi
 setup_rclone=true
fi

echo "======================="
echo "Setup Ngrok"
echo "======================="
if $setup_rclone
then 
    RTSX=${ZDIRT}ngrok.conf
    echo "Ngrok: Check file: $RTSX"
    if test -f "$RTSX";
    then
     echo "Found file token"
     SET_NGROK=`cat $RTSX`
     setup_ngrok=true
    else
     if [ -z "$SET_NGROK" ]
     then
      read -p "Ngrok Token: " SET_NGROK
     fi
     if [ -z "$SET_NGROK" ]
     then 
      echo "Ngrok: Skip"
     else
      echo "Ngrok: Save Token"
      setup_ngrok=true
      echo "$SET_NGROK" >> "$RTSX"
     fi
    fi
else 
   if [ -z "$SET_NGROK" ]
   then
    read -p "Ngrok Token: " SET_NGROK
   fi
   if [ -z "$SET_NGROK" ]
   then
    echo "Ngrok Skip"
   else
    setup_ngrok=true
   fi
fi

if $setup_ngrok
then 
 echo "Ngrok Install..."
 wget -O ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && unzip -o ngrok.zip
 ls
 echo "Ngrok: Set Token"
 ./ngrok authtoken $SET_NGROK 
fi

ARR_INSTALL=($(echo $SET_INSTALL | tr ";" "\n"))
for i in "${ARR_INSTALL[@]}"
do
    echo "Install $i"

    if [[ "$i" == *"masscan"* ]]; then
     git clone https://github.com/robertdavidgraham/masscan && cd masscan && make && make install && cd ..
    else
     echo "Skip..."
    fi

    if [[ "$i" == *"coolab"* ]]; then
     pip3 install google-colab tqdm
     git clone https://github.com/songlinhou/coolab && cd coolab && pip3 install . && cd ..
    else
     echo "Skip..."
    fi

    if [[ "$i" == *"rdp"* ]]; then
     #TODO: check ngrok limit
     echo "Ngrok: Set Port 3389"
     nohup ./ngrok tcp 3389 &>/dev/null &
     apt-get install -y firefox xrdp xfce4 xfce4-terminal
    else
     echo "Skip..."
    fi

    if [[ "$i" == *"asleep"* ]]; then
     git clone https://github.com/d34db33f-1007/asleep_scanner && cd asleep_scanner && pip3 install . && cd ..
    else
     echo "Skip..."
    fi

done

# Ending
echo "Done..."