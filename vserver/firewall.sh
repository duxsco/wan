#!/usr/bin/env bash

wan_net="eth0"; wan_ip="xxx.xxx.xxx.xxx"
wg_mimo_net="mimo"; wg_mimo_ip_local="172.16.0.1"; wg_mimo_ip_remote="172.16.0.2"

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
iptables -t nat -A PREROUTING  -i "${wan_net}"                     -d "${wan_ip}"            -p tcp -m multiport --dports 80,50587,50993 -j DNAT   --to-destination "${wg_mimo_ip_remote}"
iptables        -A FORWARD     -i "${wan_net}" -o "${wg_mimo_net}" -d "${wg_mimo_ip_remote}" -p tcp -m multiport --dports 80,50587,50993 -j ACCEPT -m state --state NEW
iptables -t nat -A POSTROUTING                 -o "${wg_mimo_net}" -d "${wg_mimo_ip_remote}" -p tcp -m multiport --dports 80,50587,50993 -j SNAT   --to-source "${wg_mimo_ip_local}"
