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
        output reg clk_out_pos,
        output reg clk_out_neg,
        output clk_out
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

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            clk_out_pos <= 0;
        else if (cnt == DIV - 1'b1)
            clk_out_pos <= ~clk_out_pos;
    end

    always @(negedge clk or negedge rst_n) begin
        if (!rst_n)
            clk_out_neg <= 0;
        else if (cnt == DIV - 1'b1)
            clk_out_neg <= ~clk_out_neg;
    end

    assign clk_out = clk_out_pos ^ clk_out_neg;

endmodule
