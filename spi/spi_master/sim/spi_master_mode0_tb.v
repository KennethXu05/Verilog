`timescale 1ns/1ps

module spi_master_mode0_tb;

    // 50MHz clock -> period 20ns
    reg clk = 0;
    always #10 clk = ~clk;

    reg rst_n;

    reg [7:0] data_send;
    wire [7:0] data_recv;
    reg data_valid;
    wire send_completed;
    wire recv_completed;

    // SPI signals
    reg miso;         // driven by testbench (slave)
    wire mosi;
    wire sck;
    wire nss;

    // instantiate DUT with CPOL=0, CPHA=0 (use defaults)
    spi_master #(
        .CLK_DIV(4),
        .CPOL(1'b0),
        .CPHA(1'b0)
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
        .nss(nss)
    );

    // Simple SPI slave model (mode 0): drive MISO on sck falling edge, sample MOSI on sck rising edge
    reg [7:0] slave_tx = 8'h5a; // data slave will send to master
    reg [7:0] slave_rx;
    reg [3:0] slave_cnt;

    initial begin
        miso = 1'b0;
        slave_cnt = 4'd0;
        slave_rx = 8'd0;
    end

    // drive MISO on falling edge of SCK (so it's stable before next rising edge)
    always @(negedge sck or posedge nss) begin
        if (nss) begin
            miso <= 1'b0;
            slave_cnt <= 4'd0;
        end
        else begin
            miso <= slave_tx[7 - slave_cnt];
        end
    end

    // sample MOSI on rising edge of SCK
    always @(posedge sck or posedge nss) begin
        if (nss) begin
            // nothing
        end
        else begin
            slave_rx[7 - slave_cnt] <= mosi;
            slave_cnt <= slave_cnt + 1'b1;
        end
    end

    // test sequence
    initial begin
        // reset
        rst_n = 0;
        data_valid = 0;
        data_send = 8'hA5; // master will send 0xA5
        #100;
        rst_n = 1;
        #100;
        data_valid = 1;
        #1000;
        $finish;
    end

endmodule