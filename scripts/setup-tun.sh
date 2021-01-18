#!/bin/bash

. /etc/default/clash

ip route replace default dev utun table "$IPROUTE2_TABLE_ID"

ip rule del fwmark "$NETFILTER_MARK" lookup "$IPROUTE2_TABLE_ID" > /dev/null 2> /dev/null
ip rule add fwmark "$NETFILTER_MARK" lookup "$IPROUTE2_TABLE_ID"

nft -f - << EOF

define LOCAL_SUBNET = {127.0.0.0/8, 224.0.0.0/4, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12}
define TUN_DEVICE = utun

table inet clash
flush table inet clash

table inet clash {
    chain local {
        type route hook output priority 0; policy accept;
        
        ip protocol != { tcp, udp } accept
        
        meta cgroup $BYPASS_CGROUP_CLASSID accept
        ip daddr \$LOCAL_SUBNET accept
        
        ct state new ct mark set $NETFILTER_MARK
        ct mark $NETFILTER_MARK mark set $NETFILTER_MARK
    }
    
    chain forward {
        type filter hook prerouting priority 0; policy accept;
        
        ip protocol != { tcp, udp } accept
    
        iif utun accept
        ip daddr \$LOCAL_SUBNET accept
        
        mark set $NETFILTER_MARK
    }
    
    chain local-dns-redirect {
        type nat hook output priority 0; policy accept;
        
        ip protocol != { tcp, udp } accept
        
        meta cgroup $BYPASS_CGROUP_CLASSID accept
        
        udp dport 53 dnat ip to $FORWARD_DNS_REDIRECT
        tcp dport 53 dnat ip to $FORWARD_DNS_REDIRECT
    }
    
    chain forward-dns-redirect {
        type nat hook prerouting priority 0; policy accept;
        
        ip protocol != { tcp, udp } accept
        
        udp dport 53 dnat ip to $FORWARD_DNS_REDIRECT
        tcp dport 53 dnat ip to $FORWARD_DNS_REDIRECT
    }
}

EOF

sysctl -w net/ipv4/ip_forward=1

exit 0
