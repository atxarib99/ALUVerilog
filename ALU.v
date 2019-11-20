//I am using iVerilog, downloaded from http://bleyer.org/icarus/
//For OSX we are using iVerilog, downloaded from MacPorts

//multiplication circuit
module Mult_full(a, b, c);
   //define inputs 
   input [1:0] a, b;

   //define outputs
   output [3:0] c;

   //develop circuitry for outputs
    assign c[0] = (a[0] & b[0]);
    assign c[1] = ((a[0] & b[1]) ^ (a[1] & b[0]));
    assign c[2] = (((a[0] & b[1]) & (a[1] & b[0])) ^ (a[1] & b[1]));
    assign c[3] = (((a[0] & b[1]) & a[1] & b[0]) & (a[1] & b[1]));

endmodule

//divide circuit
module Divide_full(a, b, c);
   //define inputs
   input [1:0] a, b;
   //define outputs
   output [1:0] c;

   //because division is hard we use /
   assign c[0] = ((!b[1] & a[0]) | (a[1] & a[0]) | (!b[0] & a[1]));
   assign c[1] = (!b[1] & a[1]);
   
endmodule


//OR
module my_OR(input a, b, output c);
   //apply OR function and store in output 
   or (c, a, b);
endmodule

//NOR
module my_NOR(input a, b, output c);
   //apply NOR function and store in output 
   nor (c, a, b);
endmodule

//Multiplexer (4 channel)
module Mux4(a3, a2, a1, a0, s, b);
	parameter k = 16 ;
	input [k-1:0] a3, a2, a1, a0;  // inputs
	input [3:0]   s; // one-hot select
	output[k-1:0] b;
	assign b = ({k{s[3]}} & a3) | 
                ({k{s[2]}} & a2) | 
                ({k{s[1]}} & a1) |
                ({k{s[0]}} & a0) ;
endmodule

//Multiplexer (2 channel)
module Mux2(a1, a0, s, b);
	parameter k = 16;
	input [k-1:0] a1, a0;
	input [1:0] s;
	output[k-1:0] b;
	assign b = ({k{s[1]}} & a1) |
				({k{s[0]}} & a0);
endmodule

//D-Flip-Flop
module DFF(clk, in, out);
	parameter n = 1;
	input clk;
	input [n-1:0] in;
	output [n-1:0] out;
	reg [n-1:0] out;
	
	always @(clk, in, out) begin
	if(clk == 1)
	begin
		out = in;
	end
	end
	
endmodule

//ADDERS
module Add_half (input a, b, output c_out, sum);
   xor G1(sum, a, b);	// Gate instance names are optional
   and G2(c_out, a, b);
endmodule
//-----------------------------------------------------------------------------
module Add_full (input a, b, c_in, output c_out, sum);	 
   wire w1, w2, w3;				// w1 is c_out; w2 is sum
   Add_half M1 (a, b, w1, w2);
   Add_half M0 (w2, c_in, w3, sum);
   or (c_out, w1, w3);
endmodule
//-----------------------------------------------------------------------------
module Add_rca_4 (input [3:0] a, b, input c_in, output c_out, output [3:0] sum);
   wire c_in1, c_in2, c_in3, c_in4;			// Intermediate carries
   Add_full M0 (a[0], b[0], c_in,  c_in1, sum[0]);
   Add_full M1 (a[1], b[1], c_in1, c_in2, sum[1]);
   Add_full M2 (a[2], b[2], c_in2, c_in3, sum[2]);
   Add_full M3 (a[3], b[3], c_in3, c_out, sum[3]);
endmodule
//-----------------------------------------------------------------------------
module Add_rca_8 (input [7:0] a, b, input c_in, output c_out, output [7:0] sum);
   wire c_in4;
   Add_rca_4 M0 (a[3:0], b[3:0], c_in, c_in4, sum[3:0]);
   Add_rca_4 M1 (a[7:4], b[7:4], c_in4, c_out, sum[7:4]);
endmodule

//-----------------------------------------------------------------------------
module Xor(a, b, c);
	input [15:0] a;
	input [15:0] b;
	output [15:0] c;
	assign c[0] = a[0] ^ b[0];
	assign c[1] = a[1] ^ b[1];
	assign c[2] = a[0] ^ b[0];
	assign c[3] = a[0] ^ b[0];
	assign c[4] = a[0] ^ b[0];
	assign c[5] = a[0] ^ b[0];
	assign c[6] = a[0] ^ b[0];
	assign c[7] = a[0] ^ b[0];
	assign c[8] = a[0] ^ b[0];
	assign c[9] = a[0] ^ b[0];
	assign c[10] = a[0] ^ b[0];
	assign c[11] = a[0] ^ b[0];
	assign c[12] = a[0] ^ b[0];
	assign c[13] = a[0] ^ b[0];
	assign c[14] = a[0] ^ b[0];
	assign c[15] = a[0] ^ b[0];
endmodule

//-----------------------------------------------------------------------------
module Xnor(a, b, c);
	input [15:0] a;
	input [15:0] b;
	output [15:0] c;
	assign c[0] = !(a[0] ^ b[0]);
	assign c[1] = !(a[1] ^ b[1]);
	assign c[2] = !(a[0] ^ b[0]);
	assign c[3] = !(a[0] ^ b[0]);
	assign c[4] = !(a[0] ^ b[0]);
	assign c[5] = !(a[0] ^ b[0]);
	assign c[6] = !(a[0] ^ b[0]);
	assign c[7] = !(a[0] ^ b[0]);
	assign c[8] = !(a[0] ^ b[0]);
	assign c[9] = !(a[0] ^ b[0]);
	assign c[10] = !(a[0] ^ b[0]);
	assign c[11] = !(a[0] ^ b[0]);
	assign c[12] = !(a[0] ^ b[0]);
	assign c[13] = !(a[0] ^ b[0]);
	assign c[14] = !(a[0] ^ b[0]);
	assign c[15] = !(a[0] ^ b[0]);
endmodule

//-----------------------------------------------------------------------------
module Shift_right(in, amt, out);
	input [15:0] in;
	input [3:0] amt;
	output [15:0] out;
	assign out = in >> amt;
endmodule

module Input_registers(clk, a_in, b_in, acc_val, a_s, b_s, a_out, b_out);
	parameter n = 16;
	
	input clk;
	
	//inputs and outputs to the entire section
	input [n-1:0] a_in, b_in, acc_val;	//a&b and current accumulator value
	input [1:0] a_s;		//2 bit one-hot selector
	input [3:0] b_s;		//4 bit one-hot selector
	output a_out, b_out;
	reg a_out, b_out;
	
	//wires
	wire [n-1:0] muxA_out;
	wire [n-1:0] muxB_out;
	
	//module instantiations for the two muxes and two d flip-flops
	Mux2 #(n) muxA(a_in, a_out, a_s, muxA_out);
	Mux4 #(n) muxB(16'b0000000000000000, b_in, acc_val, b_out, b_s, muxB_out);
	DFF  #(n) selectedA(clk, muxA_out, a_out);
	DFF  #(n) selectedB(clk, muxB_out, b_out);
		
endmodule

//-----------------------------------------------------------------------------
module testbench();

	//reg [15:0] one;
	//reg [15:0] two;
	//reg [3:0] three;
	//wire [15:0] out1;
	//wire [15:0] out2;
	//wire [15:0] out3;
	
	//Xor testXor(one, two, out1);
	//Xnor testXnor(one, two, out2);
	//Shift_right testShiftRight(one, three, out3);
	
	initial begin
		
		$display("test\n");
		//one = 16'b0000000011111111;
		//two = 16'b0000111100001111;
		//three = 3'b010;
		
		//#10
		//$display("   input 1     |    input 2    |    xor out    |    xnor out   |   shift out   ");
		//$display("%15b|%15b|%15b|%15b|%15b", one, two, out1, out2, out3);
		
		#10
		$finish;
		
	end
endmodule