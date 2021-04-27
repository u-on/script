#!/bin/bash
function update_ubuntu() {
    #ubuntu内核版本

    [ -z "${kernel_ver}" ] && kernel_ver=v5.4.7

    tmp_dir=/tmp/my_tmp/kernel/ubuntu
    rm -rf /tmp/my_tmp/kernel/ubuntu
    [ ! -d "${tmp_dir}" ] && mkdir -p "${tmp_dir}"
    #获取版本
    ubkernel_urls=https://kernel.ubuntu.com/~kernel-ppa/mainline/${kernel_ver}
    var_rep=$(curl -A "Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko" https://kernel.ubuntu.com/~kernel-ppa/mainline/${kernel_ver}/ | grep -Eio 'linux-headers-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-[[:digit:]]+-generic_[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-[[:digit:]]+\.[[:digit:]]+_amd64.deb' | sort | uniq)
    var_ver3=$(echo ${var_rep} | grep -Eio '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-[[:digit:]]+' | sort | uniq)
    echo ${var_ver3}
    var_ver1=$(echo ${var_ver3} | grep -Eio '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+' | sort | uniq)
    var_ver2=$(echo ${var_ver3} | grep -Eio '[[:digit:]]{4,}')
    var_date=$(echo ${var_rep} | grep -Eio '\.[[:digit:]]+\_' | grep -Eio '[[:digit:]]+' | sort | uniq)

    kernel_files=(
        linux-modules-${var_ver1}-${var_ver2}-generic_${var_ver1}-${var_ver2}.${var_date}_amd64.deb
        linux-image-unsigned-${var_ver1}-${var_ver2}-generic_${var_ver1}-${var_ver2}.${var_date}_amd64.deb
        linux-headers-${var_ver1}-${var_ver2}-generic_${var_ver1}-${var_ver2}.${var_date}_amd64.deb
        /linux-headers-${var_ver1}-${var_ver2}_${var_ver1}-${var_ver2}.${var_date}_all.deb
    )

    for i in "${kernel_files[@]}"; do

        if which axel &>/dev/null; then
            axel -n 12 -ak "${ubkernel_urls}/${i}" -o "${tmp_dir}/${i}"
        else
            curl -fL --retry 3 "${ubkernel_urls}/${i}" -o "${tmp_dir}/${i}" --create-dirs
        fi
    done

    cd ${tmp_dir} && dpkg -i ./*.deb
    sudo dpkg --get-selections | grep linux-image

}

function update_centons() {
    #centos内核版本
    [ -z "${kernel_ver}" ] && kernel_ver=5.4.95
    tmp_dir=/tmp/my_tmp/kernel/centos
    ctkerner_url="https://elrepo.org/linux/kernel/el7/x86_64/RPMS"
    rm -rf /tmp/my_tmp/kernel/centos
    [ ! -d "${tmp_dir}" ] && mkdir -p "${tmp_dir}"
    kernel_files=(
        kernel-lt-${kernel_ver}-1.el7.elrepo.x86_64.rpm
        kernel-lt-devel-${kernel_ver}-1.el7.elrepo.x86_64.rpm
        kernel-lt-tools-${kernel_ver}-1.el7.elrepo.x86_64.rpm
        kernel-lt-tools-libs-${kernel_ver}-1.el7.elrepo.x86_64.rpm
    )

    for i in "${kernel_files[@]}"; do

        if which axel &>/dev/null; then
            axel -n 12 -ak "${ctkerner_url}/${i}" -o "${tmp_dir}/${i}"
        else
            echo "${ctkerner_url}/${i}"
            curl -fL --retry 3 "${ctkerner_url}/${i}" -o "${tmp_dir}/${i}" --create-dirs
        fi
    done

    cd ${tmp_dir} && yum localinstall -y kernel-lt-${kernel_ver}-1.el7.elrepo.x86_64.rpm kernel-lt-devel-${kernel_ver}-1.el7.elrepo.x86_64.rpm kernel-lt-tools-${kernel_ver}-1.el7.elrepo.x86_64.rpm kernel-lt-tools-libs-${kernel_ver}-1.el7.elrepo.x86_64.rpm
    cd ${tmp_dir} && yum localinstall -y kernel-lt-${kernel_ver}-1.el7.elrepo.x86_64.rpm
    grub2-set-default 0
    rpm -qa | grep kernel
}

while
    getopts :hv: varname
do
    case $varname in

    v)
        echo "$varname"
        kernel_ver=$OPTARG #将选项参数赋值给
        ;;
    h)
        echo "-v <ver>      kernel version.(ubuntu:v5.4.7    centos:5.4.95)"
        exit 0
        ;;
    :)                                                  #当选项后面没有参数时，varname的值被设置为（：），OPTARG的值被设置为选项本身
        echo "the option -$OPTARG require an arguement" #提示用户此选项后面需要一个参数
        exit 1
        ;;

    ?) #当选项不匹配时，varname的值被设置为（？），OPTARG的值被设置为选项本身
        echo "$varname"
        echo "Invaild option: -$OPTARG" #提示用户此选项无效
        echo "-v <kernel version> "
        exit 2
        ;;

    esac
done

if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
    update_centons "$@"
elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
    update_ubuntu "$@"
fi
