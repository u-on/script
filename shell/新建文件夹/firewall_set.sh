#!/bin/bash
# DATE: 2020-12-31 16:52:17
# FileName:     firewall_set.sh
# Description:  防火墙开关
# Depend:       NULL
#

##################################依赖##################################
function get_sys() {
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
    else
        DISTRO='1'
    fi
    ###返回值
    echo ${DISTRO}
}

#############################################################################

function firewall_set() {

    if [ "$1" == "off" ]; then

        if [ "$(get_sys)" == "CentOS" ]; then
            systemctl stop firewalld
            systemctl disable firewalld
            systemctl status firewalld

        elif [ "$(get_sys)" == "Ubuntu" ]; then
            ufw disable
            ufw status
        fi

    elif [ "$1" == "on" ]; then

        if [ "$(get_sys)" == "CentOS" ]; then
            systemctl start firewalld
            systemctl enable firewalld
            systemctl status firewalld

        elif [ "$(get_sys)" == "Ubuntu" ]; then
            echo -e "\e[1;31m此操作将中断ssh连接，是否继续？（y|n）\e[0m"
            ufw enable >/dev/null
            ufw status

        fi
    fi
}

f