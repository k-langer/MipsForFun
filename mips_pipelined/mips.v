module mips (
    input clk, 
    input reset
);
    wire AnyStall; 
    wire [31:0] RedirectPc_EX, FetchData_IF, RedirectPc_ID, Result_EX;
    wire [25:0] JumpTgt_ID;
    wire [15:0] Imm_ID;
    wire [3:0] AluControl_ID;
    wire [2:0] BpCtl_ID;
    wire [31:0] RdDatA_ID, RdDatB_ID; 
    wire Stall_EX,RegWrite_EX, MemToReg_EX, MemWrite_EX; 
    wire BranchTaken_EX;
    wire Jump_ID, RegWrite_ID, RegDst_ID,AluSrc_ID,MemWrite_ID; 
    wire MemToReg_ID, Link_ID;

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
        Imm_ID, RdDatA_ID, RdDatB_ID);
    execute ex(clk, reset, AnyStall, AluSrc_ID, BpCtl_ID, AluControl_ID, Imm_ID,
        RegWrite_ID, MemWrite_ID, MemToReg_ID,        
        RdDatA_ID, RdDatB_ID, Result_EX,
        RegWrite_EX, MemToReg_EX, MemWrite_EX, Stall_EX);


    wire [5:0] Cnt, CntNxt;
    assign CntNxt = Cnt+1'b1; 
    dff #(6) endcntr (clk, reset, CntNxt, Cnt); 
    always @ (posedge clk) begin
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
