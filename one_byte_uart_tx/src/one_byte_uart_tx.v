module one_byte_uart_tx #(
    parameter CLK_FREQ = 50000000,  //时钟频率
    parameter BAUD_RATE = 115200    //波特率
)(
    input clk,
    input rst_n,
    input tx_en,

    input [7:0] tx_data,
    output reg tx_out,
    output reg tx_done,

    //仿真调试
    output reg baud_tick,   
    output reg [15:0] baud_cnt
);
    //1 波特率115200，时钟频率50MHz
    //parameter BAUD_CNT = CLK_FREQ / BAUD_RATE;  //真实波特率下，434
    localparam BAUD_CNT = 4; //仿真用

    //2 波特率产生器，每434个系统时钟周期，产生一个波特率脉冲
    //2.1 系统时钟计数器
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            baud_cnt <= 16'd0;
        else if(baud_cnt == BAUD_CNT - 1)
            baud_cnt <= 16'd0;
        else
            baud_cnt <= baud_cnt + 1'b1;
    end

    //2.2 波特率脉冲
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            baud_tick <= 1'b0;
        else if(baud_cnt == BAUD_CNT - 1)
            baud_tick <= 1'b1;
        else
            baud_tick <= 1'b0;
    end

    //3 在每个波特率脉冲时，发送一个比特的数据(LSB first)
    reg [3:0] bit_cnt;
    reg [9:0] tx_shift_reg;  //发送移位寄存器，1个起始位，8个数据位，1个停止位
    // reg [1:0] UART_STATE;

    localparam UART_IDLE = 2'b00;
    localparam UART_SEND = 2'b01;
    localparam UART_DONE = 2'b10;

    wire tx_en_pos;
    reg tx_en_prev;
    reg [1:0] tx_en_edge;

    //3.1 tx_en上升沿检测(需要补充key_filter模块或程控边沿)
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tx_en_prev <= 1'b0;
            tx_en_edge <= 2'b00;
        end 
        else begin
            tx_en_prev <= tx_en;
            tx_en_edge <= {tx_en_prev, tx_en};
        end
    end
    assign tx_en_pos = (tx_en_edge == 2'b01) ? 1'b1 : 1'b0;


    // //3.2 串口发送FSM(一段式)
    // always @(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         tx_done <= 1'b0;
    //         tx_shift_reg <= 10'b1111111111;  //空闲状态，发送移位寄存器全为1
    //         UART_STATE <= UART_IDLE;
    //         bit_cnt <= 4'd0;
    //         tx_out <= 1'b1;  //空闲状态，tx_out为高电平
    //     end 
    //     else begin
    //         case (UART_STATE)
    //             UART_IDLE: begin
    //                 tx_done <= 1'b0;
    //                 bit_cnt <= 4'd0;
    //                 tx_out <= 1'b1;
    //                 tx_shift_reg <= {1'b1, tx_data, 1'b0};  //停止位-MSB-LSB-起始位，从起始位开始发，符合规范
    //                 if(tx_en_pos)
    //                     UART_STATE <= UART_SEND;
    //                 else 
    //                     UART_STATE <= UART_IDLE; 
    //             end 
    //             UART_SEND: begin
    //                 if(bit_cnt == 4'd9)
    //                     UART_STATE <= UART_DONE;
    //                 else if(baud_tick) begin
    //                     bit_cnt <= bit_cnt + 1'b1;
    //                     tx_out <= tx_shift_reg[bit_cnt];  //发送最低位
    //                 end
    //                 else
    //                     UART_STATE <= UART_SEND;
    //             end
    //             UART_DONE: begin
    //                 tx_done <= 1'b1;
    //                 UART_STATE <= UART_IDLE;
    //             end
    //             default: 
    //                 UART_STATE <= UART_IDLE;
    //         endcase
    //     end
    // end

    //3.2 串口发送FSM(三段式)
    reg [1:0] uart_current_state;
    reg [1:0] uart_next_state;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            uart_current_state <= UART_IDLE;
        else
            uart_current_state <= uart_next_state;
    end

    always @(*) begin
        case (uart_current_state)
            UART_IDLE:
                if(tx_en_pos)
                    uart_next_state = UART_SEND;
                else 
                    uart_next_state = UART_IDLE;
            UART_SEND:
                if(bit_cnt == 4'd9)
                    uart_next_state = UART_DONE;
                else 
                    uart_next_state = UART_SEND;
            UART_DONE: 
                uart_next_state = UART_IDLE;
            default: 
                uart_next_state = UART_IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tx_done <= 1'b0;
            tx_shift_reg <= 10'b1111111111;  //空闲状态，发送移位寄存器全为1
            bit_cnt <= 4'd0;
            tx_out <= 1'b1;  //空闲状态，tx_out为高电平    
        end
        else begin
            case (uart_current_state)
                UART_IDLE: begin
                    tx_done <= 1'b0;
                    bit_cnt <= 4'd0;
                    tx_out <= 1'b1;
                    tx_shift_reg <= {1'b1, tx_data, 1'b0};  //停止位-MSB-LSB-起始位，从起始位开始发，符合规范                    
                end 
                UART_SEND: begin
                    if(baud_tick) begin
                        bit_cnt <= bit_cnt + 1'b1;
                        tx_out <= tx_shift_reg[bit_cnt];  //发送最低位
                    end
                end
                UART_DONE: begin
                    tx_out <= 1'b1;
                    tx_done <= 1'b1;
                    bit_cnt <= 4'd0;
                end
                default: begin
                    tx_done <= 1'b0;
                    tx_shift_reg <= 10'b1111111111;  //空闲状态，发送移位寄存器全为1
                    bit_cnt <= 4'd0;
                    tx_out <= 1'b1;  //空闲状态，tx_out为高电平  
                end
            endcase
        end        
    end

endmodule 