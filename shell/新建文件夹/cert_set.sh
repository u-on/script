#!/bin/bash
# DATE: 2021-01-01 22:37:27
# FileName:     cert_set.sh
# Description:  证书生成工具
# Depend:       cfssl_install.sh
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



function set_ca()
{
    local CA_DIR="$1"
    
    #创建 CA 配置文件 ca-config.json.j2
    if [ ! -f "${CA_DIR}/ca.pem" ];then
        
cat > "${CA_DIR}"/ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF
        
    else
        echo -e "\e[1;33m${CA_DIR}/ca.pem already exists\e[0m"
    fi
    
    
    #创建 CA 证书签名请求 ca-csr.json.j2
    if [ ! -f "${CA_DIR}/ca-csr.json" ];then
cat > "${CA_DIR}"/ca-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Jiangsu",
      "L": "XS",
      "O": "k8s",
      "OU": "System"
    }
  ],
  "ca": {
    "expiry": "876000h"
  }
}
EOF
        
    else
        echo -e "\e[1;33m${CA_DIR}/ca.pem already exists\e[0m"
    fi
    
    
    #生成CA 证书和私钥
    cd "${CA_DIR}" || return 1
    cfssl gencert -initca "${CA_DIR}/ca-csr.json" | cfssljson -bare ca
}


# etcd证书生成
function set_etcd_ssl()
{
    var_nhs=$((${#etcd_hosts[@]} - 1))
    for((i=0;i<=var_nhs;i++))
    do
        if [[ $i < $var_nhs ]];then
            sc=\"${etcd_hosts[i]}\"\,
            
        else
            sc=\"${etcd_hosts[i]}\"
            
        fi
        var_etcd_ssl_hosts=${var_etcd_ssl_hosts}${sc}
        
    done
    
    #创建etcd证书请求
cat > "${ETCD_SSL_DIR}/etcd-csr.json" <<EOF
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
    ${var_etcd_ssl_hosts}
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Jiangsu",
      "L": "Jiangsu",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
    
    #创建证书和私钥
    cd ${ETCD_SSL_DIR} && cfssl gencert \
    -ca=${CA_DIR}/ca.pem \
    -ca-key=${CA_DIR}/ca-key.pem \
    -config=${CA_DIR}/ca-config.json \
    -profile=kubernetes ${ETCD_SSL_DIR}/etcd-csr.json | cfssljson -bare etcd
}

########################  mian  ######################

if [ ! -f "${CA_DIR}/ca.pem" ]; then
    set_ca "$@"
else
    echo -e "\e[1;31mCA证书已存在，请手动删除后再试！\e[0m"
fi

if [ ! -f "${ETCD_SSL_DIR}/etcd-key.pem" ]; then
    set_etcd_ssl "$@"
else
    echo -e "\e[1;31metcd证书已存在，请手动删除后再试！\e[0m"
fi
