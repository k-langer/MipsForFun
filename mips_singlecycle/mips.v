module testbench();
    reg        clk;
    reg        reset;
    wire [31:0] dataadr;
    wire signed [31:0] writedata; 
    wire        memwrite;

    top dut(clk, reset, writedata, dataadr, memwrite);

    initial
    begin
        reset <= 1; # 22; reset <= 0;
    end

    // generate clock to sequence tests
    always
    begin
        clk <= 1; # 5; clk <= 0; # 5;
    end

    // check results
    always @(negedge clk)
    begin
        if(memwrite) begin
            if(dataadr === 0 ) begin
                $display("%d\n",writedata);
            end
            if (dataadr === 4) begin
                $finish;
            end 
        end
    end
endmodule

module top(input        clk, reset, 
           output [31:0] writedata, dataadr, 
           output        memwrite);

  wire [31:0] pc, instr, readdata;
  wire dben; 
  // instantiate processor and memories
  mips mips(clk, reset, pc, instr, memwrite, dataadr, 
            writedata, dben, readdata);
  imem imem(pc[7:2], instr);
  dmem dmem(clk, memwrite, dben, dataadr, writedata, readdata);
endmodule

module dmem(input        clk, we,
            input        dben, 
            input [31:0] a, wd,
            output [31:0] rd);

  reg [31:0] RAM[63:0];
  wire [31:0] addr; 

  //assign addr = dben ? a[31:0] : a[31:2];
  assign addr = a[31:0];
  assign rd = dben ? RAM[addr]&32'h000000ff : RAM[addr]; // word aligned
    
  always @(posedge clk)
    if (we)
    RAM[addr] <= dben ? wd[7:0] : wd[31:0];
endmodule

module imem(input [5:0] a,
            output [31:0] rd);
  //A ROM for now
  reg [31:0] RAM[1023:0];
  //VERIFONLY
  initial 
    begin $readmemh( "m.dat" , RAM , 0,63 ); end
  //ENDVERIFONLY
  assign rd = RAM[a]; // word aligned
endmodule

module mips(input        clk, reset,
            output [31:0] pc,
            input [31:0] instr,
            output        memwrite,
            output [31:0] aluout, writedata,
            output        dben, 
            input [31:0] readdata);

  wire       memtoreg, alusrc, regdst, 
              regwrite, jump, pcsrc, zero;
  wire [3:0] alucontrol;
  wire [2:0] bpcontrol; 
  assign dben = 1'b0; 
  controller c(instr[31:16], instr[5:0], zero,
               memtoreg, memwrite,  pcsrc,
               alusrc, regdst, regwrite, bdec, jump, bpcontrol,
               alucontrol);
  datapath dp(clk, reset, memtoreg, pcsrc,
              alusrc, regdst, regwrite, jump,
              bpcontrol, alucontrol, bdec, 
              zero, pc, instr,
              aluout, writedata, readdata);
endmodule

module controller(input [15:0] op, 
                  input [5:0] funct,
                  input       zero,
                  output       memtoreg, memwrite,
                  output       pcsrc, alusrc,
                  output       regdst, regwrite,
                  output       bdec, 
                  output       jump,
                  output [2:0] bpcontrol, 
                  output [3:0] alucontrol);

  wire [2:0] aluop;
  wire       bdec, branch;
  wire       branch_ne; 
  wire [2:0] bpop; 

  maindec md(op, memtoreg, memwrite, branch, branch_ne, bdec, 
             alusrc, regdst, regwrite, jump, bpcontrol, aluop);
  aludec  ad(funct, aluop, alucontrol);
  assign pcsrc = ( branch & zero ) | (branch_ne & !zero);
endmodule

