#!/bin/bash
# DATE: 2020-12-31 19:53:05
# FileName:     cfssl_install.sh
# Description:  cfssl安装
# Depend:       axel_install.sh
#
# shellcheck source=/dev/null
##################################加载依赖##################################
Load_dependencies()
{
    local i depend var_tmp
    
    depend=(
        axel_install.sh
    )
    
  depend_url=https://gitee.com/uon/script/raw/master/shell/
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
    
}
Load_dependencies
############################################################################

cfssl_install()
{
    axel_install
    if ! which cfssl;then
        local down_file=(
            cfssl_linux-amd64
            cfssljson_linux-amd64
            cfssl-certinfo_linux-amd64
        )
        for i in "${down_file[@]}";do
            [ ! -d /tmp/my_tmp/cfssl ] && mkdir -p /tmp/my_tmp/cfssl
            cd /tmp/my_tmp/cfssl &&  axel -n 8 -ak https://pkg.cfssl.org/R1.2/"${i}"
            #重命名去除_linux-amd64
            mv $i ${i%*_linux-amd64}
        done
        cd /tmp/my_tmp/cfssl && mv cfssl* /usr/local/bin/ && chmod +x /usr/local/bin/cfssl*
        cd ~
    fi
}

