module testbench();
    reg        clk;
    reg        reset;

    mips core(clk, reset);

    initial
    begin
        reset <= 1; # 22; reset <= 0;
    end

    // generate clock to sequence tests
    always
    begin
        clk <= 1; # 5; clk <= 0; # 5;
    end

endmodule

module mips (
    input clk, 
    input reset
);
    wire AnyStall; 
    wire [31:0] RedirectPc_EX, FetchData_IF, RedirectPc_ID;
    wire [25:0] JumpTgt_ID;
    wire [15:0] Imm_ID;
    wire [3:0] AluControl_ID;
    wire [2:0] BpCtl_ID;
    wire BranchTaken_EX; 
    assign RedirectPc_EX = 32'b0; 
    assign BranchTaken_EX = 1'b0; 
    assign AnyStall = 1'b0; 
    fetch fe(clk, reset, 
        AnyStall, JumpTgt_ID, Jump_ID, RedirectPc_EX, BranchTaken_EX, 
        FetchData_IF);

    decode de( clk, reset, AnyStall, FetchData_IF, Jump_ID, JumpTgt_ID,
        RegWrite_ID, RegDst_ID, AluSrc_ID, MemWrite_ID, MemToReg_ID, Link_ID,
        BpCtl_ID,
        AluControl_ID,
        Imm_ID);

    initial
     begin
        $dumpfile("test.vcd");
        $dumpvars(0,mips);
     end

    wire [5:0] Cnt, CntNxt;
    assign CntNxt = Cnt+1'b1; 
    dff #(6) endcntr (clk, reset, CntNxt, Cnt); 
    always @ (posedge clk) begin
        $display("%h",FetchData_IF); 
        if (Cnt > 16) 
            $finish;
    end

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
