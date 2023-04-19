# axis_passthrough_monitor

## 增加一个帧率监测 reg, 已经添加 debug 属性

但是需要手动修改axis频率参数

## 增加一个 axi-lite 总线 slave 接口

1. 定义了3个只读寄存器 (RO Registers) 存储 col, line, fps, 可以通过总线读取这几个寄存器.

2. aclk的CONFIG.FREQ_HZ设置为PROPAGATED, 这样可以自动更新为连接过来的时钟的频率

3. FREQ_HZ在validate的时候自动按aclk的CONFIG.FREQ_HZ更新