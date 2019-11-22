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

module ADD (input [15:0] a, b, input c_in, output [31:0] sum);
   wire c_in4;
   ADD_8 M0 (a[7:0], b[7:0], c_in, c_in4, sum[7:0]);
   ADD_8 M1 (a[15:8], b[15:8], c_in4, c_out, sum[15:8]);
   assign sum[16] = c_out;
   assign sum[31:17] = 0;
endmodule

module SUB (input [15:0] a, b, output reg [31:0] out);
	always @(a, b) begin
		if (b > a)
			out = 32'bX;
		else
			out = a - b;
	end
endmodule

module MULTIPLY(x, y, mult_out);
	input [15:0] x, y;
	output [31:0] mult_out;

	assign mult_out = x * y;
endmodule

module DIVIDE(x, y, div_out);
	input [15:0] x, y;
	output [31:0] div_out;

	assign div_out = x / y;
endmodule

module AND(x,y,z);
	input[15:0] x,y;          
	output[31:0] z;    
 
	assign z = x & y;
endmodule

module OR(a, b, c);
	input[15:0] a, b;
	output[31:0] c;

	assign c = a | b;
endmodule

module XOR(a, b, c);
	input [15:0] a;
	input [15:0] b;
	output [31:0] c;
	assign c = a ^ b;
endmodule

module NOT(b, b_out);
    input[15:0] b;
	output[31:0] b_out;

	assign b_out = ~b;
endmodule

module NAND(x,y,z);
	input[15:0] x,y;          
	output[31:0] z;    
   
	assign z = ~(x & y);
endmodule

module NOR(a, b, c);
	input[15:0] a, b;
	output[31:0] c;
	
	assign c = ~(a | b);
endmodule

module XNOR(a, b, c);
	input [15:0] a;
	input [15:0] b;
	output [31:0] c;
	assign c = ~(a ^ b);
endmodule

module SHIFT_LEFT(shift, in, out);
	input[15:0] shift;
	input[15:0] in;
	output[31:0] out;
 
	assign out = in << shift;
endmodule
 
module SHIFT_RIGHT(shift, in, out);
	input[15:0] shift;
	input[15:0] in;
	output[31:0] out;
 
	assign out = in >> shift;
endmodule

module MUX2(a1, a0, s, b);
	parameter k = 16;
	input [15:0] a1, a0;
	input [1:0] s;
	output[15:0] b;
	
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
	
	always @(negedge clk) begin
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

module COMBINATIONAL_LOGIC (muxAInput, muxBInput, op, reset, aOut, bOut, m);
    input[1:0] muxAInput;
    input[3:0] muxBInput;
    input[3:0] op;
    input reset;

    output[1:0] aOut;
    output[3:0] bOut;
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

module MUX16(add, sub, mult, div, andd, orr, xorr, nt, nandd, norr, xnorr, shiftL, shiftR, select, out);
	parameter n = 32;
	
	input[31:0] 	mult, nt, nandd, add, sub, div, andd, orr, xorr, norr, xnorr, shiftL, shiftR;
	input[15:0] 	select;
	output[31:0] 	out;
	
	assign out = (({n{select[0]}} & add))|
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
                ({n{select[14]}} & 0);
endmodule

module CURRENT_OP(op, operation);
	input[3:0]		op;
	output reg [8*12:1] 	operation;
	
	always @(op)
    begin
        case(op)
        0: operation = "Add";
        1: operation = "Subtract";
        2: operation = "Multiply";
        3: operation = "Divide";
        4: operation = "AND";
        5: operation = "OR";
        6: operation = "XOR";
        7: operation = "NOT";
        8: operation = "NAND";
        9: operation = "NOR";
        10: operation = "XNOR";
        11: operation = "Shift_L";
        12: operation = "Shift_R";
        13: operation = "No Op";
        14: operation = "Error";
        15: operation = "Reset";
        default : operation = "WHAT";
        endcase
	end
endmodule

