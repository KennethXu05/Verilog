`timescale 1ns/1ns
module one_byte_uart_tx_tb;

reg clk;
reg rst_n;
reg tx_en;
reg [7:0] tx_data;
wire tx_out;
wire tx_done;
wire baud_tick;
wire [8:0] baud_cnt;

// 实例化待测模块
one_byte_uart_tx 
#(
    .CLK_FREQ(50000000),  //时钟频率
    .BAUD_RATE(115200)    //波特率
) u_one_byte_uart_tx(
    .clk      (clk),
    .rst_n    (rst_n),
    .tx_en    (tx_en),
    .tx_data  (tx_data),
    .tx_out   (tx_out),
    .tx_done  (tx_done),
    .baud_cnt (baud_cnt),
    .baud_tick(baud_tick)
);

// 生成时钟
initial clk = 0;
always #1 clk = ~clk; // 50MHz, 20ns周期

// 仿真初始化和激励
initial begin
    rst_n = 0;
    tx_en = 0;
    tx_data = 8'h00;
    #100;
    rst_n = 1;
    #100;

    //发送第一个字节
    tx_data = 8'b11000101;
    tx_en = 1;
    #20;
    tx_en = 0;

    //等待一段时间后发送第二个字节
    #200;
    tx_data = 8'b01101010;
    tx_en = 1;
    #20;
    tx_en = 0;


    #200;
    $finish();
end

endmodule