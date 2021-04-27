#!/bin/bash
# 配置安装参数

while
    getopts :hv: varname
do
    case $varname in

    v)
        echo "$varname"
        docker_ver=$OPTARG #将选项参数赋值给
        ;;
    h)
        echo "默认docker版本19.0.9"
        echo "-v <版本号>       格式：19.0.9 "
        exit 0
        ;;

    :)                                                  #当选项后面没有参数时，varname的值被设置为（：），OPTARG的值被设置为选项本身
        echo "the option -$OPTARG require an arguement" #提示用户此选项后面需要一个参数
        exit 1
        ;;

    ?) #当选项不匹配时，varname的值被设置为（？），OPTARG的值被设置为选项本身
        echo "Invaild option: -$OPTARG" #提示用户此选项无效
        echo "-v <kernel version> "
        exit 2
        ;;

    esac
done

[ -z "${docker_ver}" ] && docker_ver=19.03.9

[ ! -d /tmp/my_tmp/docker ] && mkdir -p /tmp/my_tmp/docker
if which axel &>/dev/null; then
    cd /tmp/my_tmp/docker && axel -n 16 -ak https://download.docker.com/linux/static/stable/x86_64/docker-${docker_ver}.tgz
else
    cd /tmp/my_tmp/docker && curl -fL --retry 3 -O https://download.docker.com/linux/static/stable/x86_64/docker-${docker_ver}.tgz --create-dirs
fi
tar -xvf docker-${docker_ver}.tgz
cp docker/* /usr/bin/
rm -rf /tmp/my_tmp/docker

# 写服务配置文件
cat >/etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP \$MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOF

# 设置权限
chmod +x /etc/systemd/system/docker.service
# 启动
systemctl daemon-reload
systemctl enable docker.service
systemctl start docker
# 查看Docker状态
systemctl status docker
