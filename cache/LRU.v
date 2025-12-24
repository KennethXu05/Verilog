//Least Recently Used Simplified Logic Module

module LRU #(
    parameter SIZE = 4
    )(
    input clk,
    input rst_n
);

    integer i;
    reg [7:0] time_cnt[SIZE-1:0];   //第i位存储时间计数
    reg read[SIZE-1:0];    //第i位读取标志位
    reg write[SIZE-1:0];    //第i位写入标志位

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < SIZE; i = i + 1) begin
                time_cnt[i] <= 8'b0;
            end
        end 
        else begin
            for (i = 0; i < SIZE; i = i + 1) begin
                if (write[i] == 1'b1 || read[i] == 1'b1) begin
                    time_cnt[i] <= 8'b0;
                end 
                else begin
                    time_cnt[i] <= time_cnt[i] + 1'b1;  //没被使用(写入或读取)时，时间计数加1
                end
            end
        end
    end

    //replace = max(time_cnt) 替换近期最久未使用的数据

endmodule