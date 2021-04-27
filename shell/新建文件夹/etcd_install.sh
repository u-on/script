#!/bin/bash
# DATE: 2021-01-01 18:32:01
# FileName:     etcd_install.sh
# Description:  etcd安装
# Depend:       NULL
#
# shellcheck disable=SC1091
# shellcheck disable=SC2034  # Unused variables left for readability
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




etcd_install()
{
    
    
    ##################################etcd下载安装##################################
    
    etcd_down_install()
    {
        if which etcd;then
            return 3
        fi
        axel_install
        
        local latestver=$(curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest | grep tag_name | cut -d '"' -f 4)
        local etcd_ver
        if [ -n "$1" ] ;then
            etcd_ver="$1"
        else
            
            etcd_ver=${latestver}
        fi
        echo -e "\e[1;42minstall Install Ver ${latestver}\e[0m"
        [ ! -d /tmp/my_tmp/etcd/ ] && mkdir -p /tmp/my_tmp/etcd/
        rm -rf /tmp/my_tmp/etcd/*
        
        # 创建etcd数据存储目录
        [ ! -d /var/lib/etcd/ ] && mkdir -p /var/lib/etcd && chmod +x /var/lib/etcd
        # 下载 安装
        cd /tmp/my_tmp/etcd/ && axel -n 12 -ak "https://github.uon.workers.dev/https://github.com/etcd-io/etcd/releases/download/${etcd_ver}/etcd-${etcd_ver}-linux-amd64.tar.gz" && tar -zxvf "etcd-${etcd_ver}-linux-amd64.tar.gz" && cd "etcd-${etcd_ver}-linux-amd64" && cp etcd* /usr/local/bin/ && chmod +x /usr/local/bin/etcd*
    }
    
    
    
    if [ $# -gt  1 ];then
        local var_hosts
        
        for((i=2;i<=$#;i++)){
            var_hosts[i-1]=$(echo "$@"|cut -d ' ' -f $i)
            echo ${var_hosts[i-1]}
        }
    fi
    
    
    
    etcd_down_install "$1"
    
    
}
#################################
function set_etcd_server()
{
    local CA_DIR ETCD_SSL_DIR
    CA_DIR=/etc/kubernetes/ssl
    ETCD_SSL_DIR=/etc/etcd/ssl
cat > /etc/etcd/etcd.service <<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
EnvironmentFile=/etc/etcd/etcd.conf
ExecStart=/usr/local/bin/etcd \
  --cert-file=${ETCD_SSL_DIR}/etcd.pem \
  --key-file=${ETCD_SSL_DIR}/etcd-key.pem \
  --peer-cert-file=${ETCD_SSL_DIR}/etcd.pem \
  --peer-key-file=${ETCD_SSL_DIR}/etcd-key.pem \
  --trusted-ca-file=${CA_DIR}/ca.pem \
  --peer-trusted-ca-file=${CA_DIR}/ca.pem \
  --snapshot-count=50000 \
  --auto-compaction-retention=1 \
  --max-request-bytes=10485760 \
  --quota-backend-bytes=8589934592
Restart=always
RestartSec=15
LimitNOFILE=65536
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target

EOF
    
    ln -sf /etc/etcd/etcd.service  ${SYSTEM_SERVICE_DIR}/etcd.service
    chmod -x ${SYSTEM_SERVICE_DIR}/etcd.service
    
    systemctl daemon-reload
    systemctl stop etcd
    systemctl enable etcd
    systemctl restart etcd
}
etcd_install "$@"