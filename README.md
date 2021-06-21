自用，本人非运维方向。所以这里只是整理一些功能的 shell 的脚本，记录于此：

1. `dish.sh` 文件下，简单应用，磁盘利用率判断，并写入文件作为警示信息
2. `os-toolkit.sh` 文件下，系统工具箱，获取系统发行版、CPU、内存、磁盘、网络等配置信息
3. `backup.sh` 文件下，备份，删除超过 X 天的文件和保留最近 X 天的文件
4. `loss_ana.sh` 文件下，对 mmdetection 的 loss 结果进行解析、处理和绘图
5. `kill-mmdet.sh` 文件下，mmdetection 经常杀不干净，存在遗留进程占用显存，因此本脚本会杀掉 mmdetection 的所有遗留进程