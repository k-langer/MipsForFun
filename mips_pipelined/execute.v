module execute
   (input clk, flush, 
    input AnyStall, 
    input AluSrc_ME, 
    input [2:0] BpCtl_ME,
    input [3:0] AluControl_ME,
    input [15:0] Imm_ME,
    output [31:0] Result_EX, 
    output Stall_EX);

    wire [31:0] a,b; //HACK
    wire [5:0] shamt; //HACK
    reg  [31:0] result;
    wire [31:0] condinvb, sum;
    wire zero; 

    assign condinvb = AluControl_ME[2] ? ~b : b;
    assign sum = a + condinvb + AluControl_ME[2];
    assign Stall_EX = 1'b0; 

    always @ *
        case (AluControl_ME[3:0])
          //4'b1000: mul
          //4'b1001: div
          //4'b1010: result = muldiv[63:32];
          //4'b1011: result = muldiv[31:0];
          4'b1001: result = {b[15:0],16'b0};
          4'b0000: result = a & b;
          4'b0001: result = a | b;
          4'b0101: result = a ^ b;
          4'b0011: result = a << b;
          4'b0100: result = a >> b;
          4'b1100: result = a << shamt;
          4'b1101: result = a >> shamt;
          4'b1110: result = a >>> shamt;
          4'b0010: result = sum;
          4'b0110: result = sum;
          4'b0111: result = sum[31];
          default: result = 32'bx;
        endcase
    assign zero = (result == 32'b0);
    assign Result_EX = result; 
endmodule
