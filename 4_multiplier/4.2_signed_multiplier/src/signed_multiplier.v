    module signed_multiplier(
    input clk,
    input rst_n,
    input en,
    input [3:0] x,  //补码
    input [3:0] y,  //补码
    output reg [7:0] p  //运算时带符号位
);
    reg [9:0] r;
    reg [1:0] cnt; 

    wire [3:0] neg_x;
    assign neg_x = 4'b1111 - x + 1; //[-X]补

    wire [4:0] x_d; //双符号位
    wire [4:0] neg_x_d;

    assign x_d = {x[3], x};
    assign neg_x_d = {neg_x[3],neg_x};

    reg [1:0] current_state;
    reg [1:0] next_state;

    localparam IDLE = 2'b00;
    localparam JUDGE = 2'b01;
    localparam SHIFT = 2'b10;
    localparam FINISH = 2'b11;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            IDLE: next_state = en ? JUDGE : IDLE;
            JUDGE: next_state = SHIFT;
            SHIFT: next_state = (cnt == 2'b11) ? FINISH : JUDGE;
            FINISH: next_state = IDLE;
            default: next_state = IDLE;
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
                    r <= {1'b0, 4'b0, y, 1'b0};
                    cnt <= 2'b0;
                end 
                JUDGE: begin
                    if(r[1:0] == 2'b01)
                        r[9:5] <= r[9:5] + x_d; 
                    else if(r[1:0] == 2'b10)
                        r[9:5] <= r[9:5] + neg_x_d;
                end
                SHIFT: begin
                    if (cnt != 2'b11)          //前3次正常移位
                        r <= {r[9], r[9:1]};
                    //cnt==3 时不移，只把 cnt 加 1
                    cnt <= cnt + 1'b1;
                end 
                FINISH: begin
                    p <= r[9:2];
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