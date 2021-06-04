#!/bin/bash

WAN_NET="eth0"; WAN_IP="xxx.xxx.xxx.xxx"
WG_MIMO_NET="mimo"; WG_MIMO_IP_LOCAL="172.16.0.1"; WG_MIMO_IP_REMOTE="172.16.0.2"

iptables -F
iptables -X
iptables -t nat -F
ip6tables -F
ip6tables -X

iptables -P FORWARD DROP
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
ip6tables -P FORWARD DROP
ip6tables -P INPUT DROP
ip6tables -P OUTPUT ACCEPT

iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT

iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT

ip6tables -A INPUT -s fc00::/6 -d fc00::/6 -p udp --dport 546 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type 1 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type 2 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type 3 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type 4 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type 128 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type 129 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type 133 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type 134 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type 135 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type 136 -j ACCEPT

# ssh
iptables -A INPUT -p tcp --dport 50022 -m state --state NEW -j ACCEPT
ip6tables -A INPUT -p tcp --dport 50022 -m state --state NEW -j ACCEPT

# wireguard - mimo
iptables -A INPUT -p udp --dport 51820 -m state --state NEW -j ACCEPT
ip6tables -A INPUT -p udp --dport 51820 -m state --state NEW -j ACCEPT

# mimo - mail
iptables -t nat -A PREROUTING  -i "${WAN_NET}"                     -d "${WAN_IP}"            -p tcp -m multiport --dports 80,50587,50993 -j DNAT   --to-destination "${WG_MIMO_IP_REMOTE}"
iptables        -A FORWARD     -i "${WAN_NET}" -o "${WG_MIMO_NET}" -d "${WG_MIMO_IP_REMOTE}" -p tcp -m multiport --dports 80,50587,50993 -j ACCEPT -m state --state NEW
iptables -t nat -A POSTROUTING                 -o "${WG_MIMO_NET}" -d "${WG_MIMO_IP_REMOTE}" -p tcp -m multiport --dports 80,50587,50993 -j SNAT   --to-source "${WG_MIMO_IP_LOCAL}"
