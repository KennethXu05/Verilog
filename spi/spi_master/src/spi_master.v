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
    output reg nss,

    output sck_toggle_flag
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
    localparam HALF_CNT = (CLK_DIV/2 == 0) ? 1 : (CLK_DIV / 2);    
    //wire sck_toggle_flag;
    assign sck_toggle_flag = (clk_div_cnt == (HALF_CNT - 1));

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            clk_div_cnt <= 8'd0;
        else if(clk_div_cnt == (HALF_CNT - 1))
                clk_div_cnt <= 8'd0;
        else
                clk_div_cnt <= clk_div_cnt + 1'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            sck <= CPOL;   //空闲状态
        else if(!nss && sck_toggle_flag) begin
            sck <= ~sck;
        end
    end

    //FSM for MOSI/MISO handling
    reg [1:0] current_state;
    reg [1:0] next_state;
    reg [7:0] flag_cnt;

    localparam IDLE = 2'b00;
    localparam TRANSFER = 2'b01;
    localparam WAIT = 2'b10;
    localparam DONE = 2'b11;

    //移位寄存器
    reg [7:0] tx_shift;
    reg [7:0] rx_shift;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case(current_state)
            IDLE: begin
                if(data_valid_rising_edge)
                    next_state = TRANSFER;
                else
                    next_state = IDLE;
            end
            TRANSFER: begin
                if(flag_cnt == 8'd15)
                    next_state = DONE;
                else
                    next_state = WAIT;
            end
            WAIT: next_state = TRANSFER;
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            nss <= 1'b1;
            flag_cnt <= 8'd0;
            send_completed <= 1'b0;
            recv_completed <= 1'b0;
            tx_shift <= 8'd0;
            rx_shift <= 8'd0;
            data_recv <= 8'd0;
            mosi <= 1'b0;
        end
        else begin
            case (current_state)
                IDLE: begin
                    nss <= 1'b1;
                    flag_cnt <= 8'd0;
                    send_completed <= 1'b0;
                    recv_completed <= 1'b0;
                    rx_shift <= 8'd0;
                    data_recv <= data_recv;
                    send_completed <= 1'b0;
                    recv_completed <= 1'b0;
                    mosi <= 1'b0;
                    if (data_valid_rising_edge) begin   //valid上升沿时开始加载数据
                        tx_shift <= data_send;
                        nss <= 1'b0;
                        mosi <= data_send[7];
                    end
                end
                TRANSFER: begin
                    send_completed <= 1'b0;
                    recv_completed <= 1'b0;

                    if(sck_toggle_flag) begin
                        flag_cnt <= flag_cnt + 1'b1;

                        //CPHA=0:前边沿采样，CPHA=1:后边沿采样
                        if(CPHA ^ (sck == !CPOL)) begin   
                            //主设备采样MISO，从设备采集MOSI
                            mosi <= tx_shift[7];
                            rx_shift[0] <= miso;
                        end
                        else begin
                            //移位
                            tx_shift <= {tx_shift[6:0], 1'b0};
                            rx_shift <= {rx_shift[6:0], 1'b0};
                        end 
                    end
                end
                WAIT: begin
                    nss <= nss;
                    flag_cnt <= flag_cnt;
                    send_completed <= send_completed;
                    recv_completed <= recv_completed;
                    tx_shift <= tx_shift;
                    rx_shift <= rx_shift;
                    data_recv <= data_recv;
                    mosi <= mosi;
                end
                DONE: begin
                    nss <= 1'b1;
                    data_recv <= rx_shift;
                    send_completed <= 1'b1;
                    recv_completed <= 1'b1;
                    mosi <= 1'b0;
                end
                default: begin
                    nss <= nss;
                    flag_cnt <= flag_cnt;
                    send_completed <= send_completed;
                    recv_completed <= recv_completed;
                    tx_shift <= tx_shift;
                    rx_shift <= rx_shift;
                    data_recv <= data_recv;
                    mosi <= mosi;
                end
            endcase
        end
    end

endmodule