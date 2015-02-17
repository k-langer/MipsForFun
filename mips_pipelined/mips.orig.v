module testbench();
    reg        clk;
    reg        reset;

    wire [31:0] dataadr;
    wire signed [31:0] writedata; 
    wire        memwrite;

    // instantiate device to be tested
    top dut(clk, reset, writedata, dataadr, memwrite);

    // initialize test
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
  
  // instantiate processor and memories
  mips mips(clk, reset, pc, instr, memwrite, dataadr, 
            writedata, readdata);
  imem imem(pc[7:2], instr);
  dmem dmem(clk, memwrite, dataadr, writedata, readdata);
endmodule

module dmem(input        clk, we,
            input [31:0] a, wd,
            output [31:0] rd);

  reg [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]]; // word aligned

  always @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;
endmodule

module imem(input [5:0] a,
            output [31:0] rd);

  reg [31:0] RAM[63:0];

  initial
      $readmemh( "m.dat" ,RAM );

  assign rd = RAM[a]; // word aligned
endmodule

module mips(input        clk, reset,
            output [31:0] pc,
            input [31:0] instr,
            output        memwrite,
            output [31:0] aluout, writedata,
            input [31:0] readdata);

  wire       memtoreg, alusrc, regdst, 
              regwrite, jump, pcsrc, zero;
  wire [2:0] alucontrol;
  controller c(instr[31:26], instr[5:0], zero,
               memtoreg, memwrite, pcsrc,
               alusrc, regdst, regwrite, jump,
               alucontrol);
  datapath dp(clk, reset, memtoreg, pcsrc,
              alusrc, regdst, regwrite, jump,
              alucontrol,
              zero, pc, instr,
              aluout, writedata, readdata);
endmodule

module controller(input [5:0] op, funct,
                  input       zero,
                  output       memtoreg, memwrite,
                  output       pcsrc, alusrc,
                  output       regdst, regwrite,
                  output       jump,
                  output [2:0] alucontrol);

  wire [1:0] aluop;
  wire       branch;
  
    
  maindec md(op, memtoreg, memwrite, branch,
             alusrc, regdst, regwrite, jump, aluop);
  aludec  ad(funct, aluop, alucontrol);

  assign pcsrc = branch & zero;
endmodule

module maindec(input [5:0] op,
            output       memtoreg, memwrite,
            output       branch, alusrc,
            output       regdst, regwrite,
            output       jump,
            output [1:0] aluop);

reg [8:0] controls;

    assign {regwrite, regdst, alusrc, branch, memwrite,
          memtoreg, jump, aluop} = controls;

    always @ (op)
    case(op)
        6'b000000: controls <= 9'b110000010; // RTYPE
        6'b100011: controls <= 9'b101001000; // LW
        6'b101011: controls <= 9'b001010000; // SW
        6'b000100: controls <= 9'b000100001; // BEQ
        6'b001000: controls <= 9'b101000000; // ADDI
        6'b000010: controls <= 9'b000000100; // J
        default:   controls <= 9'bxxxxxxxxx; // illegal op
    endcase
endmodule

module aludec(input [5:0] funct,
              input [1:0] aluop,
              output [2:0] alucontrol);
    reg [2:0] alucontrol;

    always @ (aluop or funct)
    case(aluop)
        2'b00: alucontrol <= 3'b010;  // add (for lw/sw/addi)
        2'b01: alucontrol <= 3'b110;  // sub (for beq)
        default: case(funct)          // R-type instructions
            6'b100000: alucontrol <= 3'b010; // add
            6'b100010: alucontrol <= 3'b110; // sub
            6'b100100: alucontrol <= 3'b000; // and
            6'b100101: alucontrol <= 3'b001; // or
            6'b101010: alucontrol <= 3'b111; // slt
            6'b100110: alucontrol <= 3'b101; // xor
            default:   alucontrol <= 3'bxxx; // ???
    endcase
    endcase
endmodule
module fetch(input clk, reset, 
             input jump, 
             input [15:0] imm, 
             input [31:0] pc, 
             output [31:0] instr) 

module datapath(input        clk, reset,
                input        memtoreg, pcsrc,
                input        alusrc, regdst,
                input        regwrite, jump,
                input [2:0]  alucontrol,
                output        zero,
                output [31:0] pc,
                input [31:0] instr,
                output [31:0] aluout, writedata,
                input [31:0] readdata);

  wire [4:0]  writereg;
  wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
  wire [31:0] signimm, signimmsh;
  wire [31:0] srca, srcb;
  wire [31:0] result;

  // next PC wire
  flopr #(32) pcreg(clk, reset, pcnext, pc);
  adder       pcadd1(pc, 32'b100, pcplus4);
  sl2         immsh(signimm, signimmsh);
  adder       pcadd2(pcplus4, signimmsh, pcbranch);
  mux2 #(32)  pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
  mux2 #(32)  pcmux(pcnextbr, {pcplus4[31:28], 
                    instr[25:0], 2'b00}, jump, pcnext);

  // register file wire
  regfile     rf(clk, regwrite, instr[25:21], instr[20:16], 
                 writereg, result, srca, writedata);
  mux2 #(5)   wrmux(instr[20:16], instr[15:11],
                    regdst, writereg);
  mux2 #(32)  resmux(aluout, readdata, memtoreg, result);
  signext     se(instr[15:0], signimm);

  // ALU wire
  mux2 #(32)  srcbmux(writedata, signimm, alusrc, srcb);
  alu         alu(srca, srcb, alucontrol, aluout, zero);
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

  always @(posedge clk)
    if (we3) begin
        rf[wa3] <= wd3;	
    end

  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

module adder(input [31:0] a, b,
             output [31:0] y);

  assign y = a + b;
endmodule

module sl2(input [31:0] a,
           output [31:0] y);

  // shift left by 2
  assign y = {a[29:0], 2'b00};
endmodule

module signext(input [15:0] a,
               output [31:0] y);
              
  assign y = {{16{a[15]}}, a};
endmodule

module flopr #(parameter WIDTH = 8)
              (input             clk, reset,
               input [WIDTH-1:0] d, 
               output [WIDTH-1:0] q);
  reg [WIDTH-1:0] q; 
  always @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input [WIDTH-1:0] d0, d1, 
              input             s, 
              output [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module alu(input [31:0] a, b,
           input [2:0]  alucontrol,
           output [31:0] result,
           output        zero);
  wire [31:0] condinvb, sum;

  assign condinvb = alucontrol[2] ? ~b : b;
  assign sum = a + condinvb + alucontrol[2];
  
  reg [31:0] result; 

    
    always @ *
        case (alucontrol[2:0])
          3'b000: result = a & b;
          3'b001: result = a | b;
          3'b101: result = a ^ b; 
          3'b010: result = sum;
          3'b110: result = sum;
          3'b111: result = sum[31];
          default: result = 32'bx; 
        endcase

  assign zero = (result == 32'b0);
endmodule
