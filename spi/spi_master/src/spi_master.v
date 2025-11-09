module spi_master #(
    parameter CLK_DIV = 4,  //时钟分频系数(2N)
    parameter CPOL = 1'b0,  //时钟极性
    parameter CPHA = 1'b0   //时钟相位
)(
    input clk,      //50MHz
    input rst_n,
    
    input [7:0] data_send,
    output reg [7:0] data_recv,
    input data_valid,   //边沿触发
    output reg send_completed,
    
    output reg recv_completed,

    input miso,
    output reg mosi,
    output reg sck,
    output reg nss
);  

    //data_valid信号上升沿检测
    reg data_valid_prev;
    wire data_valid_rising_edge;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            data_valid_prev <= 1'b0;
        else
            data_valid_prev <= data_valid;
    end
    assign data_valid_rising_edge = data_valid & ~data_valid_prev;

    //50%占空比sck时钟信号产生
    reg [7:0] clk_div_cnt;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            clk_div_cnt <= 8'd0;
        else if(clk_div_cnt == (CLK_DIV / 2 - 1))
                clk_div_cnt <= 8'd0;
        else
                clk_div_cnt <= clk_div_cnt + 1'b1;
    end

    //1byte数据发送 MOSI FSM
    reg [1:0] MOSI_current_state;
    reg [1:0] MOSI_next_state;
    reg [3:0] MOSI_bit_cnt;

    localparam MOSI_IDLE = 2'b00;
    localparam MOSI_SEND = 2'b01;
    localparam MOSI_DONE = 2'b10;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            MOSI_current_state <= MOSI_IDLE;
        else
            MOSI_current_state <= MOSI_next_state;
    end

    always @(*) begin
        if(!rst_n)
            MOSI_next_state = MOSI_IDLE;
        else begin
            case(MOSI_current_state)
                MOSI_IDLE: begin
                    if(data_valid_rising_edge)
                        MOSI_next_state = MOSI_SEND;
                    else 
                        MOSI_next_state = MOSI_IDLE;
                end
                MOSI_SEND: begin
                    if((MOSI_bit_cnt == 4'd7) && (sck == ~CPOL))
                        MOSI_next_state = MOSI_DONE;
                    else
                        MOSI_next_state = MOSI_SEND;
                end
                MOSI_DONE: 
                    MOSI_next_state = MOSI_IDLE;
                default: MOSI_next_state = MOSI_IDLE;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sck <= CPOL;
            nss <= 1'b1;
            MOSI_bit_cnt <= 4'd0;
            send_completed <= 1'b0;
            mosi <= 1'b0;
        end
        else begin
            case (MOSI_current_state)
                MOSI_IDLE: begin
                    sck <= CPOL;
                    nss <= 1'b1;
                    MOSI_bit_cnt <= 4'd0;
                    send_completed <= 1'b0;
                end
                MOSI_SEND: begin
                    if(clk_div_cnt == (CLK_DIV / 2 - 1))
                        sck <= ~sck;
                    if(sck == ~CPOL && clk_div_cnt == (CLK_DIV / 2 - 1))    //等效为时钟对应边沿
                        MOSI_bit_cnt <= MOSI_bit_cnt + 1'b1;
                    nss <= 1'b0;
                    send_completed <= 1'b0;
                    mosi <= data_send[7 - MOSI_bit_cnt];
                end 
                MOSI_DONE: begin
                    sck <= CPOL;
                    nss <= 1'b1;
                    send_completed <= 1'b1;
                end
                default: begin
                    sck <= sck;
                    nss <= nss;
                    MOSI_bit_cnt <= MOSI_bit_cnt;
                    send_completed <= send_completed;
                end
            endcase
        end
    end

    //1byte数据接收 MISO FSM
    reg [1:0] MISO_current_state;
    reg [1:0] MISO_next_state;
    reg [3:0] MISO_bit_cnt;
    reg [7:0] data_recv_temp;
    
    localparam MISO_IDLE = 2'b00;
    localparam MISO_RECV = 2'b01;
    localparam MISO_DONE = 2'b10;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            MISO_current_state <= MISO_IDLE;
        else
            MISO_current_state <= MISO_next_state;
    end

    always @(*) begin
        if(!rst_n)
            MISO_next_state = MISO_IDLE;
        else begin
            case(MISO_current_state)
                MISO_IDLE: begin
                    if(data_valid_rising_edge)
                        MISO_next_state = MISO_RECV;
                    else 
                        MISO_next_state = MISO_IDLE;
                end
                MISO_RECV: begin
                    if((MISO_bit_cnt == 4'd7) && (sck == CPOL))
                        MISO_next_state = MISO_DONE;
                    else
                        MISO_next_state = MISO_RECV;
                end
                MISO_DONE: 
                    MISO_next_state = MISO_IDLE;
                default: MISO_next_state = MISO_IDLE;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            MISO_bit_cnt <= 4'd0;
            recv_completed <= 1'b0;
            data_recv <= 8'd0;
            data_recv_temp <= 8'd0;
        end
        else begin
            case (MISO_current_state)
                MISO_IDLE: begin
                    MISO_bit_cnt <= 4'd0;
                    recv_completed <= 1'b0;
                end
                MISO_RECV: begin
                    if(sck == CPOL && clk_div_cnt == (CLK_DIV / 2 - 1)) begin    //等效为时钟对应边沿
                        MISO_bit_cnt <= MISO_bit_cnt + 1'b1;
                        data_recv_temp [7 - MISO_bit_cnt] <= miso;
                    end
                    recv_completed <= 1'b0;
                end 
                MISO_DONE: begin
                    data_recv <= data_recv_temp;
                    recv_completed <= 1'b1;
                end
                default: begin
                    MISO_bit_cnt <= MISO_bit_cnt;
                    recv_completed <= recv_completed;
                end
            endcase
        end
    end
    
endmodule