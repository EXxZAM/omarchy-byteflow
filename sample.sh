#!/bin/sh
# Route lookups are local: no packets are sent. IPv6 covers IPv6-only networks.
ip -j route get 1.1.1.1 2>/dev/null \
  || ip -j -6 route get 2606:4700:4700::1111 2>/dev/null \
  || printf '[]\n'
cat /proc/net/dev /proc/uptime