module ALU(clk, reset, A, B, muxAInput, muxBInput, op, acc_val);
	input             clk;
	input             reset;
	input[1:0]		muxAInput;
	input[3:0]		muxBInput;
	input[3:0]		op;
	input[15:0]       A;
	input[15:0]       B;
	wire [8*12:1] 	operation;
	reg [8*6:1] 	currentState = ""; // "Ready" or "Error"
	reg [8*6:1] 	nextState = "";    //    ^    or    ^
	
	// Combinational Logic Output
	wire[1:0]		muxASelector;
	wire[3:0]		muxBSelector;
	wire[15:0] 		opcode;
   
   
   // Operation Module Ouput
	wire[31:0] 		add_out;
	wire[31:0] 		sub_out;
	wire[31:0] 		div_out;
	wire[31:0] 		and_out;
	wire[31:0] 		or_out;
	wire[31:0] 		xor_out;
	wire[31:0] 		nt_out;
	wire[31:0] 		nand_out;
	wire[31:0] 		nor_out;
	wire[31:0] 		xnor_out;
	wire[31:0] 		shiftL_out;
	wire[31:0] 		shiftR_out;
	wire[31:0] 		mult_out;
	output wire[31:0] 		acc_val;
   
	COMBINATIONAL_LOGIC CL(muxAInput, muxBInput, op, reset, muxASelector, muxBSelector, opcode);
	CURRENT_OP currentOP(op, operation);
	//wires for input -> mux -> dff
    wire [15:0] muxA_out;
    wire [15:0] muxB_out;
    wire [15:0] a_out, b_out;
	wire [31:0] finalMux_out;

    //module instantiations for the two muxes and two d flip-flops
    MUX2 muxA(A, a_out, muxASelector, muxA_out);
    MUX4 muxB(16'b0, B, acc_val[15:0], b_out, muxBSelector, muxB_out);
    DFF16  selectedA(clk, muxA_out, a_out);
    DFF16  selectedB(clk, muxB_out, b_out);

	ADD adder(a_out, b_out, 1'b0, add_out);
	SUB subber(a_out, b_out, sub_out);
	DIVIDE divider(a_out, b_out, div_out);
	AND ander(a_out, b_out, and_out);
	OR orer(a_out, b_out, or_out);
	XOR xorer(a_out, b_out, xor_out);
	NOT noter(b_out, nt_out);
	NAND nander(a_out, b_out, nand_out);
	NOR norer(a_out, b_out, nor_out);
	XNOR xnorer(a_out, b_out, xnor_out);
    SHIFT_LEFT leftShifter(a_out, b_out, shiftL_out);
    SHIFT_RIGHT rightShifter(a_out, b_out, shiftR_out);
    MULTIPLY multiplier(a_out, b_out, mult_out);
	
	MUX16 outputResult(add_out, sub_out, mult_out, div_out, and_out, or_out, xor_out, nt_out, nand_out, nor_out, xnor_out, shiftL_out, shiftR_out, opcode, finalMux_out);
	DFF32 acc(clk, finalMux_out, acc_val);
endmodule

module testbench();
 
	reg             clk;
	reg             reset;
	reg[15:0]		A;
	reg[15:0]		B;
	reg[1:0]		muxAInput;
	reg[3:0]		muxBInput;
	reg[3:0]		op;
	wire[31:0]		out;
	reg[8*2:1] 	print = "";
	 
	//---------------------------------------------
	// Breadboard
	//---------------------------------------------  
	ALU breadboard(clk, reset, A, B, muxAInput, muxBInput, op, out);

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

	//---------------------------------------------
	// Next State
	//---------------------------------------------
	always @(out)
	begin
		if (^out == 1'b0 || ^out == 1'b1)
			breadboard.nextState = "Ready";
		else begin
			breadboard.nextState = "Error";
		end
	end

	always @(posedge clk)
	begin
		if (breadboard.nextState == "")
			breadboard.currentState = "Ready";
		else
			breadboard.currentState = breadboard.nextState;
	end

	initial begin 
		clk = 1;
		#1
		$display("NUM1\t\t\t||NUM2\t\t\t||Operation\t\t||Current State ||Output\t\t\t\t\t||Next State");
		// Start here
		
		reset = 0;
		A = 5;
		B = 6;
		muxAInput = 2'b10;
		muxBInput = 4'b0100;

		//start with adding two numbers
		op = 0;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);
		//add another number to accumulator
		A = 42;
		muxBInput = 4'b0010;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//subtract accumulator from number
		A = 823;
		op = 1;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//subtract to cause underflow
		A = 12;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//try to add to a error state (proves error state cannot be overriden this way
		op = 0;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//reset
		op = 15;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//multiply something to accumulator (should still be 0)
		op = 2;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//multiply two fairly large numbers
		A = 2048;
		B = 16;
		muxBInput = 4'b0100;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//divide the numbers
		op = 3;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//divide by 0
		B = 0;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//reset
		op = 15;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//and two fairly large numbers
		A = 16'b100101101111010;
		B = 16'b000110101101010;
		op = 4;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//or something with accumulator
		op = 5;
		muxBInput = 4'b0010;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//xor something with accumulator 
		op = 6;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//not accumulator
		op = 7;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//nand accumulator
		op = 8;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//nor something with accumulator 
		op = 9;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//xnor something with accumulator
		op = 10;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//shift accumulator right to small number
		A = 22;
		op = 11;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);
		
		//shift accumulator left to large number
		A = 17;
		op = 12;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//do no op a couple of times
		op = 13;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//force an error state
		op = 14;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);

		//reset to ready
		op = 15;
		#10
		$display("%16b (%1d)\t||%b (%1d)\t||%1d (%1s)\t\t||%s\t||%b (%1d)\t||%s%s", breadboard.a_out, breadboard.a_out, breadboard.b_out, breadboard.b_out, op, breadboard.operation, breadboard.currentState, out, out, breadboard.nextState, print);


		// End here

		$finish;
	end

endmodule