fill=">>>>>>>>>><<<<<<<<<<"


function show_notify_info () {
cat << EOF
|:==============================================:|
#   [o]: show info of os                         #
#   [c]: show info of cpu                        #
#   [d]: show disk usage of root                 #
#   [m]: show memory usage                       #
#   [n]: whether could access to the internet    #
#   [i]: show disk and network IO info           #
#   [q]: quit the script                         #
|:==============================================:|
EOF
}


function os_info() {
    echo -e "${fill} OS Info ${fill} "
    os=$(hostnamectl | grep 'Operating System' | awk -F ": " '{print $2}')
    os="$os $(hostnamectl | grep 'Architecture' | awk -F ":" '{print $2}')"
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
    cpu_load=$(uptime | awk -F ':' '{print $NF}')
    echo -e "CPU 1min, 5min \n 15min load is      : ${cpu_load}"

    cpu_use=$(iostat | awk '{if(NR==4){print $0}}')
    cpu_util=$(echo $(echo $cpu_use) | awk '{print 100-$6"%"}')
    user=$(echo $(echo $cpu_use) | awk '{print $1"%"}')
    sys=$(echo $(echo $cpu_use) | awk '{print $3"%"}')
    iowait=$(echo $(echo $cpu_use) | awk '{print $4"%"}')
    echo "cpu  use: $cpu_util"
    echo "user use: $user"
    echo "sys  use: $sys"
    echo "io   use: $iowait"
    cpu_wait=$(iostat | awk '{if(NR==4){print $NF}}')
    echo "cpu idle: ${cpu_wait}%"

    # top 10
    ps aux | awk ' BEGIN{OFS="\n"} { if($3>0){print "CPU: " $3 "%, MEM: " $4 "%, PID: " $2 ", " $11 }}' | sort -k2 -nr | head -10
}


function disk_info() {
    echo -e "${fill} Disk Info ${fill} "
    dev=/dev/nvme0n1p5
    disk=$(df -h| grep $dev | awk '{print $2}')
    echo "Size of disk is     : ${disk}"
    # 剩余
    disk_free=$(df -h| grep $dev | awk '{print $4}')
    echo "Free disk is        : ${disk_free}"
    # 使用率
    disk_use=$(df -h| grep $dev | awk '{print $(NF-1)}')
    echo "Disk has been used  : ${disk_use}"
}


function mem_info () {
    echo -e "${fill} Memory Info ${fill} "
    mem=$(free -m | awk '{ if(NR==2){print $0} }' | awk '{print $2}')
    # mem=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
    mem=$(echo "scale=2; ${mem}/1024" |bc)
    echo "Total Memory is     : ${mem} GB"
    # 空闲率
    mem_use=$(free -m | awk '{ if(NR==2){print $0} }' | awk '{print $4}')
    mem_use=$(echo "scale=2; ${mem_use}/1024*100" |bc)
    mem_use=$(echo "scale=2; ${mem_use}/${mem}" |bc)
    echo "Memory has free     : ${mem_use} %"
}


function access_network() {
    echo -e "${fill} Network Info ${fill} "
    # 不用获取返回的内容，所以不用 $()
    ping -c4 www.baidu.com &> /dev/null
    if [ $? -eq 0 ] ; then
        echo -e "This PC can\033[32m access \033[0mthe internet." 
    fi
}


function root_check() {
    if [ $USER != root ]; then
        echo "You don't in root"
    fi
}


function install_package() {
    which iostat > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        sleep 1
        echo "ljw" | sudo pacman -S sysstat -y
        echo "-----iostat is installed-----"
        which iostat
    fi
    if ! which ifconfig &> /dev/null; then
        sleep 1
        echo "ljw" | sudo pacman -S net-tools -y
        echo "-----ifconfig is installed-----"
    fi
}


function io_info() {
    echo -e "${fill} IO Info ${fill} "
    io=$(iostat -x -k| awk '{if(NR==7){print $0}}')
    read=$(echo $(echo $io) | awk '{print $3" KB/s"}')
    echo "read  : $read"
    write=$(echo $(echo $io) | awk '{print $8" KB/s"}')
    echo "write : $write"
    wait=$(echo $(echo $io) | awk '{print $(NF-2) " ms"}')
    echo "Avg io wait time: $wait"
    cost=$(echo $(echo $io) | awk '{print $(NF) "%"}')
    echo "IO consume cpu: $cost"
}

# root_check
# install_package


while : ; do
    sleep 1
    # clear
    show_notify_info
    read -p "Please Input a command from [o/c/d/m/n/i/q]: " cmd
    case $cmd in 
        o)
            os_info
            echo -e "\n\n"
            ;;
        c)
            # vmstat
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
        i)
            io_info
            echo -e "\n\n"
            ;;
        q)
            exit 0
            ;;
        *)
            echo "Invalid parameter, please re-input"
    esac
done
