//Least Frequently Used Simplified Logic Module

module LFU #(
    parameter SIZE = 4
    )(
    input clk,
    input rst_n
);

    integer i;
    reg [7:0] used_times_cnt[SIZE-1:0];   //第i位调用次数计数
    reg read[SIZE-1:0];    //第i位读取标志位
    reg write[SIZE-1:0];    //第i位写入标志位

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for (i = 0; i < SIZE; i = i + 1) begin
                used_times_cnt[i] <= 8'b0;
            end
        end
        else begin
            if(write[i] == 1'b1)
                used_times_cnt[i] <= 1'b0;  //写入新的数据时，调用次数清零
            else if(read[i] == 1'b1)
                used_times_cnt[i] <= used_times_cnt[i] + 1'b1;  //读取时，调用次数加1
            else
                used_times_cnt[i] <= used_times_cnt[i];
        end
    end

    //replace = min(used_times_cnt) 替换最不常调用的数据

endmodule