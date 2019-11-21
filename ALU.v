//I am using iVerilog, downloaded from http://bleyer.org/icarus/
//For OSX we are using iVerilog, downloaded from MacPorts
// iverilog -o alu.vvp ALU.v
// vvp alu.vvp

module ADD_HALF (input x, y, output c_out, sum);
	xor G1(sum, x, y);	// Gate instance names are optional
	and G2(c_out, x, y);
endmodule

module ADD_FULL (input a, b, c_in, output c_out, sum);	 
	wire w1, w2, w3;				// w1 is c_out; w2 is sum
	ADD_HALF M1 (a, b, w1, w2);
	ADD_HALF M0 (w2, c_in, w3, sum);
	or (c_out, w1, w3);
endmodule

module ADD_4 (input [3:0] a, b, input c_in, output c_out, output [3:0] sum);
	wire c_in1, c_in2, c_in3, c_in4;			// Intermediate carries
	ADD_FULL M0 (a[0], b[0], c_in,  c_in1, sum[0]);
	ADD_FULL M1 (a[1], b[1], c_in1, c_in2, sum[1]);
	ADD_FULL M2 (a[2], b[2], c_in2, c_in3, sum[2]);
	ADD_FULL M3 (a[3], b[3], c_in3, c_out, sum[3]);
endmodule

module ADD_8 (input [7:0] a, b, input c_in, output c_out, output [7:0] sum);
	wire c_in4;
	ADD_4 M0 (a[3:0], b[3:0], c_in, c_in4, sum[3:0]);
	ADD_4 M1 (a[7:4], b[7:4], c_in4, c_out, sum[7:4]);
endmodule

module ADD (input [15:0] a, b, input c_in, output c_out, output [15:0] sum);
   wire c_in4;
   ADD_8 M0 (a[7:0], b[7:0], c_in, c_in4, sum[7:0]);
   ADD_8 M1 (a[15:8], b[15:8], c_in4, c_out, sum[15:8]);
endmodule

module MULTIPLY(x, y, mult_out);
	input [15:0] x, y;
	output [15:0] mult_out;

	assign mult_out = x * y;
endmodule

module DIVIDE(x, y, div_out);
	input [15:0] x, y;
	output [15:0] div_out;

	assign div_out = x / y;
endmodule

module AND(x,y,z);
	input[15:0] x,y;          
	output[15:0] z;    
 
	assign z = x & y;
endmodule

module OR(a, b, c);
	parameter n = 16;
	input[n-1:0] a, b;
	output[n-1:0] c;

	assign c = a | b;
endmodule

module XOR(a, b, c);
	input [15:0] a;
	input [15:0] b;
	output [15:0] c;
	assign c = a ^ b;
endmodule

module NOT(b, b_out);
    input[15:0] b;
  output[15:0] b_out;

  assign b_out = ~b;
endmodule

module NAND(x,y,z);
	input[15:0] x,y;          
	output[15:0] z;    
   
	assign z = ~(x & y);
endmodule

module NOR(a, b, c);
	parameter n = 16;
	input[n-1:0] a, b;
	output[n-1:0] c;
	
	assign c = ~(a | b);
endmodule

module XNOR(a, b, c);
	input [15:0] a;
	input [15:0] b;
	output [15:0] c;
	assign c = ~(a ^ b);
endmodule

module SHIFT_LEFT(shift, in, out);
	input[4:0] shift;
	input[15:0] in;
	output[15:0] out;
 
	assign out = in << shift;
endmodule
 
module SHIFT_RIGHT(shift, in, out);
	input[4:0] shift;
	input[15:0] in;
	output[15:0] out;
 
	assign out = in >> shift;
endmodule

module MUX2(a1, a0, s, b);
	parameter k = 16;
	input [k-1:0] a1, a0;
	input [1:0] s;
	output[k-1:0] b;
	assign b = ({k{s[1]}} & a1) |
				({k{s[0]}} & a0);
endmodule

module MUX4(a3, a2, a1, a0, s, mux4_out);
	parameter k = 16;
	input [15:0] a3, a2, a1, a0;  // inputs
	input [3:0]   s; // one-hot select
	output[15:0] mux4_out;
	assign mux4_out = ({k{s[3]}} & a3) | 
				({k{s[2]}} & a2) | 
				({k{s[1]}} & a1) |
				({k{s[0]}} & a0);
endmodule

module DFF16(clk, in, dff_out);
	input clk;
	input[15:0] in;
	output[15:0] dff_out;
	reg[15:0] dff_out;
	
	always @(posedge clk) begin
		begin
			dff_out = in;
		end
	end
endmodule

module DFF32(clk, in, dff_out);
	input clk;
	input[31:0] in;
	output[31:0] dff_out;
	reg[31:0] dff_out;
	
	always @(posedge clk) begin
		begin
			dff_out = in;
		end
	end
endmodule


