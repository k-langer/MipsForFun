module mips_tb();
    reg        clk;
    reg        reset;
    initial
     begin
        $dumpfile("test.vcd");
        $dumpvars(0,mips_tb);
     end 

    wire [31:0] result;
    mips core(clk, reset,result);

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
