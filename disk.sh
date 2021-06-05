# NF 是最后一个元素，NF-1是倒数第二个，-F 表示以 % 进行分割，分割后 55% 只有第一个元素
disk_free=$(df -h | grep "root" | awk '{print $(NF-1)}' | awk -F '%' '{print $1}')
file=text.log

if [ $disk_free -ge 50 ]; then
    test -d ${file} || touch ${file}
    echo "Disk ${disk_free}% was used" > ${file}
fi