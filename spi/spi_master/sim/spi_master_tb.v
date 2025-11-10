`timescale 1ns/1ns

module spi_master_tb;

    // 50MHz clock -> period 20ns
    reg clk = 0;
    always #10 clk = ~clk;

    reg rst_n;

    reg [7:0] data_send;
    wire [7:0] data_recv;
    reg data_valid;
    wire send_completed;
    wire recv_completed;
    wire sck_toggle_flag;

    // SPI signals
    reg miso;         // driven by testbench (slave)
    wire mosi;
    wire sck;
    wire nss;

    // instantiate DUT with CPOL=0, CPHA=0 (use defaults)
    spi_master #(
        .CLK_DIV(4),
        .CPOL(1'b1),
        .CPHA(1'b1)
    ) u_spi_master (
        .clk(clk),
        .rst_n(rst_n),
        .data_send(data_send),
        .data_recv(data_recv),
        .data_valid(data_valid),
        .send_completed(send_completed),
        .recv_completed(recv_completed),
        .miso(miso),
        .mosi(mosi),
        .sck(sck),
        .nss(nss),
        .sck_toggle_flag(sck_toggle_flag)
    );

    initial begin
        miso = 1'b0;
    end

    // test sequence
    initial begin
        // reset
        rst_n = 0;
        data_send = 8'h00;
        data_valid = 0;
        #21;
        rst_n = 1;        

        data_send = 8'b11010101;
        #5;
        data_valid = 1;
        #20;
        data_valid = 0;

        #1000;
        $finish;
    end

endmodule