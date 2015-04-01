module mips (); 
    wire [31:0] pc,pcnext;
    reg        clk;
    reg        reset;
    dff #(32)  pcreg(clk,reset,pc,pcnext);
    wire [31:0] fetch_data; 
    imem #(1) imem(pc[7:2],fetch_data); 

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
module dff #(parameter WIDTH = 8)
              (input             clk, reset,
               input [WIDTH-1:0] d, 
               output [WIDTH-1:0] q);
  reg [WIDTH-1:0] q; 
  always @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule
    


