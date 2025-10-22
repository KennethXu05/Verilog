//Grouup generate and propagate logic 先行进位电路，作为74181的后级，实现组内并行且组间并行的高于4bit的超前进位运算
module simp_alu74182(
    input [3:0] Pin,
    input [3:0] Gin,
    input Cin,
    output [3:0] CCout,
    output PPout,
    output GGout
);
    //多级的74181产生多组P* Q*, 74182的组内进位逻辑与74181类似,若adder大于16bit，后级仍为74182
    wire [3:0] P;
    wire [3:0] G;
    wire [3:0] C;

    assign P = Pin; //propagate进位传递函数
    assign G = Gin; //generate进位产生函数
    
    //计算每一位的进位
    assign C[0] = G[0] | (P[0] & Cin);
    assign C[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Cin);
    assign C[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & Cin);
    assign C[3] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & Cin);
    
    assign CCout = C; //最终进位输出
     

    //提取Cout特征可得，Cout = Gout + Pout * Cin，这里的Gout和Pout是4bit的整体进位产生和传递特征，可以接到下一级作为下一级的Cin
    assign PPout = &P; //所有位的P与运算
    assign GGout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]); //最高位的G与前面所有位的P与G运算

endmodule