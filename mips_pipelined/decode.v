//IFM1
//    IF    
//    IDM1
//        ID
//        EXM1
//            EX
//            MEM1
//                ME
//
//IDM1:   Main decoder, Alu decoder, branch unit decoder, register file 
module decode
   (input clk, flush, 
    input AnyStall, 
    input [31:0] Pc_IF, FetchData_IF, 
    input InstrVal_IF, 
    input RegWrite_ME, MemToReg_ME,
    input [31:0] RdDat_ME, Result_ME,
    input [4:0] WriteReg_ME, 
    output Jump_IDM1, 
    output [25:0] JumpTgt_IDM1,
    output RegWrite_ID, RegDst_ID, AluSrc_ID, MemWrite_ID, MemToReg_ID, Link_ID,
    output [4:0] BpCtl_ID,   
    output Jr_ID,
    output [3:0] AluControl_ID,
    output [31:0] Imm_ID,
    output [4:0] Rs_ID, Rt_ID, Rd_ID, 
    output [31:0] RdDatA_ID, RdDatB_ID, ExRedirectPc_ID, Pc_ID,  
    output InstrVal_ID, StoreB_ID, LoadB_ID);

    wire [31:0] RdDatA, RdDatB, SignImm, Imm; 
    wire [5:0] opcode;
    wire [15:0] brop; 
    reg [4:0] bpctl; 
    wire [15:0] imm; 
    wire [5:0] funct; 
    wire regwrite, regdst, alusrc, memwrite, memtoreg;
    wire [31:0] ExRedirectPc; 
    reg jump, jal;
    wire link; 
    wire WrEn; 
    wire [2:0] aluop;
    wire signex; 
    reg [6:0] controls;
    reg [3:0] alucontrol; 
    wire [31:0] WrDat;
    wire [4:0] WriteRegLink; 
    wire loadb, storeb; 
 
    assign brop = FetchData_IF[31:16];
    assign opcode = FetchData_IF[31:26];
    assign funct = FetchData_IF[5:0];
    assign imm = FetchData_IF[15:0]; 

    assign JumpTgt_IDM1 = FetchData_IF[25:0];
    assign Jump_IDM1 = jump;
    assign SignImm = {{16{imm[15]}},imm}; 
    assign Imm = signex ? SignImm : { 16'b0, imm};
    //assign Imm = signex ? SignImm : SignImm;
    //TODO- rename
    assign ExRedirectPc = Pc_IF + {SignImm[29:0],2'b0} +4;

    // TODO--move to ME--It logically lives there..
    assign WrDat = MemToReg_ME ? RdDat_ME : Result_ME; 
    assign WrEn = RegWrite_ME;
    regfile rf(clk, WrEn, FetchData_IF[25:21], FetchData_IF[20:16], 
               WriteReg_ME, WrDat, 
               RdDatA, RdDatB);
 
    assign {
            regwrite, regdst, memwrite, memtoreg, aluop} = controls; 
    /* verilator lint_off COMBDLY */
    always @ *
    case(opcode)
        6'b000000: controls <= 7'b1100100; // RTYPE
        6'b100011: controls <= 7'b1001000; // LW
        6'b101011: controls <= 7'b0010000; // SW
        6'b100000: controls <= 7'b1001000; // LB
        6'b101000: controls <= 7'b0010000; // SB
        6'b000100: controls <= 7'b0000010; // BEQ
        6'b000101: controls <= 7'b0000010; // BNE
        6'b001000: controls <= 7'b1000000; // ADDI
        6'b001001: controls <= 7'b1000000; // ADDIU
        6'b001100: controls <= 7'b1000001; // ANDI
        6'b001101: controls <= 7'b1000011; // ORI
        6'b001110: controls <= 7'b1000101; // XORI
        6'b001010: controls <= 7'b1000110; // SLTI
        6'b000011: controls <= 7'b1000000; // JAL
        6'b000010: controls <= 7'b0000000; // J
        6'b001111: controls <= 7'b1000111; // LUI
        default:   controls <= 7'b0000xxx; // illegal op
    endcase
   
    // Sign extend 
    always @ *
    /* verilator lint_off CASEOVERLAP */
    casez(opcode)
        6'b1000??: {alusrc,signex} = 2'b10; // LW
        6'b1010??: {alusrc,signex} = 2'b10; // SW
        6'b00100?: {alusrc,signex} = 2'b11; // ADDI
        6'b001???: {alusrc,signex} = 2'b10; // *I
        default:   {alusrc,signex} = 2'bxx; 
    endcase 
    /* verilator lint_on CASEOVERLAP */

    always @ *
    case(aluop)
        3'b000: alucontrol <= 4'b0010;  // add (for lw/sw/addi)
        3'b010: alucontrol <= 4'b0110;  // sub (for beq)
        3'b001: alucontrol <= 4'b0000;  // and (for andi)
        3'b011: alucontrol <= 4'b0001;  // or (for ori)
        3'b101: alucontrol <= 4'b1001;  // xor (for xori)
        3'b111: alucontrol <= 4'b1001;  // LUI
        3'b110: alucontrol <= 4'b0111;
        //3'b100: //RESERVED 
        default: case(funct)          // R-type instructions
            6'b011000: alucontrol <= 4'b1111; // mult
            6'b011010: alucontrol <= 4'b1110; // div
            6'b100100: alucontrol <= 4'b0000; // and
            6'b100101: alucontrol <= 4'b0001; // or
            6'b100000: alucontrol <= 4'b0010; // add
            6'b100001: alucontrol <= 4'b0010; // addu
            6'b100110: alucontrol <= 4'b0101; // xor
            6'b100010: alucontrol <= 4'b0110; // sub
            6'b100011: alucontrol <= 4'b0110; // subu
            6'b101010: alucontrol <= 4'b0111; // slt
            6'b101011: alucontrol <= 4'b0111; // sltu
            6'b010000: alucontrol <= 4'b1010; // mfhi
            6'b010010: alucontrol <= 4'b1011; // mflo
            6'b000110: alucontrol <= 4'b0100; // srlv
            6'b000010: alucontrol <= 4'b1101; // srl
            6'b000000: alucontrol <= 4'b1100; // sll
            6'b000100: alucontrol <= 4'b0011; // sllv
            6'b000011: alucontrol <= 4'b1110; // sra
            //6'b001000: alucontrol <= 4'b0000; // jr
            default:   alucontrol <= 4'bxxxx; // ???
        endcase
    endcase
  
    always @*
        casez(brop)
        16'b000111?????00000: bpctl <= 5'b10110; //BGT
        16'b000001?????00001: bpctl <= 5'b10100; //GEZ
        16'b000001?????10001: bpctl <= 5'b10101; //GEZAL
        16'b000001?????00000: bpctl <= 5'b10000; //LTZ 
        16'b000001?????10000: bpctl <= 5'b10001; //LTZAL
        16'b000110?????00000: bpctl <= 5'b10010; //LEZ
        16'b000101??????????: bpctl <= 5'b11000; //BNE
        16'b000100??????????: bpctl <= 5'b11100; //BEQ
        default:              bpctl <= 5'b0xxxx;
    endcase
 
    always @*  
        case(opcode)
        6'b000011: {jump,jal} <= 2'd3; //JAL
        6'b000010: {jump,jal} <= 2'd2; //J
        default:   {jump,jal} <= 2'd0;
    endcase 
    assign link = jal | bpctl[0];
    assign WriteRegLink = link ? 5'd31 : FetchData_IF[20:16];
    /* verilator lint_on COMBDLY */

    assign loadb  = FetchData_IF[27:26] == 0;
    assign storeb = FetchData_IF[27:26] == 0;

    wire RegWrite_IDM1, RegDst_IDM1, AluSrc_IDM1, MemWrite_IDM1, MemToReg_IDM1, Jr_IDM1; 
    assign RegWrite_IDM1 = AnyStall ? RegWrite_ID : regwrite; 
    assign RegDst_IDM1 = AnyStall ? RegDst_ID : regdst; 
    assign AluSrc_IDM1 = AnyStall ? AluSrc_ID : alusrc; 
    assign MemWrite_IDM1 = AnyStall ? MemWrite_ID : memwrite; 
    assign MemToReg_IDM1 = AnyStall ? MemToReg_ID : memtoreg; 
    assign Jr_IDM1 = AnyStall ? Jr_ID : funct==6'd8 & opcode==6'b0; 
    wire [3:0] AluControl_IDM1;
    assign AluControl_IDM1 = AnyStall ? AluControl_ID : alucontrol;
    wire Link_IDM1; 
    assign Link_IDM1 = AnyStall ? Link_ID : link; 
    wire [4:0] BpCtl_IDM1; 
    assign BpCtl_IDM1 = AnyStall ? BpCtl_ID  : bpctl;
    wire [31:0] RdDatA_IDM1, RdDatB_IDM1; 
    assign RdDatA_IDM1 = AnyStall ? RdDatA_ID : RdDatA;  
    assign RdDatB_IDM1 = AnyStall ? RdDatB_ID : RdDatB;
    wire [31:0] Imm_IDM1; 
    assign Imm_IDM1 = AnyStall ? Imm_ID : Imm; 
    wire [4:0] Rt_IDM1, Rd_IDM1, Rs_IDM1;
    assign Rt_IDM1 = AnyStall ? Rt_ID : WriteRegLink;
    assign Rd_IDM1 = AnyStall ? Rd_ID : FetchData_IF[15:11];
    assign Rs_IDM1 = AnyStall ? Rs_ID : FetchData_IF[25:21];
    wire [31:0] ExRedirectPc_IDM1;
    assign ExRedirectPc_IDM1 = AnyStall ? ExRedirectPc_ID : ExRedirectPc; 
    wire [31:0] Pc_IDM1;
    assign Pc_IDM1 = AnyStall ? Pc_ID : Pc_IF; 
    wire LoadB_IDM1, StoreB_IDM1; 
    assign LoadB_IDM1 = AnyStall ? LoadB_ID : loadb;   
    assign StoreB_IDM1 = AnyStall ? StoreB_ID : storeb;   

    dff #(1)  dff_StoreB(clk,flush,StoreB_IDM1,StoreB_ID);  
    dff #(1)  dff_LoadB (clk,flush,LoadB_IDM1,LoadB_ID);  
    dff #(1)  dff_InstrVal(clk,flush,InstrVal_IF,InstrVal_ID);  
    dff #(32) dff_ExRedirectPc(clk,flush, ExRedirectPc_IDM1, ExRedirectPc_ID);
    dff #(32) dff_Pc(clk,flush, Pc_IDM1, Pc_ID); //Really not the best way to do link ops, eh
    dff #(32) dff_RdDatA   (clk,flush,  RdDatA_IDM1,      RdDatA_ID);
    dff #(32) dff_RdDatB   (clk,flush,  RdDatB_IDM1,      RdDatB_ID);
    dff #(32) dff_SignImm  (clk,flush,  Imm_IDM1,     Imm_ID); 
    dff #(5)  dff_bpctl    (clk,flush,  BpCtl_IDM1,       BpCtl_ID); 
    dff #(1)  dff_jr       (clk,flush,  Jr_IDM1,          Jr_ID); 
    dff #(1)  dff_link     (clk,flush,  Link_IDM1,        Link_ID);  
    dff #(4)  dff_aluctl   (clk, flush, AluControl_IDM1 , AluControl_ID); 
    dff #(5)  dff_Rt       (clk, flush, Rt_IDM1 ,         Rt_ID); 
    dff #(5)  dff_Rd       (clk, flush, Rd_IDM1 ,         Rd_ID); 
    dff #(5)  dff_Rs       (clk, flush, Rs_IDM1 ,         Rs_ID); 
    dff #(1)  dff_regwrite (clk, flush, RegWrite_IDM1 ,   RegWrite_ID );
    dff #(1)  dff_RegDst   (clk, flush, RegDst_IDM1   ,   RegDst_ID  );
    dff #(1)  dff_alusrc   (clk, flush, AluSrc_IDM1   ,   AluSrc_ID   );
    dff #(1)  dff_memwrite (clk, flush, MemWrite_IDM1 ,   MemWrite_ID );
    dff #(1)  dff_memtoreg (clk, flush, MemToReg_IDM1 ,   MemToReg_ID );
endmodule
module regfile(input        clk, 
               input        we3, 
               input [4:0]  ra1, ra2, wa3, 
               input [31:0] wd3, 
               output [31:0] rd1, rd2);
  reg [31:0] rf[31:0];
  

  // three ported register file
  // read two ports combinationally
  // register 0 hardwired to 0

  always @(posedge clk)
    if (we3) begin
        rf[wa3] <= wd3; 
    end 

  assign rd1 = (ra1 != 0) ? 
        (we3 && wa3==ra1) ? wd3 : rf[ra1] 
        : 0;
  assign rd2 = (ra2 != 0) ? 
        (we3 && wa3==ra2) ? wd3 : rf[ra2] 
        : 0;
endmodule

