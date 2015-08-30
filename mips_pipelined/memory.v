//IFM1
//    IF    
//    IDM1
//        ID
//        EXM1
//            EX
//            MEM1
//                ME
//
//MEM1:   D$  
//ME:     Writeback
module memory
   (input clk, flush, 
    input AnyStall, 
    input [31:0] Result_EX,
    input [31:0] WrDat_EX,
    input RegWrite_EX, MemToReg_EX, MemWrite_EX, 
    input [4:0] WriteReg_EX,
    input InstrVal_EX, LoadB_EX, StoreB_EX,
    output [31:0] RdDat_ME,
    output [31:0] Result_ME,
    output [4:0] WriteReg_ME,
    output  RegWrite_ME, MemToReg_ME,
    output [31:0] ResultRdDat_ME);

    wire [31:0] DatAdr, RdDat;
    wire WrEn; 
    wire [31:0] RdDat_MEM1, Result_MEM1, StoreDat, LoadDat; 
    wire RegWrite_MEM1, MemToReg_MEM1; 
    wire [4:0] WriteReg_MEM1; 
    
    dmem dmem(clk, WrEn, DatAdr, StoreDat, RdDat);
    
    assign DatAdr = Result_EX; 
    assign LoadDat = LoadB_EX ? RdDat & 32'hFF : RdDat; 
    assign StoreDat = StoreB_EX ? WrDat_EX & 32'hFF : WrDat_EX; 
    
    assign WrEn = AnyStall ? 1'b0 : MemWrite_EX; 
    assign RdDat_MEM1  = AnyStall ? RdDat_ME : LoadDat; 
    assign Result_MEM1 = AnyStall ? Result_ME : Result_EX; 
    assign RegWrite_MEM1 = AnyStall ? RegWrite_ME : RegWrite_EX;  
    assign MemToReg_MEM1 = AnyStall ? MemToReg_ME : MemToReg_EX; 
    assign WriteReg_MEM1 = AnyStall ? WriteReg_ME : WriteReg_EX; 

    dff #(32) dff_RdDat   (clk, flush, RdDat_MEM1,    RdDat_ME);  
    dff #(32) dff_Result  (clk, flush, Result_MEM1,   Result_ME);  
    dff #(1)  dff_RegWrite(clk, flush, RegWrite_MEM1, RegWrite_ME);  
    dff #(1)  dff_MemToReg(clk, flush, MemToReg_MEM1, MemToReg_ME);  
    dff #(5)  dff_WriteReg(clk, flush, WriteReg_MEM1, WriteReg_ME);  
    
    assign ResultRdDat_ME = MemToReg_ME ? RdDat_ME : Result_ME;

    // Preformance Counters
    wire [15:0] Cycles_ME, Cycles_MEM1, Instr_ME, Instr_MEM1; 
    assign Cycles_MEM1 = Cycles_ME + 16'd1;
    assign Instr_MEM1 = Instr_ME + {15'b0,InstrVal_EX};
    dff #(16) dff_InstrCnt(clk, flush, Cycles_MEM1, Cycles_ME); 
    dff #(16) dff_CyclCnt(clk, flush, Instr_MEM1, Instr_ME);

endmodule

module dmem(input        clk, we,
            input [31:0] a, wd,
            output [31:0] rd);

  reg [31:0] RAM[63:0];

  assign rd = RAM[a[7:2]]; // word aligned

  always @(posedge clk)
    if (we) RAM[a[7:2]] <= wd;
endmodule
