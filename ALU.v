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

//Multiplexer
module Mux4(a3, a2, a1, a0, s, b);
	parameter k = 1 ;
	input [k-1:0] a3, a2, a1, a0;  // inputs
	input [3:0]   s; // one-hot select
	output[k-1:0] b;
	assign b = ({k{s[3]}} & a3) | 
                ({k{s[2]}} & a2) | 
                ({k{s[1]}} & a1) |
                ({k{s[0]}} & a0) ;
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