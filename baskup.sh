# 删除大于两天的，不要使用当前路径
find ~/github/shell-use -mtime +2 |xargs rm -rvf

# 保留最近两天的，跳过节假日、周六日
# 按时间排序、行号大于 2、的删除
ls -t ~/shell-learn/01-basic/*.sh | awk '{if(NR>2) {print "rm -rf: " $0}}' | xargs rm -rvf