# Verilog
Verilog learning.  
:)  
## 0 test_file  
## 1 one_byte_uart_tx  
    单字节串口发送  
## 2 odd_divider  
    奇分频电路  
    补：消除最终输出由于组合逻辑反馈环带来的锁存器，含仿真波形  
## 3 Carry-Lookahead Adder  
    4bit超前进位加法器  
    topmodule: cla_16bit  
    包括简化后的ALU74181芯片和ALU74182芯片的Verilog实现  
## 4 multiplier  
    乘法器（内含加法器略）  
    4.1 原码乘法器  
    用一段式状态机实现“右移”乘法
    4.2 补码乘法器  
## 5 FSM template  
    以0101可重叠序列检测为例，设计一个标准的三段式moore型状态机:  
    1 状态寄存器  
    2 状态转移  
    3 输出  
    三段式moore型更稳定  
