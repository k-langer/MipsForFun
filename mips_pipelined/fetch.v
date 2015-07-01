module fetch
   (input clk, flush, 
    input AnyStall, 
    input [25:0] JumpTgt_ID,
    input Jump_ID, 
    input [31:0] RedirectPc_EX,
    input BranchTaken_EX, 
    output [31:0] FetchData_IF);

    wire [31:0] FetchData_IFM1;
    reg [31:0] Pc_IFM1; 
    wire [31:0] Pc_IF; 
    wire [31:0] nPc_IF;
    wire [31:0] DeRedirectPc; 

    reg [31:0] RAM[63:0];
    initial
        $readmemh( "m.dat" , RAM );

    assign  FetchData_IFM1 = RAM[Pc_IFM1[7:2]];
    assign  nPc_IF = Pc_IF + 4; 
    assign  DeRedirectPc = {nPc_IF[31:28], JumpTgt_ID[25:0], 2'b00};
    always @*
        casez ({Jump_ID, BranchTaken_EX, AnyStall})
            3'b??1: Pc_IFM1 = Pc_IF; 
            3'b?10: Pc_IFM1 = RedirectPc_EX;
            3'b100: Pc_IFM1 = DeRedirectPc; 
            3'b000: Pc_IFM1 = nPc_IF; 
        endcase
    dff #(32) dff_FetchData (clk,flush, FetchData_IFM1, FetchData_IF); 
    dff #(32) dff_PC (clk,flush,Pc_IFM1, Pc_IF); 

endmodule
