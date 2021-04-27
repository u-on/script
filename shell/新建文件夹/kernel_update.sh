#!/bin/bash
# DATE: 2020-12-31 16:41:54
# FileName:     kernel_update.sh
# Description:  NULL
# Depend:       get_sys
#
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


kernel_update()
{
    
    
    ###############################更新内核###############################
    
    kernel_update_ubuntu(){
        if [ -n "$1" ] ;then
            kernel_ver="$1"
        else
            echo -e "\e[1;42minstall 默认版本 v5.4.7\e[0m"
            kernel_ver=v5.4.7
        fi
        tmp_dir=/tmp/my_tmp/kernel/ubuntu
        rm -rf /tmp/my_tmp/kernel/ubuntu
        [ ! -d "${tmp_dir}" ] && mkdir -p "${tmp_dir}"
        #获取版本
        ubkernel_urls=https://kernel.ubuntu.com/~kernel-ppa/mainline/${kernel_ver}
        var_rep=$(curl -A "Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko" https://kernel.ubuntu.com/~kernel-ppa/mainline/${kernel_ver}/|grep -Eio 'linux-headers-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-[[:digit:]]+-generic_[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-[[:digit:]]+\.[[:digit:]]+_amd64.deb'|sort | uniq)
        var_ver3=$(echo ${var_rep}|grep -Eio '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-[[:digit:]]+'|sort | uniq )
        echo ${var_ver3}
        var_ver1=$(echo ${var_ver3}|grep -Eio '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+'|sort | uniq )
        var_ver2=$(echo ${var_ver3}|grep -Eio '[[:digit:]]{4,}')
        var_date=$(echo ${var_rep}|grep -Eio '\.[[:digit:]]+\_'|grep -Eio '[[:digit:]]+'|sort | uniq )
        #echo ${var_ver1}
        #echo ${var_ver2}
        #echo ${var_date}
        # 多线程下载内核文件     # ${mirrors_url}
        axel -n 12 -ak "${ubkernel_urls}/linux-modules-${var_ver1}-${var_ver2}-generic_${var_ver1}-${var_ver2}.${var_date}_amd64.deb" -o "${tmp_dir}/linux-modules-${var_ver1}-${var_ver2}-generic_5.4.7-${var_ver2}.${var_date}_amd64.deb"
        axel -n 12 -ak "${ubkernel_urls}/linux-image-unsigned-${var_ver1}-${var_ver2}-generic_${var_ver1}-${var_ver2}.${var_date}_amd64.deb" -o "${tmp_dir}/linux-image-unsigned-${var_ver1}-${var_ver2}-generic_${var_ver1}-${var_ver2}.${var_date}_amd64.deb"
        axel -n 12 -ak "${ubkernel_urls}/linux-headers-${var_ver1}-${var_ver2}-generic_${var_ver1}-${var_ver2}.${var_date}_amd64.deb" -o "${tmp_dir}/linux-headers-${var_ver1}-${var_ver2}-generic_${var_ver1}-${var_ver2}.${var_date}_amd64.deb"
        axel -n 12 -ak "${ubkernel_urls}/linux-headers-${var_ver1}-${var_ver2}_${var_ver1}-${var_ver2}.${var_date}_all.deb" -o "${tmp_dir}/linux-headers-${var_ver1}-${var_ver2}_${var_ver1}-${var_ver2}.${var_date}_all.deb"
        
        cd ${tmp_dir} && dpkg -i ./*.deb
        sudo dpkg --get-selections |grep linux-image
    }
    
    kernel_update_centos(){
        if [ -n "$1" ] ;then
            kernel_ver="$1"
        else
            echo -e "\e[1;42minstall 默认版本 4.4.248\e[0m"
            kernel_ver=4.4.248
        fi
        tmp_dir=/tmp/my_tmp/kernel/centos
        rm -rf /tmp/my_tmp/kernel/centos
        [ ! -d "${tmp_dir}" ] && mkdir -p "${tmp_dir}"
        #
        axel -n 12 -ak "https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-lt-${kernel_ver}-1.el7.elrepo.x86_64.rpm" -o "${tmp_dir}/kernel-lt-${kernel_ver}-1.el7.elrepo.x86_64.rpm"
        axel -n 12 -ak "https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-lt-devel-${kernel_ver}-1.el7.elrepo.x86_64.rpm" -o "${tmp_dir}/kernel-lt-devel-${kernel_ver}-1.el7.elrepo.x86_64.rpm"
        axel -n 12 -ak "https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-lt-tools-${kernel_ver}-1.el7.elrepo.x86_64.rpm" -o "${tmp_dir}/kernel-lt-tools-${kernel_ver}-1.el7.elrepo.x86_64.rpm"
        axel -n 12 -ak "https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-lt-tools-libs-${kernel_ver}-1.el7.elrepo.x86_64.rpm" -o "${tmp_dir}/kernel-lt-tools-libs-${kernel_ver}-1.el7.elrepo.x86_64.rpm"
        cd ${tmp_dir} && yum localinstall -y kernel-lt-${kernel_ver}-1.el7.elrepo.x86_64.rpm kernel-lt-devel-${kernel_ver}-1.el7.elrepo.x86_64.rpm kernel-lt-tools-${kernel_ver}-1.el7.elrepo.x86_64.rpm kernel-lt-tools-libs-${kernel_ver}-1.el7.elrepo.x86_64.rpm
        cd ${tmp_dir} && yum localinstall -y kernel-lt-${kernel_ver}-1.el7.elrepo.x86_64.rpm
        grub2-set-default 0
        rpm -qa | grep kernel
    }
    
    
    
    if [ "$(get_sys)" == "Ubuntu" ];then
        kernel_update_ubuntu "$@"
        elif [ "$(get_sys)" == "CentOS" ];then
        kernel_update_centos "$@"
        
    fi
}

function kernel_del()
{
    if [ "$(get_sys)" == "Ubuntu" ];then
        
        sudo apt remove --purge -y $(dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d')
        
        # sudo apt remove -y $(dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d')
        sudo dpkg --get-selections |grep linux-
        
    else
        echo Not currently supported
    fi
    
}


function kernel_ls()
{
    if [ "$(get_sys)" == "Ubuntu" ];then
        sudo dpkg --get-selections |grep linux-
        elif [ "$(get_sys)" == "CentOS" ];then
        rpm -qa | grep kernel
    fi
}