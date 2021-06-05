fill=">>>>>>>>>><<<<<<<<<<"


function show_notify_info () {
cat << EOF
|:==========================:|
    [o]: show info of os
    [c]: show info of cpu
    [d]: show disk usage of root
    [m]: show memory usage
    [n]: whether could access to the internet
    [q]: quit the script
|:==========================:|
EOF
}


function os_info() {
    echo -e "${fill} OS Info ${fill} "
    os=$(lsb_release -a | grep "Description" | awk '{print $2 " " $3}')
    echo "Operating system is : ${os}"
    # 内核版本
    kernel=$(cat /proc/version | awk '{print $1 " " $2 " " $3}')
    echo "Kernel version is   : ${kernel}"
    # 系统运行时间
    runtime=$(uptime -p)
    echo "The os State is     : ${runtime}"
}


function cpu_info() {
    echo -e "${fill} CPU Info ${fill} "
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
}


function disk_info() {
    echo -e "${fill} Disk Info ${fill} "
    disk=$(df -h| grep rootfs | awk '{print $2}')
    echo "Size of disk is     : ${disk}"
    # 剩余
    disk_free=$(df -h| grep rootfs | awk '{print $4}')
    echo "Free disk is        : ${disk_free}"
    # 使用率
    disk_use=$(df -h| grep rootfs | awk '{print $(NF-1)}')
    echo "Disk has been used  : ${disk_use}"
}


function mem_info () {
    echo -e "${fill} Memory Info ${fill} "
    mem=$(free -m | grep Mem | awk '{print $2}')
    # mem=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
    mem=$(echo "scale=2; ${mem}/1024" |bc)
    echo "Total Memory is     : ${mem} GB"
    # 空闲率
    mem_use=$(free -m | grep Mem | awk '{print $4}')
    mem_use=$(echo "scale=2; ${mem_use}/1024*100" |bc)
    mem_use=$(echo "scale=2; ${mem_use}/${mem}" |bc)
    echo "Memory has free     : ${mem_use} %"
}


function access_network() {
    echo -e "${fill} Network Info ${fill} "
    # 不用获取返回的内容，所以不用 $()
    ping -c1 www.baidu.com &> /dev/null
    if [ $? -eq 0 ] ; then
        echo -e "This PC can\033[32m access \033[0mthe internet." 
    fi
}


while : ; do
    show_notify_info
    read -p "Please Input a command from [o/c/d/m/n/q]: " cmd
    case $cmd in 
        o)
            os_info
            echo -e "\n\n"
            ;;
        c)
            cpu_info
            echo -e "\n\n"
            ;;
        d)
            disk_info
            echo -e "\n\n"
            ;;
        m)
            mem_info
            echo -e "\n\n"
            ;;
        n)
            access_network
            echo -e "\n\n"
            ;;
        q)
            exit 0
            ;;
        *)
            echo "Invalid parameter, please re-input"
    esac
done
