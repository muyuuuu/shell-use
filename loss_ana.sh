# rpn_cls loss

losses_log=losses.log
cat $1 | grep "Epoch \[" > ${losses_log}
echo "Parse loss from source"

loss_dir=loss
test -d loss || mkdir ${loss_dir}
echo "Create dir to save loss"

cat ${losses_log} | awk -F ', ' '{print $NF}' > ${loss_dir}/loss.log
cat ${losses_log} | awk -F ', ' '{print $(NF-1)}' > ${loss_dir}/loss_bbox.log
cat ${losses_log} | awk -F ', ' '{print $(NF-2)}' > ${loss_dir}/acc.log
cat ${losses_log} | awk -F ', ' '{print $(NF-3)}' > ${loss_dir}/loss_cls.log
cat ${losses_log} | awk -F ', ' '{print $(NF-4)}' > ${loss_dir}/loss_rpn_bbox.log
cat ${losses_log} | awk -F ', ' '{print $(NF-5)}' > ${loss_dir}/loss_rpn_cls.log
echo "Parse sub loss"

echo "Ready to plot figure"
python << EOF
import os, copy
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
plt.style.use('ggplot')

root = 'loss/'

acc_log = []
loss_log = []
loss_bbox_log = []
loss_cls_log = []
loss_rpn_bbox_log = []
loss_rpn_cls_log = []

for i in os.listdir(root):
    tmp = []
    with open(root + i, 'r') as f:
        lines = f.readlines()
        for line in lines:
            line = line.split(': ')
            s = float(line[1])
            tmp.append(s)
    if i == 'acc.log':
        acc_log = np.array(copy.deepcopy(tmp))
    elif i == 'loss.log':
        loss_log = np.array(copy.deepcopy(tmp))
    elif i == 'loss_bbox.log':
        loss_bbox_log = np.array(copy.deepcopy(tmp))
    elif i == 'loss_cls.log':
        loss_cls_log = np.array(copy.deepcopy(tmp))
    elif i == 'loss_rpn_bbox.log':
        loss_rpn_bbox_log = np.array(copy.deepcopy(tmp))
    elif i  == 'loss_rpn_cls.log':
        loss_rpn_cls_log = np.array(copy.deepcopy(tmp))


x = np.linspace(0, 1000, len(loss_rpn_cls_log))

fig, ax = plt.subplots(figsize = (30, 15), nrows = 2, ncols = 3)
ax[0][0].plot(x, acc_log, label='acc')
ax[0][1].plot(x, loss_log, label='loss')
ax[0][2].plot(x, loss_cls_log, label='cls_loss')
ax[1][0].plot(x, loss_bbox_log, label='bbox_loss')
ax[1][1].plot(x, loss_rpn_cls_log, label='rpn_cls_loss')
ax[1][2].plot(x, loss_rpn_bbox_log, label='rpn_bbox_loss')

for i in range(2):
    for j in range(3):
        ax[i][j].legend(fontsize=15)

plt.savefig('loss.png', dpi=300, bbox_inches='tight')
EOF