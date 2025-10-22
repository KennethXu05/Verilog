//4bit CLA ALU74181
module simp_alu74181(
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] S,
    output Cout,
    output Pout,
    output Gout
);
    wire [3:0] P;
    wire [3:0] G;
    wire [3:0] C; // Carry signals for each bit

    assign P = A ^ B; // Propagate进位传递函数
    assign G = A & B; // Generate进位产生函数
    
    //计算每一位的进位
    assign C[0] = G[0] | (P[0] & Cin);
    assign C[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Cin); //assign C[1] = G[1] | (P[1] & C[0]); //逻辑正确，但是综合成电路时，不是并行
    assign C[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & Cin); // assign C[2] = G[2] | (P[2] & C[1]);
    assign C[3] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & Cin);    // assign C[3] = G[3] | (P[3] & C[2]);
    assign Cout = C[3]; //最终进位输出
    
    //计算和输出 
    assign S = P ^ {C[2:0], Cin}; 

    //提取Cout特征可得，Cout = Gout + Pout * Cin，这里的Gout和Pout是4bit的整体进位产生和传递特征，可以接到下一级作为下一级的Cin
    assign Pout = &P; //所有位的P与运算
    assign Gout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]); //最高位的G与前面所有位的P与G运算
    
endmodule //alu74181