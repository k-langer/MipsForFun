module testbench();
    reg        clk;
    reg        reset;

    wire [31:0] data;
    wire        memwrite;

    wire pc_branch;
    wire [31:0] pc;
    dff pcbranchreg (clk,reset, 1'b0, pc_branch);
    dff #(32) pcreg (clk,reset, pc+4, pc);
    fetch fe ( clk, reset, 1'b0, pc, 1'b1, 32'b0, 1'b1, data);

    initial
    begin
        reset <= 1; # 20; reset <= 0;
    end

    always
    begin
        clk <= 1; # 10; clk <= 0; # 10;
    end

    always @(posedge clk)
        if (pc > 64)
            $finish;
        else 
            $display("%h\n",data);
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

module fetch
   (input clk, flush, 
    input AnyStall, 
    input [31:0] RedirectPc_ID,
    input Jump_ID, 
    input [31:0] RedirectPc_EX,
    input BranchTaken_EX, 
    output [31:0] FetchData_IF);

    wire [31:0] FetchData_IFM1;
    reg [31:0] Pc_IFM1; 
    wire [31:0] Pc_IF; 

    reg [31:0] RAM[63:0];
    initial
        $readmemh( "m.dat" , RAM );

    assign  FetchData_IFM1 = RAM[Pc_IF[7:2]];

    always @*
        casex ({Jump_ID, BranchTaken_EX, AnyStall})
            3'b1xx: Pc_IFM1 = RedirectPc_ID; 
            3'b0x1: Pc_IFM1 = Pc_IF; 
            3'b010: Pc_IFM1 = RedirectPc_EX;
            3'b000: Pc_IFM1 = Pc_IF + 4; 
        endcase
    dff #(32) dff_FetchData (clk,flush, FetchData_IFM1, FetchData_IF); 
    dff #(32) dff_PC (clk,flush,Pc_IFM1, Pc_IF); 

endmodule
