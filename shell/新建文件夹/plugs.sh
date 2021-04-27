#!/bin/bash

# source plugs.sh &&
##################################root检测##################################
[[ $(id -u) != 0 ]] && echo -e "\n please use \e[1;41mroot\e[0m user login\n" && exit 1

# ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
# 获取系统信息
##
#  返回值
#  var_sys       系统名称   CentOS|RHEL|Ubuntu|Debian|Fedora|Raspbian|Aliyun|unknow
#  var_bit       系统位数   64|32
#  var_pm        install 命令   yum|apt
mirrors_url=https://github.uon.workers.dev/https://github.com/igread/d/releases/download/mirrors
function get-sys()
{
    if [ "$1" = "-h" ];then
        echo "获取系统名称、install 命令apt|yum"
        echo "返回值："
        echo -e "\e[1;32m\${var_sys}\e[0m       系统名称"
        echo -e "\e[1;32m\${var_bit}\e[0m       系统位数32|64"
        echo -e "\e[1;32m\${var_pm}\e[0m        install 命令"
    else
        if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
            DISTRO='CentOS'
            PM='yum'
            elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
            DISTRO='RHEL'
            PM='yum'
            elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
            DISTRO='Aliyun'
            PM='yum'
            elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
            DISTRO='Fedora'
            PM='yum'
            elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
            DISTRO='Debian'
            PM='apt'
            elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
            DISTRO='Ubuntu'
            PM='apt'
            elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
            DISTRO='Raspbian'
            PM='apt'
        else
            DISTRO='unknow'
        fi
        bit=$(uname -m)
        if [[ ${bit} = "x86_64" ]]; then
            bit="64"
        else
            bit="32"
        fi
        
        ###返回值
        var_sys=${DISTRO}
        var_pm=${PM}
        var_bit=${bit}
    fi
}
# ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

