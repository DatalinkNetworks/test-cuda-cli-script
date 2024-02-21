#!/bin/bash

# My subinterfaces that I need on distinct MAC addresses
TARGET_IFACES=("bond1.3001" "bond1.3002" "bond1.3003" "bond1.3004" "bond1.3009")


if [[ $(hostname) == *-HA ]]; then
	# Secondary unit
    TARGET_ADDRS=("00:0d:48:22:30:01" "00:0d:48:22:30:02" "00:0d:48:22:30:03" "00:0d:48:22:30:04" "00:0d:48:22:30:09")
else
	# Primary unit
    TARGET_ADDRS=("00:0d:48:11:30:01" "00:0d:48:11:30:02" "00:0d:48:11:30:03" "00:0d:48:11:30:04" "00:0d:48:11:30:09")
fi

for i in "${!TARGET_IFACES[@]}"
do
    IFACE="${TARGET_IFACES[$i]}"
    ADDR="${TARGET_ADDRS[$i]}"
    
	# Show MAC address 
	/sbin/ip link show dev "${IFACE}" 2>/dev/null 1>&2 || continue
	
	# Check to see if the MAC address needs to be changed
    CURRENT_ADDR=$(/sbin/ip address show dev "${IFACE}" | grep ether | cut -d" " -f 6)
    if [[ "${CURRENT_ADDR}" == "${ADDR}" ]]; then
        continue
    fi
	
	# Change the MAC address
    /sbin/ip link set dev "${IFACE}" down  2>/dev/null || continue
    /sbin/ip link set dev "${IFACE}" address "${ADDR}"  2>/dev/null
    /sbin/ip link set dev "${IFACE}" up 2>/dev/null
done
