#!/bin/bash
# DATE: 2021-02-06 16:28:13
# FileName:     NULL
# Description:  NULL
# Depend:       NULL
#

cfssl_install() {
    if ! which cfssl; then
        local down_file=(
            cfssl_linux-amd64
            cfssljson_linux-amd64
            cfssl-certinfo_linux-amd64
        )
        [ ! -d /tmp/my_tmp/cfssl ] && mkdir -p /tmp/my_tmp/cfssl
        for i in "${down_file[@]}"; do
            if which axel &>/dev/null; then
                cd /tmp/my_tmp/cfssl && axel -n 8 -ak https://pkg.cfssl.org/R1.2/"${i}"
            else
                cd /tmp/my_tmp/cfssl && curl -fL --retry 3 -O https://pkg.cfssl.org/R1.2/"${i}" --create-dirs
            fi
            #重命名 去除_linux-amd64
            cd /tmp/my_tmp/cfssl && mv $i ${i%*_linux-amd64}
        done

        cd /tmp/my_tmp/cfssl && mv cfssl* /usr/local/bin/ && chmod +x /usr/local/bin/cfssl*
        rm -rf /tmp/my_tmp/cfssl
        cd ~
    fi
}
cfssl_install
