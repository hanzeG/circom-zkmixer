import matplotlib.pyplot as plt
import numpy as np

# 定义三个函数
def hedera(x):
    return ((1/x)/2200)*319

def xrpl(x):
    return ((1/x)/75)*63

def bnb(x):
    return ((1/x)/1000)*1000

# 生成x轴数据
x_values = np.linspace(1, 3600, 1000)  # 从1到3600生成1000个点

# 生成y轴数据
y_hedera = hedera(x_values)
y_xrpl = xrpl(x_values)
y_bnb = bnb(x_values)

# 绘制图形
plt.figure(figsize=(10, 6))

plt.plot(x_values, y_hedera, label='Hedera', color='blue')
plt.plot(x_values, y_xrpl, label='XRPL', color='green')
plt.plot(x_values, y_bnb, label='BNB', color='red')

# 添加标题和标签
plt.title('Improved TPS vs Time')
plt.xlabel('Time (s)')
plt.ylabel('Improved TPS (%)')

# 添加图例
plt.legend()

# 显示图形
plt.show()
