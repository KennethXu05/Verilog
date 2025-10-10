`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/10 17:53:24
// Design Name: 
// Module Name: odd_div_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module odd_div_tb;

    reg clk;
    reg rst_n;
    wire [7:0] cnt_pos;
    wire [7:0] cnt_neg;
    wire [7:0] cnt_temp;
    wire [7:0] cnt;
    wire clk_out;

    // Instantiate the DUT
    odd_div uut (
        .clk(clk),
        .rst_n(rst_n),
        .cnt_pos(cnt_pos),
        .cnt_neg(cnt_neg),
        .cnt_temp(cnt_temp),
        .cnt(cnt),
        .clk_out(clk_out)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        // Apply reset
        rst_n = 0;
        #20;
        rst_n = 1;

        #500;
        $stop;
    end


endmodule
