#!/bin/bash

# 设置时区（所有系统通用）
if [ -f /etc/os-release ]; then
    sudo timedatectl set-timezone Asia/Shanghai 2>/dev/null || \
    sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
else
    sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
fi

# 判断系统类型并安装依赖
if grep -qEi "debian|ubuntu" /etc/os-release 2>/dev/null; then
    # Debian/Ubuntu 分支
    sudo apt-get update
    sudo apt-get install -y chrony ntpdate
    sudo systemctl restart chrony 2>/dev/null || sudo systemctl restart chronyd
elif grep -qEi "centos|rhel|fedora" /etc/os-release 2>/dev/null; then
    # CentOS/RHEL 分支
    sudo yum install -y chrony ntpdate 2>/dev/null || sudo dnf install -y chrony ntpdate
    sudo systemctl enable --now chronyd
elif grep -q "alpine" /etc/os-release 2>/dev/null; then
    # Alpine 分支
    sudo apk add --no-cache chrony ntpdate
    sudo rc-service chronyd restart 2>/dev/null || sudo rc-service chrony restart
else
    echo "Unsupported OS. Exit."
    exit 1
fi

# 强制同步时间（兼容所有系统）
if command -v chronyc >/dev/null; then
    sudo chronyc -a makestep || sudo ntpdate -u ntp.aliyun.com
else
    sudo ntpdate -u ntp.aliyun.com
fi

# 同步到硬件时钟（Alpine 默认无 hwclock，跳过错误）
sudo hwclock --systohc 2>/dev/null || true

# 验证时间
echo "Current time:"
date
