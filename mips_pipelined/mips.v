module mips (
    input clk, 
    input reset,
    //input AnyStall,
    input [31:0] IntrAddr_FL0,
    input [31:0] IntrFill_FL0,
    output [31:0] Result_EX
);
    wire AnyStall; 
    wire [31:0] Pc_IF, RedirectPc_EXM1, FetchData_IF, ExRedirectPc_ID, RedirectPc_ID, Result_EX, WrDat_EX;
    wire [31:0] InstrFill_SY0, PcReq_SY0;
    wire [25:0] JumpTgt_IDM1;
    wire [3:0] AluControl_ID;
    wire [4:0] BpCtl_ID;
    wire Jr_ID; 
    wire [31:0] RdDatA_ID, RdDatB_ID, Imm_ID, Pc_ID; 
    wire RegWrite_EX, MemToReg_EX, MemWrite_EX; 
    wire BranchTaken_EXM1;
    wire Jump_IDM1, RegWrite_ID, RegDst_ID,AluSrc_ID,MemWrite_ID; 
    wire MemToReg_ID, Link_ID;
    wire [31:0] RdDat_ME, Result_ME,ResultRdDat_ME;
    wire [4:0]  WriteReg_EX, WriteReg_ME;
    wire  RegWrite_ME, MemToReg_ME, LwStall_EXM1, MisAlignStall_MEM1;
    wire [4:0] Rs_ID, Rt_ID, Rd_ID; 
    wire InstrVal_IF, InstrVal_ID, InstrVal_EX;
    wire StoreB_ID, LoadB_ID, StoreB_EX, LoadB_EX; 
    
    system sy(clk, reset, IntrAddr_FL0, IntrFill_FL0, PcReq_SY0, InstrFill_SY0); 

    fetch fe(clk, flush_FE, 
        Stall_FE, JumpTgt_IDM1, Jump_IDM1, RedirectPc_EXM1, BranchTaken_EXM1, InstrFill_SY0,  
        PcReq_SY0, InstrVal_IF, Pc_IF,FetchData_IF);

    decode de( clk, flush_DE, Stall_DE, Pc_IF, FetchData_IF, InstrVal_IF,
        RegWrite_ME, MemToReg_ME, RdDat_ME, Result_ME, WriteReg_ME,
        Jump_IDM1, JumpTgt_IDM1,
        RegWrite_ID, RegDst_ID, AluSrc_ID, MemWrite_ID, MemToReg_ID, Link_ID,
        BpCtl_ID, Jr_ID, AluControl_ID, Imm_ID, 
        Rs_ID, Rt_ID, Rd_ID, RdDatA_ID, RdDatB_ID,
        ExRedirectPc_ID, Pc_ID, InstrVal_ID,StoreB_ID, LoadB_ID);

    execute ex(clk, flush_EX, Stall_EX, AluSrc_ID, RegDst_ID, BpCtl_ID, Jr_ID, AluControl_ID, 
        ExRedirectPc_ID, Pc_ID, Imm_ID, RegWrite_ID, MemWrite_ID, MemToReg_ID, Link_ID,         
        RdDatA_ID, RdDatB_ID, Rs_ID, Rt_ID, Rd_ID, WriteReg_ME, LoadB_ID, StoreB_ID, InstrVal_ID, RegWrite_ME, 
        ResultRdDat_ME, LwStall_EXM1, Result_EX, WrDat_EX, WriteReg_EX,
        RegWrite_EX, MemToReg_EX, MemWrite_EX,
        BranchTaken_EXM1, RedirectPc_EXM1, InstrVal_EX, LoadB_EX, StoreB_EX);

    memory me(clk, flush_ME, Stall_ME, 
        Result_EX,WrDat_EX, RegWrite_EX, MemToReg_EX, MemWrite_EX, WriteReg_EX, InstrVal_EX,
        LoadB_EX, StoreB_EX, RdDat_ME, Result_ME, WriteReg_ME, RegWrite_ME, MemToReg_ME,ResultRdDat_ME, MisAlignStall_MEM1);

    // Global stall and flush logic
    wire flush_FE, flush_DE, flush_EX, flush_ME; 
    assign flush_FE = reset; 
    assign flush_DE = reset| BranchTaken_EXM1; 
    assign flush_EX = reset| LwStall_EXM1; 
    assign flush_ME = reset; 

    assign AnyStall = 1'b0; 
    wire Stall_FE, Stall_DE, Stall_EX, Stall_ME; 
    assign Stall_FE = AnyStall| LwStall_EXM1 | MisAlignStall_MEM1;
    assign Stall_DE = AnyStall| LwStall_EXM1 | MisAlignStall_MEM1;
    assign Stall_EX = AnyStall| MisAlignStall_MEM1;  
    assign Stall_ME = AnyStall;
 

endmodule 

module dff #(parameter WIDTH = 1)
              (input             clk, reset,
               input [WIDTH-1:0] d,
               output [WIDTH-1:0] q); 
  reg [WIDTH-1:0] q;
  always @(posedge clk)
    if (reset) q <= 0;
    else       q <= d;
endmodule
