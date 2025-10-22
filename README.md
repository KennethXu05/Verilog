# Verilog
Verilog and digital IC front-end design learning.  
:)  

## Carry-Lookahead Adder  
    4bit超前进位加法器  
    topmodule: cla_16bit  
    包括简化后的ALU74181芯片和ALU74182芯片的Verilog实现  
## FSM template  
    以0101可重叠序列检测为例，设计一个标准的三段式moore型状态机:  
    1 状态寄存器  
    2 状态转移  
    3 输出  
    三段式moore型更稳定，repository中其他代码理应向本template看齐，“不要把Verilog写成C语言！”  
    补：完善敏感量列表，修正缺失的初始态，fsm_sim_1.png对应状态机第三段为时序逻辑，fsm_sim_2.png对应状态机第三段为组合逻辑  
## odd_divider  
    奇分频电路  
    补：消除最终输出由于组合逻辑反馈环带来的锁存器，含仿真波形  
## one_byte_uart_tx  
    单字节串口发送  
## multiplier
    乘法器（内含加法器略）  
### unsigned_multiplier  
    用一段式状态机实现“右移”乘法  
    补：添加三段式  
### signed_multiplier 
    Booth法，状态机有改进空间  

    
