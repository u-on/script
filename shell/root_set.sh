#!/bin/bash
# DATE: 2021-05-08 09:10:22
# FileName:     root_set.sh
# Description:  启用、禁用root账号
# Depend:       NULL
#

##################################启用root用户##################################
# 启用|关闭 root用户
# root-user [on|off]

RootUserOpen() {
    sed -ri 's/^PermitRootLogin.*/#&/g' /etc/ssh/sshd_config
    sed -ri 's/^LoginGraceTime.*/#&/g' /etc/ssh/sshd_config
    sed -ri 's/^StrictModes.*/#&/g' /etc/ssh/sshd_config
    grep -Eqi "^#PermitRootLogin.*" /etc/ssh/sshd_config
    tmp_fh=$?
    [[ $tmp_fh == 0 ]] && echo -e "\e[1;32mROOT账户启用成功 [Root account enabled successfully]\e[0m"
    [[ $tmp_fh == 0 ]] || echo -e "\e[1;31mROOT账户启用失败 [Failed to enable root account]\e[0m"
    systemctl restart sshd
}

RootUserClose() {
    sed -ri 's/^#(PermitRootLogin).*/\1 yes/g' /etc/ssh/sshd_config
    sed -ri 's/^#(LoginGraceTime).*/\1 2m/g' /etc/ssh/sshd_config
    sed -ri 's/^#(StrictModes).*/\1 yes/g' /etc/ssh/sshd_config
    grep -Eqi "^PermitRootLogin.*yes" /etc/ssh/sshd_config
    tmp_fh=$?
    [[ $tmp_fh == 0 ]] && echo -e "\e[1;32mROOT账户禁用成功 [Root account disabled successfully]\e[0m"
    [[ $tmp_fh == 0 ]] || echo -e "\e[1;31mROOT账户禁用失败 [Root account disable failed]\e[0m"
    systemctl restart sshd
}

while
    getopts :och OPT
do
    case $OPT in

    o)
        RootUserOpen
        ;;

    c)
        RootUserClose
        ;;

    h)
        dis=$(
            cat <<-EOF

\e[1;42m参数：\e[0m
        -o      # 启用
        -c      # 关闭
 
 
EOF
        )

        echo -e "${dis}"
        ;;
    :)                                                  #当选项后面没有参数时，OPT的值被设置为（：），OPTARG的值被设置为选项本身
        echo "the option -$OPTARG require an arguement" #提示用户此选项后面需要一个参数
        exit 1
        ;;
    ?)                                  #当选项不匹配时，OPT的值被设置为（？），OPTARG的值被设置为选项本身
        echo "Invaild option: -$OPTARG" #提示用户此选项无效
        echo "-v <kernel version> "
        exit 2
        ;;
    esac
done
