//IFM1
//    IF    
//    IDM1
//        ID
//        EXM1
//            EX
//            MEM1
//                ME
//
//IFM1:   Next PC logic, I$ fetch
module fetch
   (input clk, flush, 
    input AnyStall, 
    input [25:0] JumpTgt_IDM1,
    input Jump_IDM1, 
    input [31:0] RedirectPc_EXM1,
    input BranchTaken_EXM1,
    input [31:0] InstrFill_SY0,
    output [31:0] PcReq_SY0,
    output InstrVal_IF,  
    output [31:0] Pc_IF, FetchData_IF);

    wire InstrVal_IFM1; 
    wire FlushHold; 
    wire [31:0] FetchData_IFM1;
    reg  [31:0] Pc_IFM1; 
    wire [31:0] Pc_IF; 
    wire [31:0] nPc_IFM1;
    wire [31:0] DeRedirectPc; 
    wire [31:0] RedirectPc;
    wire        StallPc;
 
    assign PcReq_SY0 = Pc_IFM1; 
    assign  FetchData_IFM1 = AnyStall ? FetchData_IF : InstrFill_SY0;
    
    assign  nPc_IFM1 = Pc_IF + 4; 
    assign  DeRedirectPc = {nPc_IFM1[31:28], JumpTgt_IDM1[25:0], 2'b00};
    assign StallPc = AnyStall | FlushHold; 
    always @*
        casez ({Jump_IDM1, BranchTaken_EXM1, StallPc})
            3'b??1: Pc_IFM1 = Pc_IF; 
            3'b?10: Pc_IFM1 = RedirectPc_EXM1;
            3'b100: Pc_IFM1 = DeRedirectPc; 
            3'b000: Pc_IFM1 = nPc_IFM1; 
        endcase
    dff #(32) dff_FetchData (clk,flush, FetchData_IFM1, FetchData_IF); 
    dff #(32) dff_PC (clk,flush,Pc_IFM1, Pc_IF); 
    
    assign InstrVal_IFM1 = AnyStall ? InstrVal_IF : 1'b1; 
    dff #(1)  dff_InstrVal(clk,flush,InstrVal_IFM1,InstrVal_IF);
    dff #(1)  dff_FlushHold(clk,1'b0, flush,FlushHold); 
endmodule
