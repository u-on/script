#!/bin/bash
function axel_install() {
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
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

    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        apt install -y axel

    fi
}

if ! which axel 2>/dev/null; then
    axel_install
else
    echo axel已经存在
fi
