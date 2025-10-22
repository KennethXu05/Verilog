`timescale 1ns / 1ns
module alu74181_4bit_tb();
    reg [3:0] A;
    reg [3:0] B;
    reg Cin;
    wire [3:0] S;
    wire Cout;
    wire Pout;
    wire Gout;

    simp_alu74181 u_simp_alu74181(
        .A    	(A     ),
        .B    	(B     ),
        .Cin  	(Cin   ),
        .S    	(S     ),
        .Cout 	(Cout  ),
        .Pout 	(Pout  ),
        .Gout 	(Gout  )
    );

    initial begin
        A = 4'b0000; B = 4'b0000; Cin = 1'b0;
        #10 A = 4'b0001; B = 4'b0010; Cin = 1'b0;
        #10 A = 4'b0011; B = 4'b0100; Cin = 1'b0;
        #10 A = 4'b0101; B = 4'b0110; Cin = 1'b0;
        #10 A = 4'b0111; B = 4'b1000; Cin = 1'b0;
        #10 A = 4'b1001; B = 4'b1010; Cin = 1'b0;
        #10 A = 4'b1011; B = 4'b1100; Cin = 1'b0;
        #10 A = 4'b1101; B = 4'b1110; Cin = 1'b0;
        #10 A = 4'b1111; B = 4'b0001; Cin = 1'b0;
        #10 A = 4'b1111; B = 4'b1111; Cin = 1'b1;
        #10 $stop;
    end
endmodule