module Input_registers(clk, a_in, b_in, acc_val, a_s, b_s, a_out, b_out);
	parameter n = 16;
	
	input clk;
	
	//inputs and outputs to the entire section
	input [n-1:0] a_in, b_in, acc_val;	//a&b and current accumulator value
	input [1:0] a_s;		//2 bit one-hot selector
	input [3:0] b_s;		//4 bit one-hot selector
	output [n-1:0] a_out, b_out;
	
	
	//wires
	wire [n-1:0] muxA_out;
	wire [n-1:0] muxB_out;
	wire [n-1:0] a_out, b_out;
	
	//module instantiations for the two muxes and two d flip-flops
	MUX2 #(n) muxA(a_in, a_out, a_s, muxA_out);
	MUX4 #(n) muxB(16'b0000000000000000, b_in, acc_val, b_out, b_s, muxB_out);
	DFF16  #(n) selectedA(clk, muxA_out, a_out);
	DFF16  #(n) selectedB(clk, muxB_out, b_out);
endmodule

module COMBINATIONAL_LOGIC (muxAInput, muxBInput, op, reset, aOut, bOut, m);
    input[1:0] muxAInput;
    input[2:0] muxBInput;
    input[3:0] op;
    input reset;

    output[1:0] aOut;
    output[2:0] bOut;
    output[15:0] m;

    wire[14:0] decodeOut;
    wire[15:0] leftArbOut;

    assign aOut = muxAInput;
    assign bOut = muxBInput;

    DECODER decoding(op, decodeOut);
    LEFT_ARBITER leftArbing(decodeOut, reset, leftArbOut);

    assign m = leftArbOut;
endmodule


module DECODER(input[3:0] in, output [14:0] out);
	assign out = 1 << in;
endmodule

module LEFT_ARBITER (d, r, m);
    input[14:0] d;
    input r;

    output reg[15:0] m;

    always @(d, r)
    begin
        case(r)
        1'b1 : m=1000000000000000;
        1'b0 : m={r, d};
        default : m=16'bX;
        endcase
	end

endmodule

module MUX16(add, sub, mult, div, andd, orr, xorr, nt, nandd, norr, xnorr, shiftL, shiftR, err, select, out);
	parameter n = 32;
	
	input[32:0] add, sub, mult, div, andd, orr, xorr, nt, nandd, norr, xnorr, shiftL, shiftR, err;
	input[n/2-1:0] select;
	output[n-1:0] out;
	
	assign out = ({n{select[0]}} & add) |
                ({n{select[1]}} & sub) |
                ({n{select[2]}} & mult) |
				({n{select[3]}} & div) |
				({n{select[4]}} & andd) |
				({n{select[5]}} & orr) |
				({n{select[6]}} & xorr) |
				({n{select[7]}} & nt) |
				({n{select[8]}} & nandd) |
				({n{select[9]}} & norr) |
				({n{select[10]}} & xnorr) |
				({n{select[11]}} & shiftL) |
				({n{select[12]}} & shiftR) |
				({n{select[13]}} & out) |
				({n{select[14]}} & err) |
                ({n{select[15]}} & 0);
endmodule 

module testbench();
 
	// Combinational Logic Input
	reg             clk;
	reg             reset;
	reg[1:0]		muxAInput;
	reg[2:0]		muxBInput;
	reg[3:0]		op;
	reg[15:0]       a;
	reg[15:0]       b;
	
	// Combinational Logic Output
	wire[1:0]		muxASelector;
	wire[2:0]		muxBSelector;
	wire[15:0] 		opcode;
   
   
   // Operation Module Ouput
	wire[15:0] 		add;
	wire[15:0] 		sub;
	wire[15:0] 		div;
	wire[15:0] 		andd;
	wire[15:0] 		orr;
	wire[15:0] 		xorr;
	wire[15:0] 		nt;
	wire[15:0] 		nandd;
	wire[15:0] 		norr;
	wire[15:0] 		xnorr;
	wire[15:0] 		shiftL;
	wire[15:0] 		shiftR;
	wire[15:0] 		err;
	wire[31:0] 		mult;
   
	COMBINATIONAL_LOGIC CL(muxAInput, muxBInput, op, reset, muxASelector, muxBSelector, opcode);
	ADD()
	MUX16(add, sub, mult, div, andd, orr, xorr, nt, nandd, norr, xnorr, shiftL, shiftR, err, select, out);
	
	//wires for input -> mux -> dff
    wire [15:0] muxA_out;
    wire [15:0] muxB_out;
    wire [15:0] a_out, b_out;

    //module instantiations for the two muxes and two d flip-flops
    MUX2 #(n) muxA(a, a_out, muxASelector, muxA_out);
    MUX4 #(n) muxB(16'b0000000000000000, b, acc_val, b_out, muxBSelector, muxB_out);
    DFF16  #(n) selectedA(clk, muxA_out, a_out);
    DFF16  #(n) selectedB(clk, muxB_out, b_out);

  //a_out is output from DFF that should be used for modules

	initial begin 
		#1
		
		reset = 0;
		a = 6;
		b = 3;
		muxAInput = 1;
		muxBInput = 2;
		
		op = 0;
		
		#10
		$display("opcode: %1b", opcode);
		
		$finish;
	end
   
	//---------------------------------------------
	// Clock Control
	//---------------------------------------------
	initial begin
		forever
		begin
			#10
			clk = 0 ;
			#10
			clk = 1 ;
		end
	end

endmodule
