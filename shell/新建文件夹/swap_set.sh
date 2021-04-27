#!/bin/bash
# DATE: 2020-12-31 16:52:17
# FileName:     swap_set.sh
# Description:  swap开关
# Depend:       NULL
#

function swap_set()
{
    if [ "$1" == "off" ];then
        swapoff -a && sysctl -w vm.swappiness=0
        tmp_fh1=$?
        sed -ri 's/^\/swap.*swap.*/#&/' /etc/fstab
        tmp_fh2=$?
        tmp_fh3=$((tmp_fh1+tmp_fh2))
        [[ $tmp_fh3 == 0 ]] && echo -e "\e[1;32m关闭成功\e[0m"
        [[ $tmp_fh3 == 0 ]] || echo -e "\e[1;31m关闭失败\e[0m"
        
        elif [ "$1" == "on" ];then
        sed -ri 's/^\#(\/swap.*swap.*)/\1/' /etc/fstab
        tmp_fh1=$?
        swapon -a && sysctl -w vm.swappiness=60
        tmp_fh2=$?
        tmp_fh3=$((tmp_fh1+tmp_fh2))
        [[ $tmp_fh3 == 0 ]] && echo -e "\e[1;32m开启成功\e[0m"
        [[ $tmp_fh3 == 0 ]] || echo -e "\e[1;31m开启失败\e[0m"
    fi
}