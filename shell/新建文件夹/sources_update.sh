#!/bin/bash
# DATE: 2020-12-31 16:58:42
# FileName:     sources_update.sh
# Description:  NULL
# Depend:       get_sys.sh
#


function sources_update()
{
    
    ##################################加载支持文件##################################
    local i depend var_tmp
    depend=(
        get_sys.sh
    )
    
    depend_url=https://gitee.com/uon/conf/raw/master/
    for i in "${depend[@]}";do
        var_tmp=$(echo $i|cut -c 1-$((${#i}-3)))
        if [[ ! $(type -t $var_tmp) == "function" ]];then
            
            if [ -f "$i" ];then
                if source "${i}";then
                    echo -e "\e[1;32mSuccessfully loaded ${i}\e[0m"
                else
                    echo -e "\e[1;31mFailed to load ${i}\e[0m"
                fi
            else
                if source <(curl -sLk "${depend_url}${i}");then
                    echo -e "\e[1;32mSuccessfully loaded ${i}\e[0m"
                else
                    echo -e "\e[1;31mFailed to load ${i}\e[0m"
                fi
            fi
        fi
    done
    #################################################################################
    
    
    if [ "$(get_sys)" == "CentOS" ];then
        sudo yum install -y epel-release
        sudo sed -e 's|^metalink=|#metalink=|g' \
        -e 's|^#baseurl=https\?://download.fedoraproject.org/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel/|g' \
        -i.bak \
        /etc/yum.repos.d/epel.repo
        
        
        
        elif [ "$(get_sys)" == "Ubuntu" ];then
        cp /etc/apt/sources.list /etc/apt/sources.list."$(date +"%Y%m%d%H%M%S")".bak
            cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
EOF
        
        tmp_fh=$?
        [[ $tmp_fh == 0 ]] && echo -e "\e[1;32m成功\e[0m"
        [[ $tmp_fh == 0 ]] || echo -e "\e[1;31m失败\e[0m"
        
        
    fi
}