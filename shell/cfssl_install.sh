#!/bin/bash
# DATE: 2021-05-05
# FileName:     cfssl_install.sh
# Description:  NULL
# Depend:       NULL
#           

cfssl_install() {
    if ! which cfssl; then

        latestver=$(curl -s https://api.github.com/repos/cloudflare/cfssl/releases/latest | grep tag_name | cut -d '"' -f 4)
        ver=${latestver:1}

        local down_file=(
            cfssl_"${ver}"_linux_amd64
            cfssljson_"${ver}"_linux_amd64
            cfssl-certinfo_"${ver}"_linux_amd64
        )

        [ ! -d /tmp/my_tmp/cfssl ] && mkdir -p /tmp/my_tmp/cfssl

        for i in "${down_file[@]}"; do
            if which axel &>/dev/null; then
                cd /tmp/my_tmp/cfssl && axel -n 8 -ak "${mirrorurl}"https://github.com/cloudflare/cfssl/releases/download/"${latestver}"/"${i}"
            else
                cd /tmp/my_tmp/cfssl && curl -fL --retry 3 -O "${mirrorurl}"https://github.com/cloudflare/cfssl/releases/download/"${latestver}"/"${i}" --create-dirs
            fi
            #重命名 去除_linux-amd64
            cd /tmp/my_tmp/cfssl && mv "$i" "${i%*_${ver}_linux_amd64}"
        done

        cd /tmp/my_tmp/cfssl && mv cfssl* /usr/local/bin/ && chmod +x /usr/local/bin/cfssl*
        rm -rf /tmp/my_tmp/cfssl
        cd ~ || exit
    fi
}

cfssl_uninstall() {
    rm -f /usr/local/bin/cfssl
    rm -f /usr/local/bin/cfssljson
    rm -f /usr/local/bin/cfssl-certinfo
    echo -e "\e[1;32mDeleted!\e[0m"

}

while
    # 可选参数有u和m和i和h
    getopts :umih OPT
do
    case $OPT in

    m)
        mirrorurl="https://github.uon.workers.dev/"
        ;;

    u)
        cfssl_uninstall
        ;;

    i)
        cfssl_install
        ;;

    h)
        dis=$(
            cat <<-EOF

示例：
        -mi     # 镜像加速安装cfssl
        -u      # 卸载
        -mui    # 升级

参数：
        -m      # 镜像加速
        -i      # 安装
        -u      # 卸载
        -mi     # 镜像加速安装，m参数需在最前
 
 
EOF
        )

        echo "${dis}"
        ;;

    :)                                                  #当选项后面没有参数时，OPT的值被设置为（：），OPTARG的值被设置为选项本身
        echo "the option -$OPTARG require an arguement" #提示用户此选项后面需要一个参数
        exit 1
        ;;

    ?)                                  #当选项不匹配时，OPT的值被设置为（？），OPTARG的值被设置为选项本身
        echo "Invaild option: -$OPTARG" #提示用户此选项无效
        echo "-v <kernel version> "
        exit 2
        ;;

    esac

done
