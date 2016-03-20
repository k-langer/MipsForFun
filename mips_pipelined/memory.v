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
    output [31:0] ResultRdDat_ME,
    output MisAlignStall_MEM1 );

    wire [31:0] DatAdr, RdDat;
    wire WrEn; 
    wire [31:0] RdDat_MEM1, Result_MEM1, StoreDat, LoadDat; 
    wire RegWrite_MEM1, MemToReg_MEM1; 
    wire [4:0] WriteReg_MEM1; 
    wire [1:0] MisAlignAddrLo; 
    wire       flushMisAlign; 
    wire MisAlignLd, NxtMisAlignLd; 
    reg  [31:0] MisAlignLdDat;
    wire  [31:0] LoadDatByte;

    dmem dmem(clk, WrEn, DatAdr, StoreDat, RdDat);
    
    assign DatAdr = MisAlignLd ? Result_EX+4 : Result_EX; 
    assign LoadDat = LoadB_EX ? LoadDatByte : 
                     |MisAlignAddrLo ? MisAlignLdDat : RdDat; 

    assign StoreDat = StoreB_EX ? WrDat_EX & 32'hFF : WrDat_EX; 
    
    assign WrEn = AnyStall ? 1'b0 : MemWrite_EX; 
    assign RdDat_MEM1  = AnyStall ? RdDat_ME : LoadDat; 
    assign Result_MEM1 = AnyStall ? Result_ME : Result_EX; 
    assign RegWrite_MEM1 = AnyStall ? RegWrite_ME : RegWrite_EX;  
    assign MemToReg_MEM1 = AnyStall ? MemToReg_ME : MemToReg_EX; 
    assign WriteReg_MEM1 = AnyStall ? WriteReg_ME : WriteReg_EX; 

    dff #(32) dff_RdDat   (clk, flush, RdDat_MEM1,    RdDat_ME);  
    dff #(32) dff_Result  (clk, flush, Result_MEM1,   Result_ME);  
    dff #(1)  dff_RegWrite(clk, flushMisAlign, RegWrite_MEM1, RegWrite_ME);  
    dff #(1)  dff_MemToReg(clk, flushMisAlign, MemToReg_MEM1, MemToReg_ME);  
    dff #(5)  dff_WriteReg(clk, flushMisAlign, WriteReg_MEM1, WriteReg_ME);  
    dff       dff_MisAlignLd   (clk, flush, NxtMisAlignLd, MisAlignLd);  
        
    assign ResultRdDat_ME = MemToReg_ME ? RdDat_ME : Result_ME;

    //Mis-Aligned Addresses
    assign MisAlignAddrLo = Result_EX[1:0]; 
    assign LoadDatByte = { {24{MisAlignLdDat[7]}}, MisAlignLdDat[7:0] } ; // SignEx 
    assign NxtMisAlignLd = (|Result_EX[1:0] ^ MisAlignLd) & MemToReg_MEM1 & ~LoadB_EX;
    //TODO Basically, the LS and EX should be seperated to allow 2 ops 
    // to retire at once. three in the case of a load and alu
    // op should all be able to retire at once w/ 2 reg write ports
    // This allows removing generic stall in exchange for load/store only stall
    assign MisAlignStall_MEM1 = NxtMisAlignLd; 
    assign flushMisAlign = flush | NxtMisAlignLd; 

    always @*
    case (MisAlignAddrLo) 
          2'b11: MisAlignLdDat = { RdDat_ME[23:0], RdDat[31:24]  }; 
          2'b10: MisAlignLdDat = { RdDat_ME[15:0], RdDat[31:16]  }; 
          2'b01: MisAlignLdDat = { RdDat_ME[7:0],  RdDat[31:8]   }; 
          2'b00: MisAlignLdDat = { 24'bx	,  RdDat[7:0]	 }; //For LoadB 
    endcase
    
    // Preformance Counters
    wire [15:0] Cycles_ME, Cycles_MEM1, Instr_ME, Instr_MEM1; 
    assign Cycles_MEM1 = Cycles_ME + 16'd1;
    assign Instr_MEM1 = Instr_ME + {15'b0,InstrVal_EX} - {15'b0,MisAlignLd};
    dff #(16) dff_InstrCnt(clk, flush, Cycles_MEM1, Cycles_ME); //retired
    dff #(16) dff_CyclCnt(clk, flush, Instr_MEM1, Instr_ME);
endmodule

module dmem(input        clk, we,
            input [31:0] a, wd,
            output [31:0] rd);

  reg [31:0] RAM[63:0];
  wire [31:0] SwDat;
  wire [5:0] Addr;
  assign Addr = a[7:2];
  assign rd = RAM[a[7:2]]; // word aligned
  assign SwDat = wd; 
  always @(posedge clk)
    if (we) RAM[a[7:2]] <= SwDat;
endmodule
