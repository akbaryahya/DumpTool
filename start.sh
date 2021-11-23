cd /content/
setup_rclone=false
setup_ngrok=false
read -p "Set Password Root: " PSW
echo "======================="
echo "Set password root to $PSW and login?"
echo "======================="
echo -e "$PSW\n$PSW\n" | sudo passwd

echo "======================="
echo "Install Packages Base"
echo "======================="
echo $PSW | sudo -S apt update && apt upgrade -y && apt-get install -y git make gcc libpcap-dev curl unzip zip && apt autoremove && pip install --upgrade pip

echo "======================="
echo "Setup Rclone"
echo "======================="
read -p "Rclone config file: " RCP
if [ -z "$RCP" ]
then 
 echo "Rclone Skip"
else
 echo "Install Rclone"
 curl https://rclone.org/install.sh | sudo bash -s beta
 echo "Rclone: Download file $RCP"
 mkdir -p /root/.config/rclone/
 wget -O /root/.config/rclone/rclone.conf $RCP
 echo "Rclone: Mount"
 read -p "Server?: " MTP
 mkdir $MTP  && rclone mount $MTP:/ $MTP --daemon
 ZDIRT=$MTP/.cache/
 if [ -d "$ZDIRT" ] 
 then
  echo "Found folder cache" 
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
    RTSX=$MTP/.cache/ngrok.conf
    echo "Ngrok: Check file: $RTSX"   
    if test -f "$RTSX"; 
    then
     echo "Found file token"
     NROK=`cat $RTSX`
     setup_ngrok=true
    else
     read -p "Ngrok Token: " NROK
     if [ -z "$NROK" ]
     then 
      echo "Ngrok: Skip"
     else
      echo "Ngrok: Save Token"
      setup_ngrok=true
      echo "$NROK" >> "$RTSX"
     fi
    fi
else 
   read -p "Ngrok Token: " NROK
   if [ -z "$NROK" ]
   then
    echo "Ngrok Skip"
   else
    setup_ngrok=true
   fi
fi

if $setup_ngrok
then 
 echo "Ngrok Install"
 wget -O ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && unzip ngrok.zip
 echo "Ngrok: Set Token"
 ./ngrok/ngrok authtoken $NROK
 echo "Ngrok: Set Port 3389"
 nohup ./ngrok/ngrok tcp 3389 &>/dev/null &
 sudo apt-get install -y firefox xrdp xfce4 xfce4-terminal
fi

read -r -p "Install masscan? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    git clone https://github.com/robertdavidgraham/masscan && cd masscan && make && make install && cd ..
fi
read -r -p "Install asleep scanner? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    git clone https://github.com/d34db33f-1007/asleep_scanner && cd asleep_scanner && pip install . && cd ..
fi
read -r -p "Install Coolab? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    git clone https://github.com/songlinhou/coolab && cd coolab && pip install . && cd ..
fi

# Ending
echo "Done..."