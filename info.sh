#!/usr/bin/bash

fill='----------------------------'


# 操作系统发行版名称------------------------------------------------------------------------
echo -e "${fill} OS Info ${fill} "
os=$(lsb_release -a | grep "Description" | awk '{print $2 " " $3}')
echo "Operating system is : ${os}"
# 内核版本
kernel=$(cat /proc/version | awk '{print $1 " " $2 " " $3}')
echo "Kernel version is   : ${kernel}"
# 系统运行时间
runtime=$(uptime -p)
echo "The os State is     : ${runtime}"


# CPU 数量与内核---------------------------------------------------------------------------
echo -e "\n${fill} CPU Info ${fill} "
cpu_nums=$(cat /proc/cpuinfo | grep -c "physical id" | uniq | wc -l)
cpu_cores=$(cat /proc/cpuinfo | grep "cpu cores" | uniq | awk '{print $NF}')
cpu_threads=$(grep -c 'model name' /proc/cpuinfo)
echo "CPU number is       : ${cpu_nums}"
echo "CPU cores is        : ${cpu_cores}"
echo "CPU threads  is     : ${cpu_threads}"
# CPU 负载
# https://www.ruanyifeng.com/blog/2011/07/linux_load_average_explained.html
cpu_load=$(uptime | awk -F ':' '{print $4}' | awk -F ', ' '{print $0}')
echo -e "CPU 1min, 5min \n 15min load is      : ${cpu_load}"


# 磁盘空间-----------------------------------------------------------------------
echo -e "\n${fill} Disk Info ${fill} "
disk=$(df -h| grep rootfs | awk '{print $2}')
echo "Size of disk is     : ${disk}"
# 剩余
disk_free=$(df -h| grep rootfs | awk '{print $4}')
echo "Free disk is        : ${disk_free}"
# 使用率
disk_use=$(df -h| grep rootfs | awk '{print $(NF-1)}')
echo "Disk has been used  : ${disk_use}"


# 内存大小-------------------------------------------------------------------
echo -e "\n${fill} Memory Info ${fill} "
mem=$(free -m | grep Mem | awk '{print $2}')
# mem=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
mem=$(echo "scale=2; ${mem}/1024" |bc)
echo "Total Memory is     : ${mem} GB"
# 空闲率
mem_use=$(free -m | grep Mem | awk '{print $4}')
mem_use=$(echo "scale=2; ${mem_use}/1024*100" |bc)
mem_use=$(echo "scale=2; ${mem_use}/${mem}" |bc)
echo "Memory has free     : ${mem_use} %"


# 是否能上网-----------------------------------------------------------------
echo -e "\n${fill} Network Info ${fill} "
# 不用获取返回的内容，所以不用 $()
ping -c1 www.baidu.com &> /dev/null
if [ $? -eq 0 ] ; then
    echo -e "This PC can\033[32m access \033[0mthe internet." 
fi