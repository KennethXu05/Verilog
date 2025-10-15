//以0101序列检测为例，设计一个标准的三段式moore型状态机
module sequence_detection(
    input clk,
    input rst_n,
    input in,
    output reg out
);
    reg [2:0] current_state;
    reg [2:0] next_state;
    localparam S0 = 3'b000; //初始状态
    localparam S1 = 3'b001; //检测到第一个0
    localparam S2 = 3'b010; //检测到01
    localparam S3 = 3'b011; //检测到010
    localparam S4 = 3'b100; //检测到0101

    //1 状态寄存器
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    //2 状态转移组合逻辑
    always @(*) begin
        case (current_state)
            S0: next_state = (in == 1'b0) ? S1 : S0;
            S1: next_state = (in == 1'b1) ? S2 : S1;
            S2: next_state = (in == 1'b0) ? S3 : S0;
            S3: next_state = (in == 1'b1) ? S4 : S1;
            S4: next_state = (in == 1'b1) ? S0 : S3;
            default: next_state = S0;
        endcase
    end 

    //3 输出时序逻辑
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            out <= 1'b0;
        else begin
            case (current_state)
                S0: out <= 1'b0;
                S1: out <= 1'b0;
                S2: out <= 1'b0;
                S3: out <= 1'b0;
                S4: out <= 1'b1;
                default: out <= 1'b0;
            endcase
        end
    end

endmodule