##################################安装axel##################################
function install_axel()
{
    get-sys "$@"
    
    
    var_tmp=$(which axel)
    if [ $? -ne 0 ];then
        echo install axel
        if [ "$var_sys" == "Ubuntu" ];then
            apt install -y axel
            
            elif [ "$var_sys" == "CentOS" ];then
            yum -y install gcc openssl openssl-devel
            
            local latestver=$(curl -s https://api.github.com/repos/axel-download-accelerator/axel/releases/latest | grep tag_name | cut -d '"' -f 4)
            local latestver2=$(echo ${latestver} | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
            local ufile=axel-${latestver2}.tar.gz
            
            local down_url=https://github.com/axel-download-accelerator/axel/releases/download/${latestver}/axel-${latestver2}.tar.gz
            
            [ ! -d "/tmp/my_tmp/axel" ] && mkdir -p "/tmp/my_tmp/axel"
            curl -fLk --retry 3 ${down_url} -o /tmp/my_tmp/axel/${ufile} --create-dirs
            echo $(ls /tmp/my_tmp/axel)
            cd /tmp/my_tmp/axel && tar -zxvf ${ufile} -C /tmp/my_tmp/axel
            cd axel-${latestver2}
            ./configure && make && make install
            
            rm -rf /tmp/my_tmp/axel/
            cd ~
        fi
    fi
}







##################################iptables##################################
function set-iptables()
{
    iptables -F \
    && iptables -t nat -F \
    && iptables -t mangle -F \
    && iptables -X \
    && update-alternatives --set iptables /usr/sbin/iptables-legacy
}


##################################swap设置##################################
# swap开关
# set-swap [on|off]
##
function set-swap()
{
    if [ "$1" == "off" ];then
        swapoff -a && sysctl -w vm.swappiness=0
        tmp_fh1=$?
        sed -ri 's/^\/swap.*swap.*/#&/' /etc/fstab
        tmp_fh2=$?
        tmp_fh3=$((tmp_fh1+tmp_fh2))
        [[ $tmp_fh3 == 0 ]] && echo -e "\e[1;32m关闭Success\e[0m"
        [[ $tmp_fh3 == 0 ]] || echo -e "\e[1;31m关闭Failed\e[0m"
        
        elif [ "$1" == "on" ];then
        sed -ri 's/^\#(\/swap.*swap.*)/\1/' /etc/fstab
        tmp_fh1=$?
        swapon -a && sysctl -w vm.swappiness=60
        tmp_fh2=$?
        tmp_fh3=$((tmp_fh1+tmp_fh2))
        [[ $tmp_fh3 == 0 ]] && echo -e "\e[1;32m开启Success\e[0m"
        [[ $tmp_fh3 == 0 ]] || echo -e "\e[1;31m开启Failed\e[0m"
    fi
}



##################################防火墙开关##################################
# set-firewall [on|off]
function set-firewall()
{
    get-sys "$@"
    echo $var_sys
    if [ "$1" == "off" ];then
        
        if [ $var_sys == "CentOS" ];then
            systemctl stop firewalld
            systemctl  disable firewalld
            systemctl status firewalld
            
            elif [ $var_sys == "Ubuntu" ];then
            ufw disable
            ufw status
            
        fi
        
        elif [ "$1" == "on" ];then
        
        if [ $var_sys == "CentOS" ];then
            systemctl start firewalld
            systemctl  enable firewalld
            systemctl status firewalld
            
            elif [ $var_sys == "Ubuntu" ];then
            echo -e "\e[1;31m此操作将中断ssh连接，是否继续？（y|n）\e[0m"
            ufw enable >/dev/null
            ufw status
            
        fi
    fi
}

##################################启用root用户##################################
# 启用|关闭 root用户
# root-user [on|off]
function root-user()
{
    if [ "$1" == "off" ];then
        sed -ri 's/^PermitRootLogin.*/#&/g' /etc/ssh/sshd_config
        sed -ri 's/^LoginGraceTime.*/#&/g' /etc/ssh/sshd_config
        sed -ri 's/^StrictModes.*/#&/g' /etc/ssh/sshd_config
        grep -Eqi "^#PermitRootLogin.*" /etc/ssh/sshd_config
        tmp_fh=$?
        [[ $tmp_fh == 0 ]] && echo -e "\e[1;32mSuccess\e[0m"
        [[ $tmp_fh == 0 ]] || echo -e "\e[1;31mFailed\e[0m"
        systemctl restart sshd
        
        elif [ "$1" == "on" ];then
        sed -ri 's/^#(PermitRootLogin).*/\1 yes/g' /etc/ssh/sshd_config
        sed -ri 's/^#(LoginGraceTime).*/\1 2m/g' /etc/ssh/sshd_config
        sed -ri 's/^#(StrictModes).*/\1 yes/g' /etc/ssh/sshd_config
        grep -Eqi "^PermitRootLogin.*yes" /etc/ssh/sshd_config
        tmp_fh=$?
        [[ $tmp_fh == 0 ]] && echo -e "\e[1;32mSuccess\e[0m"
        [[ $tmp_fh == 0 ]] || echo -e "\e[1;31mFailed\e[0m"
        systemctl restart sshd
    fi
}



##################################更新源##################################
# update-sources
function update-sources()
{
    get-sys "$@"
    
    if [ $var_sys == "CentOS" ];then
        curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
        sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
        
        elif [ $var_sys == "Ubuntu" ];then
            cp /etc/apt/sources.list /etc/apt/sources.list.$(date  +'%Y%m%d%H%M%S').bak && cat > /etc/apt/sources.list <<EOF
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
        [[ $tmp_fh == 0 ]] && echo -e "\e[1;32mSuccess\e[0m"
        [[ $tmp_fh == 0 ]] || echo -e "\e[1;31mFailed\e[0m"
        apt update
        apt -y upgrade
        
        
    fi
}


##################################ssh加速##################################
# 设置ssh的dns解析
# ssh-dns [on|off]
function ssh-dns()
{
    if [ "$1" == "off" ];then
        sed -ri 's/.*(UseDNS).*/\1 no/g' /etc/ssh/sshd_config
        grep -Eqi "UseDNS no" /etc/ssh/sshd_config
        tmp_fh=$?
        [[ $tmp_fh == 0 ]] && echo -e "\e[1;32mSuccess\e[0m"
        [[ $tmp_fh == 0 ]] || echo -e "\e[1;31mFailed\e[0m"
        systemctl restart sshd
        
        elif [ "$1" == "on" ];then
        sed -ri 's/.*(UseDNS).*/\1 yes/g' /etc/ssh/sshd_config
        grep -Eqi "UseDNS yes" /etc/ssh/sshd_config
        tmp_fh=$?
        [[ $tmp_fh == 0 ]] && echo -e "\e[1;32mSuccess\e[0m"
        [[ $tmp_fh == 0 ]] || echo -e "\e[1;31mFailed\e[0m"
        systemctl restart sshd
    fi
}


# ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
# 设置时区为Asia/Shanghai
# set-timezone
function set-timezone()
{
    timedatectl set-timezone Asia/Shanghai
}



##################################install 基本工具##################################
#  install 基本工具（必须）
function install-tools()
{
    
    get-sys "$@"
    
    if [ $var_sys == "Ubuntu" ];then
        
        
        apt remove -y ufw \
        lxd \
        lxd-client \
        lxcfs \
        lxc-common
        
        apt update && apt -y upgrade
        apt install -y vim \
        curl \
        apt-transport-https \
        ca-certificates \
        software-properties-common
        
    else
        echo echo -e "\e[1;31mNot currently supported\e[0m"
        
    fi
    
}

# ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑


# ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
# 开启ipvs

#查看IPVS是否启动
# lsmod | grep ip_vs
function set-ipvs ()
{
    
    if [ "$1" == "on" ];then
        
        
        
        get-sys "$@"
        if [ "$var_sys" == "Ubuntu" ];then
            
            for i in $(ls /lib/modules/$(uname -r)/kernel/net/netfilter/ipvs|grep -o "^[^.]*");do echo $i; /sbin/modinfo -F filename $i >/dev/null 2>&1 && /sbin/modprobe $i; done
            ls /lib/modules/$(uname -r)/kernel/net/netfilter/ipvs|grep -o "^[^.]*" >> /etc/modules
            # 去除重复
            var_file=/etc/modules && awk '!a[$0]++' ${var_file} >${var_file}.tmp && mv -f ${var_file}.tmp ${var_file}
            sudo sysctl -p
            lsmod | grep ip_vs
            
            
            elif [ "$var_sys" == "CentOS" ];then
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

# ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑


# ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
# br_netfilter

#查看IPVS是否启动
# lsmod | grep br_netfilter
function set-br_netfilter ()
{
    
    if [ "$1" == "on" ];then
        
        
        
        get-sys "$@"
        if [ "$var_sys" == "Ubuntu" ];then
            
            for i in $(ls /lib/modules/$(uname -r)/kernel/net/bridge|grep -o 'br_.*'|grep -o "^[^.]*");do echo $i; /sbin/modinfo -F filename $i >/dev/null 2>&1 && /sbin/modprobe $i; done
            ls /lib/modules/$(uname -r)/kernel/net/bridge|grep -o 'br_.*'|grep -o "^[^.]*" >> /etc/modules
            # 去除重复
            var_file=/etc/modules && awk '!a[$0]++' ${var_file} >${var_file}.tmp && mv -f ${var_file}.tmp ${var_file}
            sudo sysctl -p
            lsmod | grep br_netfilter
            
            
            elif [ "$var_sys" == "CentOS" ];then
            
            function zs-注释--()
            {
    cat > /etc/sysconfig/modules/br_netfilter.modules <<EOF
#!/bin/bash
modprobe -- br_netfilter
EOF
                chmod 755 /etc/sysconfig/modules/br_netfilter.modules && bash /etc/sysconfig/modules/br_netfilter.modules && lsmod | grep br_netfilter
            }
            echo Not currently supported
            
            
        fi
        
        
        elif [ "$1" == "off" ];then
        echo -e "\e[1;31mNot currently supported\e[0m"
    fi
}

# ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑



##################################禁用selinux（必须）##################################
# 查看selinux状态   sestatus
function set-selinux()
{
    
    get-sys "$@"
    
    if [ $var_sys == "CentOS" ];then
        
        
        if [ "$1" == "on" ];then
            setenforce 1
            sed -ri 's/^(SELINUX=).*/\1 enforcing/g' /etc/selinux/config
            elif [ "$1" == "off" ];then
            setenforce 0
            sed -ri 's/^(SELINUX=).*/\1 disabled/g' /etc/selinux/config
        fi
        
    else
        echo -e "\e[1;31mNot currently supported\e[0m"
        
    fi
    
    
}


# ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓     初始优化      ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
#
function set-youhua()
{
    get-sys "$@"
    #### 优化内核参数（必须）
    # √ 关闭net.ipv4. tcp_tw_recycle，否则与 NAT 冲突，可能导致服务不通
    cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv4.neigh.default.gc_thresh1=1024
net.ipv4.neigh.default.gc_thresh1=2048
net.ipv4.neigh.default.gc_thresh1=4096
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF
    
    sysctl -p /etc/sysctl.d/kubernetes.conf
    
    
    # X 处理器性能模式配置-（必须）
    
    # @@@!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    echo install cpufrequtils
    if [ $var_sys == "Ubuntu" ];then
        
        sudo apt-get install -y cpufrequtils
        echo conservative > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        sudo cpufreq-set -g performance
        apt install -y sysfsutils
        
        elif [ $var_sys == "CentOS" ];then
        yum install -y sysfsutils
        
    else
        echo -e "\e[1;31mNot currently supported\e[0m"
        
    fi
    
    
    
    #@!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    # √ 禁用巨大页面置-（必须）
    echo Disable huge page placement
    if [ $var_sys == "Ubuntu" ];then
        echo 'never' | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
        echo 'never' | sudo tee /sys/kernel/mm/transparent_hugepage/defrag
        if grep -Eqi "^transparent_hugepage=.*" /etc/default/grub;then
            sed -ri 's/(^transparent_hugepage=).*/\1never/g' /etc/default/grub
        else
            sed -ri 's/(^GRUB_CMDLINE_LINUX_DEFAULT.*)/\1\ntransparent_hugepage=never/g' /etc/default/grub
        fi
        update-grub
        elif [ $var_sys == "CentOS" ];then
        echo Not currently supported
    else
        echo -e "\e[1;31mNot currently supported\e[0m"
    fi
    
    ##############################################取消打开文件数限制 用户进程限制-（必须）
    # √
    # 取消用户进程限制
    
    # 除root用户外
    echo Cancel user process restriction
    if ! grep -Eqi "^\*.*soft.*nofile.*" /etc/security/limits.conf;then
        echo -e "* soft nofile 204800" >> /etc/security/limits.conf
    else
        sed -ri 's/^\s*\*(\s*|\t*)soft(\s*|\t*)nofile(\s*|\t*).*/* soft nofile 204800/gm' /etc/security/limits.conf
    fi
    if ! grep -Eqi "\*.*hard.*nofile.*" /etc/security/limits.conf;then
        echo -e "* hard nofile 204800">> /etc/security/limits.conf
    else
        sed -ri 's/^\s*\*(\s*|\t*)hard(\s*|\t*)nofile(\s*|\t*).*/* hard nofile 204800/gm' /etc/security/limits.conf
    fi
    if ! grep -Eqi "\*.*soft.*nproc.*" /etc/security/limits.conf;then
        echo -e "* soft nproc 204800">> /etc/security/limits.conf
    else
        sed -ri 's/^\s*\*(\s*|\t*)soft(\s*|\t*)nproc(\s*|\t*).*/* soft nproc 204800/gm' /etc/security/limits.conf
    fi
    if ! grep -Eqi "\*.*hard.*nproc.*" /etc/security/limits.conf;then
        echo -e "* hard nproc 204800">> /etc/security/limits.conf
    else
        sed -ri 's/^\s*\*(\s*|\t*)hard(\s*|\t*)nproc(\s*|\t*).*/* hard nproc 204800/gm' /etc/security/limits.conf
    fi
    # root
    if ! grep -Eqi "^root.*soft.*nofile.*" /etc/security/limits.conf;then
        echo -e "root soft nofile 204800" >> /etc/security/limits.conf
    else
        sed -ri 's/^root(\s*|\t*)soft(\s*|\t*)nofile(\s*|\t*).*/root soft nofile 204800/gm' /etc/security/limits.conf
    fi
    if ! grep -Eqi "^root.*hard.*nofile.*" /etc/security/limits.conf;then
        echo -e "root hard nofile 204800">> /etc/security/limits.conf
    else
        sed -ri 's/^root(\s*|\t*)hard(\s*|\t*)nofile(\s*|\t*).*/root hard nofile 204800/gm' /etc/security/limits.conf
    fi
    if ! grep -Eqi "^root.*soft.*nproc.*" /etc/security/limits.conf;then
        echo -e "root soft nproc 204800">> /etc/security/limits.conf
    else
        sed -ri 's/^root(\s*|\t*)soft(\s*|\t*)nproc(\s*|\t*).*/root soft nproc 204800/gm' /etc/security/limits.conf
    fi
    if ! grep -Eqi "^root.*hard.*nproc.*" /etc/security/limits.conf;then
        echo -e "root hard nproc 204800">> /etc/security/limits.conf
    else
        sed -ri 's/^root(\s*|\t*)hard(\s*|\t*)nproc(\s*|\t*).*/root hard nproc 204800/gm' /etc/security/limits.conf
    fi
    #################################################################################
    
    
    
    ##删除ubuntu默认install
    if [ $var_sys == "Ubuntu" ];then
        echo 删除ubuntu默认install
        sudo apt-get install -y cpufrequtils
        echo conservative > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        sudo cpufreq-set -g performance
        apt install -y sysfsutils
    fi
    #install  ubuntu/debian基础软件
    if [ $var_sys == "Ubuntu" ];then
        echo install  ubuntu/debian基础软件
        apt install -y bash-completion \
        conntrack \
        ipset \
        ipvsadm \
        jq \
        libseccomp2 \
        nfs-common \
        psmisc \
        rsync \
        socat \
        
    fi
    
    if [ $var_sys == "Ubuntu" ];then
        echo ubuntu 优化设置 journal 日志  优化设置 journal 日志相关，避免日志重复搜集，浪费系统资源
        # 准备 journal 日志相关目录
        mkdir -p /etc/systemd/journald.conf.d
        mkdir -p /var/log/journal
        # 优化设置 journal 日志
        cat >/etc/systemd/journald.conf.d/95-k8s-journald.conf <<EOF
[Journal]
# 持久化保存到磁盘
Storage=persistent
# 最大占用空间 2G
SystemMaxUse=2G
# 单日志文件最大 200M
SystemMaxFileSize=200M
# 日志保存时间 2 周
MaxRetentionSec=2week
# 禁止转发
ForwardToSyslog=no
ForwardToWall=no
EOF
        # 重启 journald 服务
        systemctl restart systemd-journald
    fi
    
}


# ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
# 更新内核
# 可选参数 版本号   ubuntu需要根据https://kernel.ubuntu.com/~kernel-ppa/mainline/网页显示出的版本号
function kernel-update()
{
    get-sys "$@"
    install_axel
    ###### Ubuntu
    if [ "$var_sys" == "Ubuntu" ];then
        
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
        
        ####### CentOS
        elif [ "$var_sys" == "CentOS" ];then
        
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
        
    else
        echo Not currently supported
    fi
    
}


# 删除旧内核
function kernel-del()
{
    get-sys "$@"
    if [ "$var_sys" == "Ubuntu" ];then
        
        sudo apt remove --purge -y $(dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d')
        
        # sudo apt remove -y $(dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d')
        sudo dpkg --get-selections |grep linux-
        
    else
        echo Not currently supported
    fi
    
}

# ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

## 内核查询
function ls_kernel()
{
    get-sys "$@"
    if [ "$var_sys" == "Ubuntu" ];then
        sudo dpkg --get-selections |grep linux-
        elif [ "$var_sys" == "CentOS" ];then
        rpm -qa | grep kernel
    fi
}


# ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

#chrony 时间同步
function install-chrony()
{
    get-sys "$@"
    #卸载ntp
    apt remove -y ntp
    
    if [ "$var_sys" == "Ubuntu" ];then
        # install
        apt install -y chrony
        # 写配置文件
        [[ ! -d "/etc/chrony/" ]] &&  mkdir -p "/etc/chrony/"
        
    cat > /etc/chrony/chrony.conf <<EOF
# Welcome to the chrony configuration file. See chrony.conf(5) for more
# information about usuable directives.

# This will use (up to):
# - 4 sources from ntp.ubuntu.com which some are ipv6 enabled
# - 2 sources from 2.ubuntu.pool.ntp.org which is ipv6 enabled as well
# - 1 source from [01].ubuntu.pool.ntp.org each (ipv4 only atm)
# This means by default, up to 6 dual-stack and up to 2 additional IPv4-only
# sources will be used.
# At the same time it retains some protection against one of the entries being
# down (compare to just using one of the lines). See (LP: #1754358) for the
# discussion.
#
# About using servers from the NTP Pool Project in general see (LP: #104525).
# Approved by Ubuntu Technical Board on 2011-02-08.
# See http://www.pool.ntp.org/join.html for more information.
pool ntp.aliyun.com             iburst
pool time1.cloud.tencent.com    iburst
pool cn.ntp.org.cn              iburst
pool cn.pool.ntp.org            iburst

#不指定就是允许所有
# allow 10.10.0.0/16

# 公网离线继续为内网提供同步服务
local stratum 10
# This directive specify the location of the file containing ID/key pairs for
# NTP authentication.
keyfile /etc/chrony/chrony.keys

# This directive specify the file into which chronyd will store the rate
# information.
driftfile /var/lib/chrony/chrony.drift

# Uncomment the following line to turn logging on.
#log tracking measurements statistics

# Log files location.
logdir /var/log/chrony

# Stop bad estimates upsetting machine clock.
maxupdateskew 100.0

# This directive enables kernel synchronisation (every 11 minutes) of the
# real-time clock. Note that it can’t be used along with the 'rtcfile' directive.
rtcsync

# Step the system clock instead of slewing it if the adjustment is larger than
# one second, but only in the first three clock updates.
makestep 1 3

EOF
        systemctl start chrony
        systemctl restart chrony
        systemctl enable chrony
        # 查看同步状态
        chronyc sourcestats
        elif [ "$var_sys" == "CentOS" ];then
        echo  Not currently supported
    fi
    
    
}
