//IFM1
//    IF    
//    IDM1
//        ID
//        EXM1
//            EX
//            MEM1
//                ME
//
//EXM1:   ALU, datapath bypass logic, branch unit
module execute
   (input clk, flush, 
    input AnyStall, 
    input AluSrc_ID, RegDst_ID, 
    input [4:0] BpCtl_ID, 
    input Jr_ID, 
    input [3:0] AluControl_ID,
    input [31:0] ExRedirectPc_ID, Pc_ID, Imm_ID, 
    input RegWrite_ID, MemWrite_ID, MemToReg_ID, Link_ID, 
    input [31:0] RdDatA_ID, RdDatB_ID, 
    input [4:0]  Rs_ID, Rt_ID, Rd_ID, WriteReg_ME,
    input LoadB_ID, StoreB_ID, InstrVal_ID, RegWrite_ME,
    input [31:0] ResultRdDat_ME,
    output LwStall_EXM1,
    output [31:0] Result_EX, WrDat_EX, 
    output [4:0] WriteReg_EX,
    output RegWrite_EX, MemToReg_EX, MemWrite_EX,
    output BranchTaken_EXM1, 
    output [31:0] RedirectPc_EXM1, 
    output InstrVal_EX, LoadB_EX, StoreB_EX
    );

    reg  [31:0] a,bNoImm;
    wire [31:0] b; 
    assign b = AluSrc_ID ? Imm_ID : bNoImm; 
    wire [5:0] shamt; //HACK
    reg  [31:0] result;
    wire  [31:0] ResultLink;
    wire [31:0] condinvb, sum;
    wire [4:0] WrReg; // HACK
    wire ResultBypRs_EXM1EX, ResultBypRs_EXM1ME, ResultBypRt_EXM1EX, ResultBypRt_EXM1ME; 
    wire RegWriteLink; 

    assign WrReg = RegDst_ID ? Rd_ID : Rt_ID; 
    assign condinvb = AluControl_ID[2] ? ~b : b;
    assign sum = a + condinvb + {31'b0,AluControl_ID[2]};
    
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
    
    assign ResultLink = Link_ID ? Pc_ID + 8 : result; //FIXME better link optimization  

    //Data Hazard bypass and stall logic 
    assign LwStall_EXM1 = (((Rs_ID === Rt_EX) || (Rt_ID === Rt_EX)) && MemToReg_EX && !AnyStall);  

    assign ResultBypRs_EXM1EX = ((Rs_ID != 5'b0) && (Rs_ID === WriteReg_EX) && RegWrite_EX );
    assign ResultBypRs_EXM1ME = ((Rs_ID != 5'b0) && (Rs_ID === WriteReg_ME) && RegWrite_ME );
    assign ResultBypRt_EXM1EX = ((Rt_ID != 5'b0) && (Rt_ID === WriteReg_EX) && RegWrite_EX );
    assign ResultBypRt_EXM1ME = ((Rt_ID != 5'b0) && (Rt_ID === WriteReg_ME) && RegWrite_ME );
    always @*
        casez ( {ResultBypRs_EXM1EX,ResultBypRs_EXM1ME} )
            2'b1?: a[31:0] = Result_EX;
            2'b01: a[31:0] = ResultRdDat_ME;
            2'b00: a[31:0] = RdDatA_ID;
        endcase
    always @*
        casez ( {ResultBypRt_EXM1EX,ResultBypRt_EXM1ME} )
            2'b1?: bNoImm[31:0] = Result_EX;
            2'b01: bNoImm[31:0] = ResultRdDat_ME;
            2'b00: bNoImm[31:0] = RdDatB_ID;
        endcase

    // Branch Unit -- mostly works
    wire BrLsThn, BrEql; 
    reg BrTkn;
    assign BrEql = a == bNoImm; 
    assign BrLsThn = a[31] | ( a==32'b0&BpCtl_ID[1] );
    always @*
    casez (BpCtl_ID)
        5'b110?0: BrTkn = ~BrEql;      //BNE
        5'b111?0: BrTkn =  BrEql;      //BEQ
        5'b1011?: BrTkn =  ~BrLsThn;   //BGT
        5'b1010?: BrTkn =  ~BrLsThn;   //GEZ
        5'b1000?: BrTkn =  BrLsThn;    //LTZ 
        5'b1001?: BrTkn =  BrLsThn;    //LEZ
        default: BrTkn = 1'b0;
    endcase
 
    assign BranchTaken_EXM1 = BrTkn | Jr_ID; 
    assign RedirectPc_EXM1 = Jr_ID ? a : ExRedirectPc_ID ;
    assign RegWriteLink = RegWrite_ID | BrTkn & Link_ID; 
 
    wire [31:0] Result_EXM1, WrDat_EXM1;
    wire [4:0] WriteReg_EXM1, Rt_EX, Rt_EXM1;
    wire RegWrite_EXM1, MemToReg_EXM1, MemWrite_EXM1;
    wire LoadB_EXM1, StoreB_EXM1; 
    assign Result_EXM1 = AnyStall ? Result_EX : ResultLink; 
    assign WrDat_EXM1 = AnyStall ? WrDat_EX : bNoImm; 
    assign RegWrite_EXM1 = AnyStall ? RegWrite_EX : RegWriteLink;
    assign MemToReg_EXM1 = AnyStall ? MemToReg_EX : MemToReg_ID;
    assign MemWrite_EXM1 = AnyStall ? MemWrite_EX : MemWrite_ID;
    assign WriteReg_EXM1 = AnyStall ? WriteReg_EX : WrReg; 
    assign Rt_EXM1 = AnyStall ? Rt_EX : Rt_ID; 
    assign LoadB_EXM1 = AnyStall ? LoadB_EX : LoadB_ID;   
    assign StoreB_EXM1 = AnyStall ? StoreB_EX : StoreB_ID;   
    dff #(32) dff_Result   (clk,flush, Result_EXM1,   Result_EX);
    dff #(32) dff_WrDat    (clk,flush, WrDat_EXM1,    WrDat_EX);
    dff #(5)  dff_WriteReg (clk,flush, WriteReg_EXM1, WriteReg_EX); 
    dff #(5)  dff_RtEx     (clk,flush, Rt_EXM1, Rt_EX); 
    dff #(1)  dff_RegWrite (clk,flush, RegWrite_EXM1, RegWrite_EX);
    dff #(1)  dff_MemToReg (clk,flush, MemToReg_EXM1, MemToReg_EX);
    dff #(1)  dff_MemWrite (clk,flush, MemWrite_EXM1, MemWrite_EX);
    dff #(1)  dff_InstrVal(clk,flush,InstrVal_ID,InstrVal_EX);
    dff #(1)  dff_StoreB(clk,flush,StoreB_EXM1,StoreB_EX);  
    dff #(1)  dff_LoadB (clk,flush,LoadB_EXM1,LoadB_EX);  

endmodule
