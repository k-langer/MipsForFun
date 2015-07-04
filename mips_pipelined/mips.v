module mips (
    input clk, 
    input reset,
    output [31:0] Result_EX
);
    wire AnyStall; 
    wire [31:0] Pc_IF, RedirectPc_EXM1, FetchData_IF, ExRedirectPc_ID, RedirectPc_ID, Result_EX, WrDat_EX;
    wire [25:0] JumpTgt_IDM1;
    wire [15:0] Imm_ID;
    wire [3:0] AluControl_ID;
    wire [3:0] BpCtl_ID;
    wire [31:0] RdDatA_ID, RdDatB_ID, SignImm_ID; 
    wire Stall_EX,RegWrite_EX, MemToReg_EX, MemWrite_EX; 
    wire BranchTaken_EXM1;
    wire Jump_IDM1, RegWrite_ID, RegDst_ID,AluSrc_ID,MemWrite_ID; 
    wire MemToReg_ID, Link_ID;
    wire [31:0] RdDat_ME, Result_ME,ResultRdDat_ME;
    wire [4:0]  WriteReg_EX, WriteReg_ME;
    wire  RegWrite_ME, MemToReg_ME;
    wire [4:0] Rs_ID, Rt_ID, Rd_ID; 

    assign AnyStall = 1'b0; 

    fetch fe(clk, reset, 
        AnyStall, JumpTgt_IDM1, Jump_IDM1, RedirectPc_EXM1, BranchTaken_EXM1, 
        Pc_IF,FetchData_IF);

    decode de( clk, reset, AnyStall, Pc_IF, FetchData_IF,    
        RegWrite_ME, MemToReg_ME, RdDat_ME, Result_ME, WriteReg_ME,
        Jump_IDM1, JumpTgt_IDM1,
        RegWrite_ID, RegDst_ID, AluSrc_ID, MemWrite_ID, MemToReg_ID, Link_ID,
        BpCtl_ID, AluControl_ID, SignImm_ID, 
        Imm_ID, Rs_ID, Rt_ID, Rd_ID, RdDatA_ID, RdDatB_ID,
        ExRedirectPc_ID);

    execute ex(clk, reset, AnyStall, AluSrc_ID, RegDst_ID, BpCtl_ID, AluControl_ID, 
        ExRedirectPc_ID, SignImm_ID, Imm_ID, RegWrite_ID, MemWrite_ID, MemToReg_ID,        
        RdDatA_ID, RdDatB_ID, Rs_ID, Rt_ID, Rd_ID, WriteReg_ME, RegWrite_ME,
        ResultRdDat_ME, Result_EX, WrDat_EX, WriteReg_EX,
        RegWrite_EX, MemToReg_EX, MemWrite_EX,
        BranchTaken_EXM1, RedirectPc_EXM1, Stall_EX);

    memory me(clk, reset, AnyStall, 
        Result_EX,WrDat_EX, RegWrite_EX, MemToReg_EX, MemWrite_EX, WriteReg_EX,
        RdDat_ME, Result_ME, WriteReg_ME, RegWrite_ME, MemToReg_ME,ResultRdDat_ME);

endmodule 

module hazard ( input clk, reset, AnyStall
);
endmodule 

module dff #(parameter WIDTH = 1)
              (input             clk, reset,
               input [WIDTH-1:0] d,
               output [WIDTH-1:0] q); 
  reg [WIDTH-1:0] q;
  always @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule
