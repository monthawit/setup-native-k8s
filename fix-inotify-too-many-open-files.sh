#!/bin/bash

# 
# กำหนดค่าที่ต้องการตั้งตั้ง
WATCHES_LIMIT=524288
INSTANCES_LIMIT=512

echo "=========================================="
echo "  Fixing fsnotify: Too many open files    "
echo "=========================================="

# 1. เพิ่มค่าแบบชั่วคราวให้ระบบใช้งานได้ทันที
echo "[+] Applying temporary limits..."
sudo sysctl fs.inotify.max_user_watches=$WATCHES_LIMIT
sudo sysctl fs.inotify.max_user_instances=$INSTANCES_LIMIT

# 2. ทำการเพิ่มค่าลงใน /etc/sysctl.conf แบบถาวร (ถ้ายังไม่มีอยู่)
SYSCTL_CONF="/etc/sysctl.conf"

echo "[+] Making changes permanent in $SYSCTL_CONF..."

# ตรวจสอบและเพิ่ม max_user_watches
if grep -q "fs.inotify.max_user_watches" "$SYSCTL_CONF"; then
    echo "[-] fs.inotify.max_user_watches already exists. Updating value..."
    sudo sed -i "s/^fs.inotify.max_user_watches.*/fs.inotify.max_user_watches=$WATCHES_LIMIT/" "$SYSCTL_CONF"
else
    echo "fs.inotify.max_user_watches=$WATCHES_LIMIT" | sudo tee -a "$SYSCTL_CONF" > /dev/null
fi

# ตรวจสอบและเพิ่ม max_user_instances
if grep -q "fs.inotify.max_user_instances" "$SYSCTL_CONF"; then
    echo "[-] fs.inotify.max_user_instances already exists. Updating value..."
    sudo sed -i "s/^fs.inotify.max_user_instances.*/fs.inotify.max_user_instances=$INSTANCES_LIMIT/" "$SYSCTL_CONF"
else
    echo "fs.inotify.max_user_instances=$INSTANCES_LIMIT" | sudo tee -a "$SYSCTL_CONF" > /dev/null
fi

# 3. สั่ง Reload คอนฟิกเพื่อให้มั่นใจว่าระบบดึงค่าไปใช้จริง
echo "[+] Reloading sysctl configuration..."
sudo sysctl -p

echo "=========================================="
echo "  Done! Please restart your application.  "
echo "=========================================="
