`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/10 17:39:15
// Design Name: 
// Module Name: odd_div
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


module odd_div #(  
        parameter DIV = 2'd3
    )
    (
        input clk,
        input rst_n,
        output reg [7:0] cnt_pos,
        output reg [7:0] cnt_neg,
        output reg [7:0] cnt_temp,
        output reg [7:0] cnt,
        output reg clk_out
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt_pos <= 0;
        else if (cnt_pos == DIV - 1'b1)
            cnt_pos <= 0;
        else
            cnt_pos <= cnt_pos + 1'b1;
    end

    always @(negedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt_neg <= 0;
        else if (cnt_neg == DIV - 1'b1)
            cnt_neg <= 0;
        else
            cnt_neg <= cnt_neg + 1'b1;
    end

    always @(*) begin
        cnt_temp = cnt_pos + cnt_neg;
    end

    always @(*) begin
        if(cnt_temp >= DIV)
            cnt = cnt_temp - DIV;
        else
            cnt = cnt_temp;
    end

    always @(*) begin
        if (!rst_n)
            clk_out = 0;
        else if (cnt == DIV - 1'b1)
            clk_out = ~clk_out;
        else
            clk_out = clk_out;
    end


endmodule
