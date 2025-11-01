module one_byte_uart_rx #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 115200
)(
    input clk,
    input rst_n,
    input rx_en,

    input rx_in,    //电平触发接收，一般持续置高，不会有异步的问题
    output reg [7:0] rx_data,
    output reg rx_done,

    output reg sample_tick,
    output reg [1:0] uart_current_state
);
    
    //1 输入信号打两拍时序同步
    reg [1:0] rx_in_q;
    wire rx_in_sync;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            rx_in_q <= 2'b11;
        else
            rx_in_q <= {rx_in_q[0], rx_in}; 
    end

    assign rx_in_sync = rx_in_q[1];
    
    //2 采样计数值
    localparam SAMPLE_CNT = CLK_FREQ / (BAUD_RATE * 9);    //以9倍波特率采样，取采样到的[8:0]中的[6:2]
    reg [15:0] sample_cnt;
    // reg sample_tick;

    //2.1 采样计数
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            sample_cnt <= 16'd0;
        else if(sample_cnt == SAMPLE_CNT - 1)
            sample_cnt <= 16'd0;
        else 
            sample_cnt <= sample_cnt + 1'b1;
    end

    //2.2 采样脉冲
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            sample_tick <= 1'b0;
        else if(sample_cnt == SAMPLE_CNT - 1)
            sample_tick <= 1'b1;
        else 
            sample_tick <= 1'b0;
    end

    //3 当有数据传入时，在每个sample_tick时，对rx_in_sync进行采样(LSB, 起始位-LSB-MSB-停止位)
    reg [6:0] sample_bit_cnt;   //从0记到89，每9个sample_tick采样一个bit
    reg [89:0] rx_shift_reg;   //接收寄存器组(10组,每组9bit)

    // reg [1:0] uart_current_state;
    reg [1:0] uart_next_state;

    localparam UART_IDLE = 2'b00;
    localparam UART_RECEIVE = 2'b01;
    localparam UART_DONE = 2'b10;


    //三段式FSM
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            uart_current_state <= UART_IDLE;
        else
            uart_current_state <= uart_next_state;
    end

    always @(*) begin
        if(!rst_n)
            uart_next_state = UART_IDLE;
        else begin
            case(uart_current_state)
                UART_IDLE: begin
                    if(rx_en && (rx_in_sync == 1'b0))   //检测到起始位
                        uart_next_state = UART_RECEIVE;
                    else
                        uart_next_state = UART_IDLE;
                end
                UART_RECEIVE: begin
                    if((sample_bit_cnt >= 7'd0) && (sample_bit_cnt <= 7'd8) && (rx_shift_reg[83] + rx_shift_reg[84] + rx_shift_reg[85] + rx_shift_reg[86] + rx_shift_reg[87] >= 2'd3)) //起始位多数表决错误，寄存器右移初始时，起始位对应[89:81]
                        uart_next_state = UART_IDLE;
                    else if(sample_bit_cnt >= 7'd89)
                        uart_next_state = UART_DONE;
                    else
                        uart_next_state = UART_RECEIVE;
                end
                UART_DONE:
                    uart_next_state = UART_IDLE;
                default: uart_next_state = UART_IDLE;
            endcase
        end 
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sample_bit_cnt <= 7'd0;
            rx_done <= 1'b0;
            rx_data <= 8'd0; 
        end
        else begin
            case (uart_current_state)
                UART_IDLE: begin
                    sample_bit_cnt <= 7'd0;
                    rx_shift_reg <= 90'd0; 
                    rx_done <= 1'b0;
                end 
                UART_RECEIVE: begin
                    if(sample_tick) begin
                        sample_bit_cnt <= sample_bit_cnt + 1'b1;
                        //每9个sample_tick采样一个bit,采样结果逐个右移
                        rx_shift_reg <= {rx_in_sync, rx_shift_reg[89:1]};
                    end
                end
                UART_DONE: begin
                    //对每组的[6:2]进行多数表决
                    rx_data[0] <= rx_shift_reg[11] + rx_shift_reg[12] + rx_shift_reg[13] + rx_shift_reg[14] + rx_shift_reg[15] >= 3 ? 1'b1 : 1'b0;
                    rx_data[1] <= rx_shift_reg[20] + rx_shift_reg[21] + rx_shift_reg[22] + rx_shift_reg[23] + rx_shift_reg[24] >= 3 ? 1'b1 : 1'b0;
                    rx_data[2] <= rx_shift_reg[29] + rx_shift_reg[30] + rx_shift_reg[31] + rx_shift_reg[32] + rx_shift_reg[33] >= 3 ? 1'b1 : 1'b0;
                    rx_data[3] <= rx_shift_reg[38] + rx_shift_reg[39] + rx_shift_reg[40] + rx_shift_reg[41] + rx_shift_reg[42] >= 3 ? 1'b1 : 1'b0;
                    rx_data[4] <= rx_shift_reg[47] + rx_shift_reg[48] + rx_shift_reg[49] + rx_shift_reg[50] + rx_shift_reg[51] >= 3 ? 1'b1 : 1'b0;
                    rx_data[5] <= rx_shift_reg[56] + rx_shift_reg[57] + rx_shift_reg[58] + rx_shift_reg[59] + rx_shift_reg[60] >= 3 ? 1'b1 : 1'b0;
                    rx_data[6] <= rx_shift_reg[65] + rx_shift_reg[66] + rx_shift_reg[67] + rx_shift_reg[68] + rx_shift_reg[69] >= 3 ? 1'b1 : 1'b0;
                    rx_data[7] <= rx_shift_reg[74] + rx_shift_reg[75] + rx_shift_reg[76] + rx_shift_reg[77] + rx_shift_reg[78] >= 3 ? 1'b1 : 1'b0;
                    
                    rx_done <= 1'b1; 
                    rx_shift_reg <= 90'd0; 
                end
                default:begin
                    sample_bit_cnt <= sample_bit_cnt;
                    rx_shift_reg <= rx_shift_reg;
                    rx_done <= 1'b0;
                end
            endcase
        end
    end
endmodule