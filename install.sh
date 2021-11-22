read -p "Set Password Root: " PSW
echo "======================="
echo "Set password root to $PSW and login?"
echo "======================="
echo -e "$PSW\n$PSW\n" | sudo passwd
echo "======================="
echo "Update app and install packages"
echo "======================="
echo $PSW | sudo -S apt update && apt upgrade -y && apt-get install -y git make gcc libpcap-dev curl unzip zip && apt autoremove && python -m pip install --upgrade pip
echo "======================="
echo "Clone Tool"
echo "======================="
mkdir Tool && rm -r *
echo "Install Masscan"
git clone https://github.com/robertdavidgraham/masscan && cd masscan && make && make install && cd ..
echo "Install Asleep Scanner"
git clone https://github.com/d34db33f-1007/asleep_scanner && cd asleep_scanner && pip install . & cd ..
echo "Install Coolab"
git clone https://github.com/songlinhou/coolab && cd coolab && pip install . && cd ..
# cd ..
echo "======================="
echo "Install Ngrok"
echo "======================="
read -p "Ngrok Token: " NROK
if [ -z "$NROK" ]
then 
 echo "RDP skip"
else
 echo "Ngrok Install"
 wget -O ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && unzip ngrok.zip
 echo "Ngrok: Set Token"
 ./ngrok/ngrok authtoken $NROK
 echo "Ngrok: Set Port 3389"
 nohup ./ngrok/ngrok tcp 3389 &>/dev/null &
 sudo firefox xrdp xfce4 xfce4-terminal
fi
echo "======================="
echo "Install Rclone"
echo "======================="
read -p "Rclone config file: " NROK
if [ -z "$NROK" ]
then 
 echo "Rclone skip"
else
 echo "Rclone todo"
 curl https://rclone.org/install.sh | sudo bash -s beta
fi