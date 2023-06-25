import common::*;

module posit_adder #(
	parameter WIDTH=7,
    parameter EN=1)(
	input logic clk,
	input logic rst,
	input logic [WIDTH-1:0] a, b,
	output logic [WIDTH-1:0] q
    );

logic a_sign, b_sign;
logic signed [7:0] a_regime, a_exponent;
logic unsigned [7:0] a_mantissa;
logic signed [7:0] b_regime, b_exponent; 
logic unsigned [7:0] b_mantissa; 


format_decoder  #(WIDTH,EN) a_decode (.posit(a),
						.sign(a_sign),
						.regime(a_regime),
						.exponent(a_exponent),
						.mantissa(a_mantissa));

format_decoder  #(WIDTH,EN) b_decode (.posit(b),
						.sign(b_sign),
						.regime(b_regime),
						.exponent(b_exponent),
						.mantissa(b_mantissa));

// first pipeline register

logic dc_a_sign, dc_b_sign;
logic signed [7:0] dc_a_regime, dc_a_exponent;
logic unsigned [7:0] dc_a_mantissa;
logic signed [7:0] dc_b_regime, dc_b_exponent; 
logic unsigned [7:0] dc_b_mantissa; 

always_ff @(posedge clk) begin
	if (~rst) begin
		dc_a_sign <= 'b0;
		dc_a_regime <= 'b0;
		dc_a_exponent <= 'b0;
		dc_a_mantissa <= 'b0;
		dc_b_sign <= 'b0;
		dc_b_regime <= 'b0;
		dc_b_exponent <= 'b0;
		dc_b_mantissa <= 'b0;
	end else begin	
		dc_a_sign <= a_sign;
		dc_a_regime <= a_regime;
		dc_a_exponent <= a_exponent;
		dc_a_mantissa <= a_mantissa;
		dc_b_sign <= b_sign;
		dc_b_regime <= b_regime;
		dc_b_exponent <= b_exponent;
		dc_b_mantissa <= b_mantissa;
	end
end

assign q = a + b;

endmodule : posit_adder

