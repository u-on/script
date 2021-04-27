#!/bin/bash
# DATE: 2020-12-31 11:04:01
# FileName:     main.sh
# Description:  NULL
# Depend:       get_sys.sh
#               axel_install.sh
#               kernel_update.sh
#

##################################加载依赖##################################
main()
{
    
    local i depend var_tmp
    
    depend=(
        get_sys.sh
        axel_install.sh
        kernel_update.sh
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
    
}
##################################main##################################
main

