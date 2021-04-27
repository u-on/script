#!/bin/bash
# DATE: 2020-12-30 16:59:53
# FileName:     set_lang.sh
# Description:  设置系统语言
#
# Depend:       get-sys
##################################加载依赖##################################
Load_dependencies()
{
    local i depend var_tmp
    
    depend=(
        get_sys.sh
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
#############################################################################



function set_lang()
{
    apt install -y language-pack-zh-hans
    locale -a|grep -q 'zh_CN.utf8'
    if [ $? == 0 ];then
        LANG="zh_CN.utf8"
    fi
}