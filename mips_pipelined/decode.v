/*
module dff #(parameter WIDTH = 1)
              (input             clk, reset,
               input [WIDTH-1:0] d,
               output [WIDTH-1:0] q);
  reg [WIDTH-1:0] q;
  always @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule
*/
module decode
   (input clk, flush, 
    input AnyStall, 
    input [31:0] FetchData_IF,
    output Jump_ID, 
    output [25:0] JumpTgt_ID,
    output RegWrite_ID, RegDst_ID, AluSrc_ID, MemWrite_ID, MemToReg_ID, Link_ID,
    output [2:0] BpCtl_ID,
    output [3:0] AluControl_ID,
    output [15:0] Imm_ID);
    wire [5:0] opcode;
    wire [15:0] brop; 
    reg [2:0] bpctl; 
    wire [15:0] imm; 
    wire [5:0] funct; 
    assign brop = FetchData_IF[31:16];
    assign opcode = FetchData_IF[31:26];
    assign funct = FetchData_IF[20:15];
    assign imm = FetchData_IF[15:0]; 

    assign JumpTgt_ID = FetchData_IF[25:0];
    assign Jump_ID = jump;
 
    wire regwrite, regdst, alusrc, memwrite, memtoreg;
    reg jump, jal;
    wire link; 
    wire [2:0] aluop;
    reg [7:0] controls;
    reg [3:0] alucontrol; 
 
    assign {regwrite, regdst, alusrc, memwrite, memtoreg, aluop} = controls; 

    always @ *
    case(opcode)
        6'b000000: controls <= 8'b11000100; // RTYPE
        6'b100011: controls <= 8'b10101000; // LW
        6'b101011: controls <= 8'b00110000; // SW
        6'b000100: controls <= 8'b00000010; // BEQ
        6'b000101: controls <= 8'b00000010; // BNE
        6'b001000: controls <= 8'b10100000; // ADDI
        6'b001001: controls <= 8'b10100000; // ADDIU
        6'b001100: controls <= 8'b10100001; // ANDI
        6'b001101: controls <= 8'b10100011; // ORI
        6'b001110: controls <= 8'b10100101; // XORI
        6'b001010: controls <= 8'b10100110; // SLTI
        6'b000011: controls <= 8'b00000000; // JAL
        6'b000010: controls <= 8'b00000000; // J
        6'b001111: controls <= 8'b10100111; // LUI
        default:   controls <= 8'b0xx0xxxx; // illegal op
    endcase
    
    
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
            default:   alucontrol <= 4'bxxxx; // ???
        endcase
    endcase
  
    always @*
        casex(brop)
        16'b000101xxxxxxxxxx: bpctl <= 3'b000; //BNE
        16'b000100xxxxxxxxxx: bpctl <= 3'b001; //BEQ
        16'b000001xxxxx00001: bpctl <= 3'b010; //GEZ
        16'b000001xxxxx10001: bpctl <= 3'b011; //GEZAL
        16'b000110xxxxx00000: bpctl <= 3'b100; //LEZ
        16'b000111xxxxx00000: bpctl <= 3'b101; //BGT
        16'b000001xxxxx00000: bpctl <= 3'b110; //LTZ 
        16'b000001xxxxx10000: bpctl <= 3'b111; //LTZAL
        default:              bpctl <= 3'b000;
    endcase
   
    always @*  
        case(opcode)
        6'b000011: {jump,jal} <= 4'b11; //JAL
        6'b000010: {jump,jal} <= 4'b10; //J
        default:   {jump,jal} <= 2'b00;
    endcase 
    assign link = jal | &bpctl[2:1];
    assign {regwrite, regdst, alusrc, memwrite, memtoreg, aluop} = controls; 
    wire RegWrite_IDM1, RegDst_IDM1, AluSrc_IDM1, MemWrite_IDM1, MemToReg_IDM1; 
    assign RegWrite_IDM1 = AnyStall ? RegWrite_ID : regwrite; 
    assign RegDst_IDM1 = AnyStall ? RegDst_ID : regdst; 
    assign AluSrc_IDM1 = AnyStall ? AluSrc_ID : alusrc; 
    assign MemWrite_IDM1 = AnyStall ? MemWrite_ID : memwrite; 
    assign MemToReg_IDM1 = AnyStall ? MemToReg_ID : memtoreg; 
    wire [3:0] AluControl_IDM1;
    assign AluControl_IDM1 = AnyStall ? AluControl_ID : alucontrol;
    wire Link_IDM1; 
    assign Link_IDM1 = AnyStall ? Link_ID : link; 
    wire [2:0] BpCtl_IDM1; 
    assign BpCtl_IDM1 = AnyStall ? BpCtl_ID  : bpctl;
    wire [15:0] Imm_IDM1; 
    assign Imm_IDM1 = AnyStall ? Imm_ID : imm;
 
    dff #(16) dff_imm      (clk,reset,  Imm_IDM1,         Imm_ID);
    dff #(3)  dff_bpctl    (clk,reset,  BpCtl_IDM1,       BpCtl_ID); 
    dff #(1)  dff_link     (clk,reset,  Link_IDM1,        Link_ID);  
    dff #(4)  dff_aluctl   (clk, reset, AluControl_IDM1 , AluControl_ID); 
    dff #(1)  dff_regwrite (clk, reset, RegWrite_IDM1 ,   RegWrite_ID );
    dff #(1)  dff_regdst   (clk, reset, RegDst_IDM1   ,   RegDst_ID  );
    dff #(1)  dff_alusrc   (clk, reset, AluSrc_IDM1   ,   AluSrc_ID   );
    dff #(1)  dff_memwrite (clk, reset, MemWrite_IDM1 ,   MemWrite_ID );
    dff #(1)  dff_memtoreg (clk, reset, MemToReg_IDM1 ,   MemToReg_ID );
endmodule
