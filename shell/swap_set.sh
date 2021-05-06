#!/bin/bash
# DATE: 2020-12-31 16:52:17
# FileName:     swap_set.sh
# Description:  swap开关
# Depend:       NULL
#

function swap-off() {
    swapoff -a && sysctl -w vm.swappiness=0
    tmp_fh1=$?
    sed -ri 's/^\/swap.*swap.*/#&/' /etc/fstab
    tmp_fh2=$?
    tmp_fh3=$((tmp_fh1 + tmp_fh2))
    [[ $tmp_fh3 == 0 ]] && echo -e "\e[1;32m关闭成功\e[0m"
    [[ $tmp_fh3 == 0 ]] || echo -e "\e[1;31m关闭失败\e[0m"
}

function swap-on() {
    sed -ri 's/^\#(\/swap.*swap.*)/\1/' /etc/fstab
    tmp_fh1=$?
    swapon -a && sysctl -w vm.swappiness=60
    tmp_fh2=$?
    tmp_fh3=$((tmp_fh1 + tmp_fh2))
    [[ $tmp_fh3 == 0 ]] && echo -e "\e[1;32m开启成功\e[0m"
    [[ $tmp_fh3 == 0 ]] || echo -e "\e[1;31m开启失败\e[0m"
}

while
    # 可选参数有u和m和i和h
    getopts :och OPT
do
    case $OPT in

    o)
        swap-on
        ;;

    c)
        swap-off
        ;;

    h)
        dis=$(
            cat <<-EOF

\e[1;42m参数：\e[0m
        -o      # 打开
        -c      # 关闭
 
 
EOF
        )

        echo -e "${dis}"
        ;;

    :)       #当选项后面没有参数时，OPT的值被设置为（：），OPTARG的值被设置为选项本身
        echo "the option -$OPTARG require an arguement" #提示用户此选项后面需要一个参数
        exit 1
        ;;

    ?)       #当选项不匹配时，OPT的值被设置为（？），OPTARG的值被设置为选项本身
        echo "Invaild option: -$OPTARG" #提示用户此选项无效
        echo "-v <kernel version> "
        exit 2
        ;;

    esac

done
