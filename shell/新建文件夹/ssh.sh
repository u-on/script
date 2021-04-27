#!/bin/bash
# DATE: 2020-12-30 13:53:21
# FileName:     ssh.sh
# Description:  配置SSH登录证书   配置免密登录
# Depend:       NULL
#
##################################创建SSL证书###################################
function create_sslkey()
{
    echo -e "\e[1;44mGenerate ssh login key\e[0m"
    # 生成秘钥
    if [ -f "/root/.ssh/id_ed25519" ] || [ -f "/root/.ssh/id_ed25519.pub" ];then
        echo -e "\e[1;31mThe public or private key already exists\e[0m"
    else
        echo -e "\e[1;34mStart generating...\e[0m"
        ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519
        if [ $? == 0 ];then
            echo -e "\e[1;32mSucceed\e[0m"
            chmod 600 ~/.ssh/id_ed25519
            chmod 600 ~/.ssh/id_ed25519.pub
        else
            echo -e "\e[1;31mFailed\e[0m"
        fi
        
    fi
}
##################################免密登录##################################
function set_nopsw()
{
    echo -e "\e[1;44mConfigure password free login\e[0m"
    
    if [ -n "$1" ] ;then
        echo -e "\e[1;34mconfig ${1}\e[0m"
        ssh root@${1} "mkdir -p /root/.ssh"
        scp /root/.ssh/id_ed25519.pub root@${1}:/root/.ssh
        scp /root/.ssh/authorized_keys root@${1}:/root/.ssh
        ssh root@${1} "chmod 700 /root/.ssh;chmod 600 /root/.ssh/id_ed25519.pub;chmod 600 /root/.ssh/authorized_keys"  
    else
        echo -e "\e[1;34mconfig local\e[0m"
        cat /root/.ssh/authorized_keys | grep -q "$(cat /root/.ssh/id_ed25519.pub)"
        if [ "$?" == 1 ];then
            echo -e "\e[1;44madd pub\e[0m"
            cat /root/.ssh/id_ed25519.pub >>/root/.ssh/authorized_keys
        else
            echo -e "\e[1;31mauthorized_keys Included\e[0m"
        fi
        chmod 600 ~/.ssh/authorized_keys
        systemctl restart sshd
    fi
}