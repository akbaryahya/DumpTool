echo "======================="
echo "Set password root to 123/123"
echo "======================="
echo -e "$123\n$123\n" | sudo passwd
echo "======================="
echo "Login root"
echo "======================="
echo -e "123" | sudo su
echo "======================="
echo "Update app and install packages"
echo "======================="
apt update && apt upgrade -y && apt-get install -y git make gcc libpcap-dev && apt autoremove curl
echo "======================="
echo "Clone Tool"
echo "======================="
mkrdir Tool && rm -r *
git clone https://github.com/robertdavidgraham/masscan && cd masscan && make && make install && cd ..
git clone https://github.com/d34db33f-1007/asleep_scanner && cd asleep_scanner && pip3 install -r requirements.txt & cd ..
git clone https://github.com/songlinhou/coolab && cd coolab && pip install . && cd ..
curl https://rclone.org/install.sh | sudo bash -s beta
cd ..
echo "======================="
echo "Done?"
echo "======================="