module maindec(input [15:0] op,
            output       memtoreg, memwrite,
            output       branch, branch_ne, bdec, alusrc,
            output       regdst, regwrite,
            output       jump,
            output [2:0] bpop, 
            output [2:0] aluop);

    reg [10:0] controls;
    reg [2:0]  bpop; 
    assign bdec = 1'b0; 

    assign {regwrite, regdst, alusrc, branch, branch_ne,
         memwrite, memtoreg, jump, aluop} = controls;
    // TODO Clean up casex xprop for timing
    always @*
    case(op[15:10])
        6'b000000: controls <= 11'b11000000100; // RTYPE
        6'b100011: controls <= 11'b10100010000; // LW
        6'b101011: controls <= 11'b00100100000; // SW
        6'b000100: controls <= 11'b00010000010; // BEQ
        6'b000101: controls <= 11'b00001000010; // BNE
        6'b001000: controls <= 11'b10100000000; // ADDI
        6'b001001: controls <= 11'b10100000000; // ADDIU
        6'b001100: controls <= 11'b10100000001; // ANDI
        6'b001101: controls <= 11'b10100000011; // ORI
        6'b001110: controls <= 11'b10100000101; // XORI
        6'b001010: controls <= 11'b10100000110; // SLTI
        6'b000011: controls <= 11'b00011001000; // JAL
        6'b000010: controls <= 12'b00000001000; // J
        6'b001111: controls <= 12'b10100000111; // LUI
        default:   controls <= 12'bxxxxxxxxxxx; // illegal op
    endcase

    always @*
    casex(op)
        16'b000001xxxxx00000: bpop <= 3'b000; //LTZ 
        16'b000001xxxxx10000: bpop <= 3'b100; //LTZAL
        16'b000001xxxxx00001: bpop <= 3'b010; //GEZ
        16'b000001xxxxx10001: bpop <= 3'b110; //GEZAL
        16'b000110xxxxx00000: bpop <= 3'b001; //LEZ
        16'b000111xxxxx00000: bpop <= 3'b011; //BGT
        16'b000011xxxxxxxxxx: bpop <= 3'b111; //JAL
        default:              bpop <= 3'b101;
    endcase
endmodule

