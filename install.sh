read -p "Set Password Root: " PSW
echo "======================="
echo "Set password root to $PSW and login?"
echo "======================="
echo -e "$PSW\n$PSW\n" | sudo passwd
echo "======================="
echo "Login root"
echo "======================="
su | echo $PSW
echo "======================="
echo "Update app and install packages"
echo "======================="
apt update
apt upgrade -y
apt-get install -y git make gcc libpcap-dev curl unzip zip
apt autoremove
echo "======================="
echo "Clone Tool"
echo "======================="
mkrdir Tool && rm -r *
git clone https://github.com/robertdavidgraham/masscan && cd masscan && make && make install && cd ..
git clone https://github.com/d34db33f-1007/asleep_scanner && cd asleep_scanner && pip3 install -r requirements.txt & cd ..
git clone https://github.com/songlinhou/coolab && cd coolab && pip install . && cd ..
curl https://rclone.org/install.sh | sudo bash -s beta
wget -O ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.tgz && unzip ngrok.zip
cd ..
echo "======================="
echo "Start Setup?"
echo "======================="
read -p "Ngrok Token: " NROK
if [ -z "$NROK" ]
then 
 echo "Ngrok Skip"
else
 echo "Ngrok Login..."
 ./ngrok/ngrok authtoken $NROK
fi