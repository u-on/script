#!/bin/bash
# DATE: 2020-12-31 16:42:24
# FileName:     axel_install.sh
# Description:  安装axel多线程下载工具
# Depend:       get_sys.sh
# shellcheck source=/dev/null


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




axel_install()
{
    
    ##################################ubuntu安装##################################
    axel_install_ubuntu()
    {
        apt install -y axel
    }
    ##################################centos安装##################################
    axel_install_centos()
    {
        yum -y install gcc openssl openssl-devel
        local latestver
        latestver=$(curl -s https://api.github.com/repos/axel-download-accelerator/axel/releases/latest | grep tag_name | cut -d '"' -f 4)
        local latestver2
        latestver2=$(echo -e "${latestver}" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
        local ufile
        ufile=axel-${latestver2}.tar.gz
        local down_url
        down_url=https://github.com/axel-download-accelerator/axel/releases/download/${latestver}/axel-${latestver2}.tar.gz
        
        [ ! -d "/tmp/my_tmp/axel" ] && mkdir -p "/tmp/my_tmp/axel"
        curl -fLk --retry 3 "${down_url}" -o /tmp/my_tmp/axel/"${ufile}" --create-dirs
        echo -e "$(ls /tmp/my_tmp/axel)"
        cd /tmp/my_tmp/axel && tar -zxvf "${ufile}" -C /tmp/my_tmp/axel
        cd axel-"${latestver2}" || exit
        ./configure && make && make install
        rm -rf /tmp/my_tmp/axel/
        cd ~ || exit
    }
    ##################################主安装##################################
    if ! which axel ;then
        if [ "$(get_sys)" == "Ubuntu" ];then
            axel_install_ubuntu
            elif [ "$(get_sys)" == "CentOS" ];then
            axel_install_centos
            
        fi
    fi
}