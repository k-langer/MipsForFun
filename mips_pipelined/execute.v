module execute
   (input clk, flush, 
    input AnyStall, 
    input AluSrc_ID, 
    input [2:0] BpCtl_ID,
    input [3:0] AluControl_ID,
    input [15:0] Imm_ID,
    input RegWrite_ID, MemWrite_ID, MemToReg_ID,
    input [31:0] RdDatA_ID, RdDatB_ID, 
    output [31:0] Result_EX, 
    output RegWrite_EX, MemToReg_EX, MemWrite_EX,
    output Stall_EX);

    wire [31:0] a,b; 
    assign a = RdDatA_ID; 
    assign b = RdDatB_ID; 
    wire [5:0] shamt; //HACK
    reg  [31:0] result;
    wire [31:0] condinvb, sum;
    wire zero; 

    assign condinvb = AluControl_ID[2] ? ~b : b;
    assign sum = a + condinvb + {31'b0,AluControl_ID[2]};
    assign Stall_EX = 1'b0; 

    always @ *
        case (AluControl_ID[3:0])
          //4'b1000: mul
          //4'b1001: div
          //4'b1010: result = muldiv[63:32];
          //4'b1011: result = muldiv[31:0];
          4'b1001: result = {b[15:0],16'b0};
          4'b0000: result = a & b;
          4'b0001: result = a | b;
          4'b0101: result = a ^ b;
          4'b0011: result = a << b;
          4'b0100: result = a >> b;
          4'b1100: result = a << shamt;
          4'b1101: result = a >> shamt;
          4'b1110: result = a >>> shamt;
          4'b0010: result = sum;
          4'b0110: result = sum;
          4'b0111: result = {32{sum[31]}};
          default: result = 32'bx;
        endcase
    assign zero = (result == 32'b0);
    wire [31:0] Result_EXM1;
    wire RegWrite_EXM1, MemToReg_EXM1, MemWrite_EXM1;
    assign Result_EXM1 = AnyStall ? Result_EX : result; 
    assign RegWrite_EXM1 = AnyStall ? RegWrite_EX : RegWrite_ID;
    assign MemToReg_EXM1 = AnyStall ? MemToReg_EX : MemToReg_ID;
    assign MemWrite_EXM1 = AnyStall ? MemToReg_EX : MemToReg_ID;
    dff #(32) dff_Result   (clk,flush, Result_EXM1,     Result_EX);
    dff       dff_RegWrite (clk,flush, RegWrite_EXM1, RegWrite_EX);
    dff       dff_MemToReg (clk,flush, MemToReg_EXM1, MemToReg_EX);
    dff       dff_MemWrite (clk,flush, MemWrite_EXM1, MemWrite_EX);

endmodule
