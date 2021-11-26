#!/bin/bash
[ `whoami` = root ] || { sudo "$0" "$@"; exit $?; }

setup_rclone=false
setup_ngrok=false

DIR_GD=/content/drive
DIR_RCLONE=/root/.config/rclone

SET_PASS=$1
SET_RCLONE=$2
SET_NGROK=$3
SET_SERVER_GD=$4

mkdir -p /content/
cd /content/

if [ -z "$SET_PASS" ]
then
 read -p "Set Password Root: " SET_PASS
fi
echo "======================="
echo "Set password root to $SET_PASS and login?"
echo "======================="
echo -e "$SET_PASS\n$SET_PASS\n" | sudo passwd
echo "======================="
echo "Install Packages Base"
echo "======================="
echo $SET_PASS | sudo -S apt update && apt upgrade -y && apt-get install -y git make gcc libpcap-dev libsqlite3-dev curl unzip zip && apt autoremove && pip3 install --upgrade pip
# apt install libpcap-dev libsqlite3-dev echo $SET_PASS | sudo -S 
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
 curl https://rclone.org/install.sh | sudo bash -s beta
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

read -r -p "Install masscan? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    git clone https://github.com/robertdavidgraham/masscan && cd masscan && make && make install && cd ..
fi
read -r -p "Install Coolab? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    pip3 install google-colab tqdm
    git clone https://github.com/songlinhou/coolab && cd coolab && pip3 install . && cd ..
fi
read -r -p "Install RDP? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    #TODO: check ngrok limit
    echo "Ngrok: Set Port 3389"
    nohup ./ngrok tcp 3389 &>/dev/null &
    sudo apt-get install -y firefox xrdp xfce4 xfce4-terminal
fi
read -r -p "Install asleep scanner? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    git clone https://github.com/d34db33f-1007/asleep_scanner && cd asleep_scanner && pip3 install . && cd ..
fi

# Ending
echo "Done..."