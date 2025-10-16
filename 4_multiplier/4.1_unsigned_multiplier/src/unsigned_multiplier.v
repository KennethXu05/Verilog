//以小数为例，如x = 0.1101 y = -0.1011([y]原 = 1.1011)，乘法时，看小数位，由于是原码，符号位不参与运算
module unsigned_multiplier(
    input clk,
    input rst_n,
    input en,
    input [3:0] x,
    input [3:0] y,
    output reg [7:0] p
);
    reg [9:0] r;
    reg [1:0] cnt;

    reg [1:0] STATE;
    localparam IDLE = 2'b00;
    localparam JUDGE = 2'b01;
    localparam SHIFT = 2'b10;
    localparam FINISH = 2'b11;

    // always @(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         STATE <= IDLE;
    //         p <= 8'b0;
    //     end
    //     else begin
    //         case(STATE)
    //             IDLE: begin
    //                 r <= {1'b0, 4'b0000, 1'b0, y};
    //                 cnt <= 2'b0;
    //                 if(en)
    //                     STATE <= JUDGE;
    //                 else
    //                     STATE <= IDLE; 
    //             end
    //             JUDGE: begin
    //                 if(r[0] == 1'b1)
    //                     r[9:5] <= r[9:5] + x;
    //                 else
    //                     r[9:5] <= r[9:5];    //删掉！
    //                 STATE <= SHIFT;
    //             end
    //             SHIFT:begin
    //                 r <= {1'b0, r[9:1]};
    //                 if(cnt == 2'b11)
    //                     STATE <= FINISH;
    //                 else begin
    //                     cnt <= cnt + 1'b1;
    //                     STATE <= JUDGE;
    //                 end
    //             end
    //             FINISH: begin
    //                 p <= r[8:1];
    //                 STATE <= IDLE;
    //             end
    //             default: STATE <= IDLE;
    //         endcase
    //     end 
    // end
    
    /*状态机优化与标准化*/
    reg [1:0] current_state;
    reg [1:0] next_state;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case(current_state)
            IDLE: next_state = en ? JUDGE : IDLE;
            JUDGE: next_state = SHIFT;
            SHIFT: next_state = (cnt == 2'b11) ? FINISH : JUDGE;
            FINISH: next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            p <= 8'b0;
            r <= 10'b0;
            cnt <= 2'b0;
        end
        else begin
            case (current_state)
                IDLE: begin
                    r <= {1'b0, 4'b0000, 1'b0, y};
                    cnt <= 2'b0;
                end
                JUDGE: begin
                    if(r[0] == 1'b1)
                        r[9:5] <= r[9:5] + x;
                end
                SHIFT: begin
                    cnt <= cnt + 1'b1;
                    r <= {1'b0, r[9:1]};
                end
                FINISH: begin
                    p <= r[8:1];
                end
                default: begin
                    p <= 8'b0;
                    r <= 10'b0;
                    cnt <= 2'b0;
                end
            endcase
        end
    end

endmodule