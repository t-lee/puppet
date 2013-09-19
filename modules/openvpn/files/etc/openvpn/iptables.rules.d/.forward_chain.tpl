TCP_PORTS=""
UDP_PORTS=""
MY_IP="!!IP!!"

$IPTABLES -N fwd_${MY_IP}_eth_tun
$IPTABLES -N fwd_${MY_IP}_tun_eth
$IPTABLES -A FORWARD -d ${MY_IP} -i $ETH -o $TUN -j fwd_${MY_IP}_eth_tun
$IPTABLES -A FORWARD -s ${MY_IP} -i $TUN -o $ETH -j fwd_${MY_IP}_tun_eth

#######################################################
### place your own rules here after
!!specific_rules!!

#######################################################
# drop the rest
$IPTABLES -A fwd_${MY_IP}_tun_eth -j $LOG "FW-FWRD_${MY_IP}: "
$IPTABLES -A fwd_${MY_IP}_tun_eth -j DROP
$IPTABLES -A fwd_${MY_IP}_eth_tun -j $LOG "FW-FWRD_${MY_IP}: "
$IPTABLES -A fwd_${MY_IP}_eth_tun -j DROP

