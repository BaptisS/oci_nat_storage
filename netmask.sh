#!/usr/bin/env bash
base=${1%/*}
masksize=${1#*/}
[ $masksize -lt 8 ] && { echo "Max range is /8."; exit 1;}
mask=$(( 0xFFFFFFFF << (32 - $masksize) ))
IFS=. read a b c d <<< $base
ip=$(( ($b << 16) + ($c << 8) + $d ))
ipstart=$(( $ip & $mask ))
ipend=$(( ($ipstart | ~$mask ) & 0x7FFFFFFF ))
seq $ipstart $ipend | while read i; do
    echo $a.$(( ($i & 0xFF0000) >> 16 )).$(( ($i & 0xFF00) >> 8 )).$(( $i & 0x00FF ))
done
