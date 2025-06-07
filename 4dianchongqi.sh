#!/bin/bash

# 判断系统类型并配置定时任务
if grep -qEi "centos|rhel|fedora" /etc/os-release; then
    # CentOS/RHEL: 直接写入 /etc/crontab
    echo "0 4 * * * root /sbin/shutdown -r now" | sudo tee -a /etc/crontab >/dev/null
    sudo systemctl restart crond
elif grep -qEi "debian|ubuntu" /etc/os-release; then
    # Debian/Ubuntu: 写入 /etc/crontab（服务名是 cron 而非 cron.service）
    echo "0 4 * * * root /sbin/shutdown -r now" | sudo tee -a /etc/crontab >/dev/null
    sudo systemctl restart cron 2>/dev/null || sudo service cron restart 2>/dev/null
elif grep -q "alpine" /etc/os-release; then
    # Alpine: 使用 crontab -e 方式
    (sudo crontab -l 2>/dev/null; echo "0 4 * * * /sbin/shutdown -r now") | sudo crontab -
    sudo rc-service crond restart 2>/dev/null || sudo rc-service cron restart 2>/dev/null
else
    echo "Unsupported OS. Exit."
    exit 1
fi

# 验证配置
echo "Current cron config:"
if grep -qEi "centos|rhel|fedora|debian|ubuntu" /etc/os-release; then
    sudo tail -n 1 /etc/crontab
else
    sudo crontab -l
fi
