//I am using iVerilog, downloaded from http://bleyer.org/icarus/
//For OSX we are using iVerilog, downloaded from MacPorts

//multiplication circuit
module Mult_full(a, b, c);
   //define inputs 
   input [15:0] a, b;

   //define outputs
   output [15:0] c;

   //develop circuitry for outputs
   //  assign c[0] = (a[0] & b[0]);
   //  assign c[1] = ((a[0] & b[1]) ^ (a[1] & b[0]));
   //  assign c[2] = (((a[0] & b[1]) & (a[1] & b[0])) ^ (a[1] & b[1]));
   //  assign c[3] = (((a[0] & b[1]) & a[1] & b[0]) & (a[1] & b[1]));

    assign c = a * b;

endmodule

//divide circuit
module Divide_full(a, b, c);
   //define inputs
   input [15:0] a, b;
   input [2:0] m;
   //define outputs
   output [15:0] c;

   //because division is hard we use /
   // assign c[0] = ((!b[1] & a[0]) | (a[1] & a[0]) | (!b[0] & a[1]));
   // assign c[1] = (!b[1] & a[1]);
   assign c = a / b;

   
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

module AND16(x,y,z);
    input[15:0] x,y;          
    output[15:0] z;    
 
    assign z = x & y;
endmodule
 
module NAND16(x,y,z);
    input[15:0] x,y;          
    output[15:0] z;    
   
    assign z = ~(x & y);
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
 
module testbench();
 
 	reg [15:0] one;
	reg [15:0] two;
	reg [4:0] three;
	wire [15:0] out1;
	wire [15:0] out2;
	wire [15:0] out3;
	
	Xor testXor(one, two, out1);
	Xnor testXnor(one, two, out2);
	Shift_right testShiftRight(one, three, out3);

    // Inputs
    reg[15:0]       in;
    reg[4:0]        shift;
    reg             clk;
    reg[15:0]           x;
    reg[15:0]           y;
    reg[1:0]            a;
    reg[1:0]            b;
    wire[3:0]           out;
    wire[15:0]          andres;
    wire[15:0]          nandres;
   
    // Output from module
    wire[15:0]      shifted;
   
    SHIFT_LEFT sL (shift, in, shifted);
    AND16 anding(x,y, andres);
    NAND16 nanding(x,y, nandres);
    initial begin
       
        a = 3;
        b = 3;
        #10
        $display("mult: %1b", out);
       
       
       x = 65535;
       y = 0;
       #10
       $display ("x:    %1b", x);
       $display ("y:    %1b", y);
       $display ("AND:  %1b", andres);
       $display ("NAND: %1b", nandres);
       
        in = 11;
        shift = 5;
        #10 // Wait
       
        $display ("Input:   %1b", in);
        $display ("Left Shift: ", shift);
        $display ("Shifted: %1b", shifted);
       
        in = shifted;
        shift = 2;
        #10
        $display ("Left Shift: ", shift);
        $display ("Shifted: %1b", shifted);
        #10
        $finish;

        one = 16'b0000000011111111;
         two = 16'b0000111100001111;
         three = 4'b0111;
         
         #10
         $display("    input 1     |     input 2    |     xor out     |    xnor out   |    shift out   ");
         $display("%15b|%15b|%15b|%15b|%15b", one, two, out1, out2, out3);
         
         #10
         $finish;
    end
   
    //---------------------------------------------
    // Clock Control
    //---------------------------------------------
    initial begin
      forever
        begin
            #5
            clk = 0 ;
            #5
            clk = 1 ;
        end
    end
   

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

//Multiplexer (2 channel)
module Mux2(a1, a0, s, b);
	parameter k = 16;
	input [k-1:0] a1, a0;
	input [1:0] s;
	output[k-1:0] b;
	assign b = ({k{s[1]}} & a1) |
				({k{s[0]}} & a0);
endmodule

//-----------------------------------------------------------------------------
module Xor(a, b, c);
	input [15:0] a;
	input [15:0] b;
	output [15:0] c;
	assign c = a ^ b;
endmodule

//-----------------------------------------------------------------------------
module Xnor(a, b, c);
	input [15:0] a;
	input [15:0] b;
	output [15:0] c;
	assign c = ~(a ^ b);
endmodule

//-----------------------------------------------------------------------------
module Shift_right(in, amt, out);
	input [15:0] in;
	input [4:0] amt;
	output [15:0] out;
	wire [15:0] out;
	assign out = in >> amt;
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
	Mux2 #(n) muxA(a_in, a_out, a_s, muxA_out);
	Mux4 #(n) muxB(16'b0000000000000000, b_in, acc_val, b_out, b_s, muxB_out);
	DFF  #(n) selectedA(clk, muxA_out, a_out);
	DFF  #(n) selectedB(clk, muxB_out, b_out);
endmodule