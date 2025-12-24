# Verilog
Verilog and digital IC design learning.  
:)  

## ALU  
### 1 Carry-Lookahead Adder  
    4bit超前进位加法器  
    topmodule: cla_16bit  
    包括简化后的ALU74181芯片和ALU74182芯片的Verilog实现  
### 2 multiplier
    乘法器（内含加法器略）  
#### 2.1 unsigned_multiplier  
    用一段式状态机实现“右移”乘法  
    补：添加三段式  
#### 2.2 signed_multiplier 
    Booth法，状态机有改进空间  

## Cache
### 1 FIFO
    简化的 First-In-First-Out（先入先出）缓存替换算法
### 2 LfU 
    简化的 Least-Recently-Used（近期最久未使用）缓存替换算法
### 3 LFU 
    简化的 Least-Frequently-Used（最不经常使用）缓存替换算法
    
## FSM template  
    以0101可重叠序列检测为例，设计一个标准的三段式moore型状态机:  
    1 状态寄存器  
    2 状态转移  
    3 输出  
    三段式moore型更稳定，repository中其他代码理应向本template看齐，“不要把Verilog写成C语言！”  
    补：完善敏感量列表，修正缺失的初始态  
    fsm_sim_1.png对应状态机第三段为时序逻辑，fsm_sim_2.png对应状态机第三段为组合逻辑  

## odd_divider  
    奇分频电路  
    补：消除最终输出由于组合逻辑反馈环带来的锁存器，含仿真波形

## spi
### spi_master
    单字节SPI主模式收发，支持四种模式  
    
## uart
### 1 one_byte_uart_tx  
    单字节串口发送  
    补：修改状态机，添加仿真波形one_byte_uart_tx_sim.png
### 2 one_byte_uart_rx
    单字节串口接收，内附考虑毛刺的非理想串口接收仿真

    
