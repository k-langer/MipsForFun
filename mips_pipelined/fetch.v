module fetch
   (input clk, flush, 
    input AnyStall, 
    input [25:0] JumpTgt_IDM1,
    input Jump_IDM1, 
    input [31:0] RedirectPc_EXM1,
    input BranchTaken_EXM1, 
    output [31:0] FetchData_IF);

    wire [31:0] FetchData_IFM1;
    reg [31:0] Pc_IFM1; 
    wire [31:0] Pc_IF; 
    wire [31:0] nPc_IFM1;
    wire [31:0] DeRedirectPc; 
    wire [31:0] RedirectPc;
    reg [31:0] RAM[63:0];
    initial
        $readmemh( "m.dat" , RAM );

    wire [5:0] Addr; 
    always @(posedge clk)
        RAM[Addr] <= RAM[Addr]; //Hack for synthesis

    assign  FetchData_IFM1 = RAM[Pc_IFM1[7:2]];
    
    assign  nPc_IFM1 = Pc_IF + 4; 
    assign  RedirectPc = Pc_IF+{RedirectPc_EXM1[29:0], 2'b0 };
    assign  DeRedirectPc = {nPc_IFM1[31:28], JumpTgt_IDM1[25:0], 2'b00};
    always @*
        casez ({Jump_IDM1, BranchTaken_EXM1, AnyStall})
            3'b??1: Pc_IFM1 = Pc_IF; 
            3'b?10: Pc_IFM1 = RedirectPc;
            3'b100: Pc_IFM1 = DeRedirectPc; 
            3'b000: Pc_IFM1 = nPc_IFM1; 
        endcase
    dff #(32) dff_FetchData (clk,flush, FetchData_IFM1, FetchData_IF); 
    dff #(32) dff_PC (clk,flush,Pc_IFM1, Pc_IF); 

endmodule
