`timescale 1ns / 1ns
module tb_sequence_detection();
    reg clk;
    reg rst_n;
    reg in;
    wire out;

    // 实例化被测模块 (DUT: Device Under Test)
    sequence_detection DUT (
        .clk(clk),
        .rst_n(rst_n),
        .in(in),
        .out(out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; // 产生周期为 PERIOD 的时钟
    end

    initial begin
        rst_n = 1'b0;
        in = 1'b1;

        #21; 
        rst_n = 1'b1;
        
        //完整匹配 0101 (非重叠)
        #10 in = 1'b1;
        
        #10 in = 1'b0; 
        #10 in = 1'b1; 
        #10 in = 1'b0; 
        #10 in = 1'b1; 
        
        #10 in = 1'b1;
        #10 in = 1'b1; 
        #10 in = 1'b1;
        
        //10匹配 010101 
        #10 in = 1'b0; 
        #10 in = 1'b1; 
        #10 in = 1'b0; 
        #10 in = 1'b1; 
        #10 in = 1'b0; 
        #10 in = 1'b1; 
        #10 in = 1'b1; 

        // 结束仿真
        #20;
        $stop;
    end


endmodule