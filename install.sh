echo "======================="
echo "Clone Tool"
echo "======================="
mkdir Tool && cd Tool && rm -r *
echo "Install Masscan"
git clone https://github.com/robertdavidgraham/masscan && cd masscan && make && make install && cd ..
echo "Install Asleep Scanner"
git clone https://github.com/d34db33f-1007/asleep_scanner && cd asleep_scanner && pip install . && cd ..
echo "Install Coolab"
git clone https://github.com/songlinhou/coolab && cd coolab && pip install . && cd ..