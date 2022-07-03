#apt install net-tools -y
clear
iptables -t mangle -F
iptables -t mangle -X
if [[ -z $(ip link |grep eth0) ]]
then
	read  -p "Nhập IP VPS: " ipaddr
	iptables -t mangle -A PREROUTING   -d $ipaddr  -p tcp --syn -m multiport --dports 80,443 -m hashlimit --hashlimit-above 300/sec --hashlimit-burst 600 --hashlimit-mode srcip --hashlimit-name synflood_http --hashlimit-htable-max 1048576 --hashlimit-htable-expire 3600000 -m comment --comment "global protect" -j DROP
	iptables -t mangle -A PREROUTING -d $ipaddr -p tcp -m tcp -m conntrack --ctstate ESTABLISHED -m multiport --dports 80,443 -m connlimit --connlimit-above 100 --connlimit-mask 64 --connlimit-saddr -m comment --comment global -j DROP		 
else
	iptables -t mangle -A PREROUTING  -i eth0 -p tcp --syn -m multiport --dports 80,443 -m hashlimit --hashlimit-above 300/sec --hashlimit-burst 600 --hashlimit-mode srcip --hashlimit-name synflood_http --hashlimit-htable-max 1048576 --hashlimit-htable-expire 3600000 -m comment --comment "global protect" -j DROP
	iptables -t mangle -A PREROUTING -i eth0 -p tcp -m tcp -m conntrack --ctstate ESTABLISHED -m multiport --dports 80,443 -m connlimit --connlimit-above 100 --connlimit-mask 64 --connlimit-saddr -m comment --comment global -j DROP
fi
echo "Done !!!!"
rm -rf antiddos.sh
