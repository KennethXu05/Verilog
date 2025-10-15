module mulitiplier_tb();
    reg clk;
    reg rst_n;
    reg en;
    reg [3:0] x;
    reg [3:0] y;
    wire [7:0] p;

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        en = 1'b0;
        x = 4'b1101; //13
        y = 4'b1011; //11
        #15
        rst_n = 1'b1;
        #10
        en = 1'b1;
        #200
        x = 4'b0011; //3
        y = 4'b0101; //5
        #200
        x = 4'b1111; //15
        y = 4'b1111; //15
        #200

        $stop;
    end
    
    unsigned_multiplier u_unsigned_multiplier(
        .clk   	(clk    ),
        .rst_n 	(rst_n  ),
        .en    	(en     ),
        .x     	(x      ),
        .y     	(y      ),
        .p     	(p      )
    );
    
endmodule