module bralu(input [2:0] brop, 
             input [31:0] a,
             output link, 
             output result );
  wire branchTgt; 
  reg result;
  assign link = (brop[2]&brop[1]&brop[0]) | ( brop[2]&result ); 
  assign branchTgt = a[31] | ( a==32'b0&brop[0] );
  always @*
  casex (brop) 
      3'bx00: result =  branchTgt; //LTZ
      3'bx10: result = ~branchTgt; //GEZ
      3'b001: result =  branchTgt; //LEZ
      3'b011: result = ~branchTgt; //BGT
      default:result = 1'b0; 
  endcase 
endmodule

module aludec(input [5:0] funct,
              input [2:0] aluop,
              output [3:0] alucontrol);
    reg [3:0] alucontrol;

    always @ (aluop or funct)
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
endmodule

module datapath(input        clk, reset,
                input        memtoreg, pcsrc,
                input        alusrc, regdst,
                input        regwrite, jump,
                input [2:0]  bpcontrol, 
                input [3:0]  alucontrol,
                input        bdec, 
                output        zero,
                output [31:0] pc,
                input [31:0] instr,
                output [31:0] aluout, writedata,
                input [31:0] readdata);

  wire [4:0]  writereg, writeaddr;
  wire [31:0] pcplus4, pcbranch;
  reg  [31:0] pcnext;
  wire [31:0] signimm;
  wire [31:0] srca, srcb;
  wire [31:0] result;
  wire [31:0] srcbimm;
  wire branch; 
  wire link, bpdir;
 
  bralu bpalu(bpcontrol,srca, link,bpdir); 
  assign branch = pcsrc | bpdir;
  dff #(32) pcreg(clk, reset, 1'b1, pcnext, pc);
  
  always @* begin 
    pcnext = pc+4; 
    if (jump)  pcnext = {pcnext[31:28],instr[25:0],2'b00}; 
    else if (branch) pcnext = pcnext+(signimm<<2); 
  end 
  
  // register file w/ jal write port
  wire [31:0] RegWr; 
  mux2 #(32)  regmux(result,pc+8,link,RegWr); 
  regfile     rf(clk, regwrite, instr[25:21], instr[20:16], 
                 writereg, RegWr, srca, writedata);
  //assign srca = srcrf | {5{regdst}}&instr[10:6]; //add shmt  
  //mux2 (input [WIDTH-1:0] d0, d1,input s, output [WIDTH-1:0] y);
  mux2 #(5)   wrmux(instr[20:16], instr[15:11],
                    regdst, writereg);
  //mux2 #(5)   linkmux(writereg,5'd31,link,writeaddr);
  mux2 #(32)  resmux(aluout, readdata, memtoreg, result);
  signext     se(instr[15:0], signimm);

  // ALU wire
  mux2 #(32)  srcbmux(writedata, signimm, alusrc, srcb);
  alu         alu(srca, srcb, instr[10:6], alucontrol, clk, aluout, zero);
endmodule

module regfile(input        clk, 
               input        we3, 
               input [4:0]  ra1, ra2, wa3, 
               input [31:0] wd3, 
               output [31:0] rd1, rd2);
  reg [31:0] rf[31:0];
  

  // three ported register file
  // read two ports combinationally
  // write third port on rising edge of clk
  // register 0 hardwired to 0
  // note: for pipelined processor, write third port
  // on falling edge of clk

  always @(posedge clk) begin
    if (we3)
    rf[wa3] <= wd3; 
  end
  /*
  always @(posedge clk) begin
    if (link) begin 
        rf[5'b1] <= linkaddr; 
    end else if (we3) begin
        rf[wa3] <= wd3;	
    end
  end
  */
  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

module adder(input [31:0] a, b,
             output [31:0] y);

  assign y = a + b;
endmodule

module signext(input [15:0] a,
               output [31:0] y);
              
  assign y = {{16{a[15]}}, a};
endmodule

module dff #(parameter WIDTH = 8)
              (input             clk, reset, enable,
               input [WIDTH-1:0] d, 
               output [WIDTH-1:0] q);
  reg [WIDTH-1:0] q; 
  always @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else if (enable) q <= d;
endmodule
module mux2 #(parameter WIDTH = 8)
             (input [WIDTH-1:0] d0, d1, 
              input             s, 
              output [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module mux4 #(parameter WIDTH = 8)
             (input [WIDTH-1:0] d0, d1, d2, d3, 
              input [1:0]        s, 
              output [WIDTH-1:0] y);

  assign y = s[1] ? 
             s[0] ? d3 : d2: 
             s[0] ? d1 : d0; 
endmodule

module alu(input signed [31:0] a, b,
           input [4:0] shamt, 
           input [3:0]  alucontrol,
           input        clk, 
           output signed [31:0] result,
           output        zero);
  wire [31:0] condinvb, sum;
  // Non-architectural registers 
  reg [63:0] muldivnext; 
  wire [63:0] muldiv; 
  

  assign condinvb = alucontrol[2] ? ~b : b;
  assign sum = a + condinvb + alucontrol[2];
  //assign branchTgt = a[31] | (!(|a) & alucontrol[0]);
  reg [31:0] result; 
    
    // FIXME Worlds stupidest encoding
    /*
  dff #(32) hireg(clk, 1'b0, muldivnext[63:32], muldiv[63:32]);
  dff #(32) loreg(clk, 1'b0, muldivnext[31:0], muldiv[31:0]);
    always @ *
        case (alucontrol[3:0])
          4'b1111: muldivnext = a * b; 
          4'b1110: muldivnext = a / b; 
          default: muldivnext = muldiv;
        endcase
    */
    always @ *
        case (alucontrol[3:0])
          //4'b1000: mul
          //4'b1001: div
          4'b1010: result = muldiv[63:32];
          4'b1011: result = muldiv[31:0];
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
          4'b0111: result = sum[31];
          default: result = 32'bx;  
        endcase
  assign zero = (result == 32'b0);
endmodule
