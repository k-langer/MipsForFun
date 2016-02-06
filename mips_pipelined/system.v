module system ( 
    input clk, 
    input reset,
    input [31:0] IntrAddr_FL0, 
    input [31:0] IntrFill_FL0, 
    input  [31:0] PcReq_SY0, 
    output [31:0] InstrFill_SY0);
    
    reg [31:0] RAM[63:0];
    //initial
    //    $readmemh( "m.dat" , RAM );

    always @(posedge clk)
        RAM[IntrAddr_FL0[5:0]] <= IntrFill_FL0[31:0]; 

    assign InstrFill_SY0 = RAM[PcReq_SY0[7:2]];
endmodule
