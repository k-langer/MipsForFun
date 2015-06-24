module mips_tb();
    reg        clk;
    reg        reset;
    initial
     begin
        $dumpfile("test.vcd");
        $dumpvars(0,mips_tb);
     end 

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
