module system ( 
    input clk, 
    input reset, 
    input  [31:0] PcReq_SY0, 
    output [31:0] InstrFill_SY0);
    
    reg [31:0] RAM[63:0];
    wire [5:0] Addr; 
    initial
        $readmemh( "m.dat" , RAM );

    always @(posedge clk)
        RAM[Addr] <= RAM[Addr]; //Hack for synthesis

    assign InstrFill_SY0 = RAM[PcReq_SY0[7:2]];
endmodule
