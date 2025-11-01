`timescale 1ns/1ps

module one_byte_uart_rx_tb;

    localparam CLK_FREQ  = 50_000_000;
    localparam BAUD_RATE = 115200;
    localparam CLK_PERIOD_NS = 20;
    localparam integer BIT_NS = 8681;
    localparam integer GLITCH_NS = 100;


    reg clk = 0;
    reg rst_n = 0;
    reg rx_en = 1'b1;
    reg rx_in = 1'b1; // 空闲高

    wire [7:0] rx_data;
    wire rx_done;

    wire sample_tick;
    wire [1:0] uart_current_state;

    // DUT 实例
    one_byte_uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_en(rx_en),
        .rx_in(rx_in),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .sample_tick(sample_tick),
        .uart_current_state(uart_current_state)
    );

    // 时钟
    always #(CLK_PERIOD_NS/2) clk = ~clk;

    // 复位并保持基本信号，具体 rx_in 波形请在 Vivado 波形编辑器中手工生成
    initial begin
        rst_n = 0;
        rx_in = 1'b1;
        rx_en = 1'b1;
        #201;
        rst_n = 1;

        // Helper: send a byte LSB-first by explicit #delay and rx_in assignments
        // 1) simple byte 0x5A (01011010)
        // idle >2 bits
        rx_in = 1'b1; #(BIT_NS*2);
        // start bit
        rx_in = 1'b0; #(BIT_NS);
        // data bits LSB first
        rx_in = 1'b0; #(BIT_NS); // bit0 = 0
        rx_in = 1'b1; #(BIT_NS); // bit1 = 1
        rx_in = 1'b0; #(BIT_NS); // bit2 = 0
        rx_in = 1'b1; #(BIT_NS); // bit3 = 1
        rx_in = 1'b1; #(BIT_NS); // bit4 = 1
        rx_in = 1'b0; #(BIT_NS); // bit5 = 0
        rx_in = 1'b1; #(BIT_NS); // bit6 = 1
        rx_in = 1'b0; #(BIT_NS); // bit7 = 0
        // stop bit
        rx_in = 1'b1; #(BIT_NS*2);

        // 2) start-bit brief high glitch during start of 0xA5 (10100101)
        rx_in = 1'b1; #(BIT_NS*2);
        // start bit low with short high glitch
        rx_in = 1'b0; #(BIT_NS/4);
        rx_in = 1'b1; #(GLITCH_NS);
        rx_in = 1'b0; #((BIT_NS) - (BIT_NS/4) - GLITCH_NS);
        // data bits for 0xA5 LSB first (0xA5 = 10100101)
        rx_in = 1'b1; #(BIT_NS); // bit0 = 1
        rx_in = 1'b0; #(BIT_NS); // bit1 = 0
        rx_in = 1'b1; #(BIT_NS); // bit2 = 1
        rx_in = 1'b0; #(BIT_NS); // bit3 = 0
        rx_in = 1'b0; #(BIT_NS); // bit4 = 0
        rx_in = 1'b1; #(BIT_NS); // bit5 = 1
        rx_in = 1'b0; #(BIT_NS); // bit6 = 0
        rx_in = 1'b1; #(BIT_NS); // bit7 = 1
        rx_in = 1'b1; #(BIT_NS*2);

        // 3) data-bit brief inverted glitch inside bit3 for 0x3C (00111100)
        rx_in = 1'b1; #(BIT_NS*2);
        // start
        rx_in = 1'b0; #(BIT_NS);
        // data bits LSB-first for 0x3C = 00111100
        rx_in = 1'b0; #(BIT_NS); // b0
        rx_in = 1'b0; #(BIT_NS); // b1
        rx_in = 1'b1; #(BIT_NS); // b2
        // b3 = 1 but inject short 0 glitch in middle
        rx_in = 1'b1; #(BIT_NS/3);
        rx_in = 1'b0; #(GLITCH_NS);
        rx_in = 1'b1; #((BIT_NS) - (BIT_NS/3) - GLITCH_NS);
        rx_in = 1'b1; #(BIT_NS); // b4
        rx_in = 1'b1; #(BIT_NS); // b5
        rx_in = 1'b0; #(BIT_NS); // b6
        rx_in = 1'b0; #(BIT_NS); // b7
        rx_in = 1'b1; #(BIT_NS*2);

        // 4) idle noise spikes (brief low pulses)
        rx_in = 1'b1; #(BIT_NS*2);
        repeat (5) begin
            rx_in = 1'b0; #(GLITCH_NS);
            rx_in = 1'b1; #(BIT_NS/4);
        end
        #(BIT_NS);

        // 5) final byte 0xFF (all ones)
        rx_in = 1'b1; #(BIT_NS*2);
        rx_in = 1'b0; #(BIT_NS); // start
        rx_in = 1'b1; #(BIT_NS); // b0
        rx_in = 1'b1; #(BIT_NS); // b1
        rx_in = 1'b1; #(BIT_NS); // b2
        rx_in = 1'b1; #(BIT_NS); // b3
        rx_in = 1'b1; #(BIT_NS); // b4
        rx_in = 1'b1; #(BIT_NS); // b5
        rx_in = 1'b1; #(BIT_NS); // b6
        rx_in = 1'b1; #(BIT_NS); // b7
        rx_in = 1'b1; #(BIT_NS*4);


        #100_000_000;
        $stop;
    end

endmodule