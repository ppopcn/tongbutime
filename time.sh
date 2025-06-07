#!/bin/bash

# 设置时区（所有系统通用）
sudo timedatectl set-timezone Asia/Shanghai

# 判断系统类型并安装依赖
if grep -qEi "debian|ubuntu" /etc/os-release; then
    # Debian/Ubuntu 分支
    sudo apt-get update
    sudo apt-get install -y chrony ntpdate
    sudo systemctl restart chrony 2>/dev/null || sudo systemctl restart chronyd
elif grep -qEi "centos|rhel|fedora" /etc/os-release; then
    # CentOS/RHEL 分支
    sudo yum install -y chrony ntpdate
    sudo systemctl enable --now chronyd
else
    echo "Unsupported OS. Exit."
    exit 1
fi

# 强制同步时间（兼容所有系统）
(sudo chronyc -a makestep || sudo ntpdate -u ntp.aliyun.com) && \
sudo hwclock --systohc

# 验证时间
echo "Current time:"
date
