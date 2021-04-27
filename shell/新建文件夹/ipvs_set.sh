#!/bin/bash
# DATE: 2021-01-08 10:44:20
# FileName:     ipvs_set.sh
# Description:  ipvs 开关
# Depend:       get_sys.sh
#

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



function ipvs_set ()
{
    if [ "$1" == "on" ];then
        if [ "$(get_sys)" == "Ubuntu" ];then
            
            for i in $(ls /lib/modules/$(uname -r)/kernel/net/netfilter/ipvs|grep -o "^[^.]*");do echo $i; /sbin/modinfo -F filename $i >/dev/null 2>&1 && /sbin/modprobe $i; done
            ls /lib/modules/$(uname -r)/kernel/net/netfilter/ipvs|grep -o "^[^.]*" >> /etc/modules
            # 去除重复
            var_file=/etc/modules && awk '!a[$0]++' ${var_file} >${var_file}.tmp && mv -f ${var_file}.tmp ${var_file}
            sudo sysctl -p
            lsmod | grep ip_vs
            
            
            elif [ "$(get_sys)" == "CentOS" ];then
            cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
            chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
            
        fi
        
        
        elif [ "$1" == "off" ];then
        echo -e "\e[1;31mNot currently supported\e[0m"
    fi
}
