module cla_16bit(
    input [15:0] A,
    input [15:0] B,
    input Cin,
    output [15:0] S
);

    wire [3:0] P;
    wire [3:0] G;
    wire [3:0] CCout;

    //实例化4个4bit的7418
    simp_alu74181 u_simp_alu74181_0(
        .A    	(A[3:0]     ),
        .B    	(B[3:0]     ),
        .Cin  	(Cin        ),
        .S    	(S[3:0]     ),
        .Cout 	(),
        .Pout 	(P[0]       ),
        .Gout 	(G[0]       )
    );

    simp_alu74181 u_simp_alu74181_1(
        .A    	(A[7:4]     ),  
        .B    	(B[7:4]     ),
        .Cin  	(CCout[0]       ),
        .S    	(S[7:4]     ),
        .Cout 	(),
        .Pout 	(P[1]       ),
        .Gout 	(G[1]       )
    );

    simp_alu74181 u_simp_alu74181_2(
        .A    	(A[11:8]    ),
        .B    	(B[11:8]    ),
        .Cin  	(CCout[1]       ),
        .S    	(S[11:8]    ),
        .Cout 	(),
        .Pout 	(P[2]       ),
        .Gout 	(G[2]       )
    );

    simp_alu74181 u_simp_alu74181_3(
        .A    	(A[15:12]   ),
        .B    	(B[15:12]   ),
        .Cin  	(CCout[2]       ),
        .S    	(S[15:12]   ),
        .Cout 	(),
        .Pout 	(P[3]       ),
        .Gout 	(G[3]       )  
    );
    
    //实例化1个4bit的74182
    simp_alu74182 u_simp_alu74182(
        .Pin   	(P    ),
        .Gin   	(G    ),
        .Cin   	(Cin    ),
        .CCout 	(CCout  ),
        .PPout 	(),
        .GGout 	()
    );

endmodule