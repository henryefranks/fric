`include "common.svh"

import common::*;

module comparator #(
    parameter int W_REG,
    parameter int W_EXP,
    parameter int W_MAN
) (
    input sign_t a_sign,
    input logic signed   [W_REG-1:0] a_regime,
    input logic signed   [W_EXP-1:0] a_exponent,
    input logic unsigned [W_MAN-1:0] a_mantissa,

    input sign_t b_sign,
    input logic signed   [W_REG-1:0] b_regime,
    input logic signed   [W_EXP-1:0] b_exponent,
    input logic unsigned [W_MAN-1:0] b_mantissa,


    output logic big_sign,
    output logic signed   [W_REG-1:0] big_regime,
    output logic signed   [W_EXP-1:0] big_exponent,
    output logic unsigned [W_MAN-1:0] big_mantissa,

    output logic small_sign,
    output logic signed   [W_REG-1:0] small_regime,
    output logic signed   [W_EXP-1:0] small_exponent,
    output logic unsigned [W_MAN-1:0] small_mantissa
);

    wire a_larger =
        (a_regime > b_regime) |
        ((a_regime == b_regime) & (a_exponent > b_exponent)) |
        ((a_regime == b_regime) & (a_exponent == b_exponent) & (a_mantissa > b_mantissa));

    // Output Muxing
    assign big_sign       = (a_larger) ? a_sign     : b_sign;
    assign big_regime     = (a_larger) ? a_regime   : b_regime;
    assign big_exponent   = (a_larger) ? a_exponent : b_exponent;
    assign big_mantissa   = (a_larger) ? a_mantissa : b_mantissa;

    assign small_sign     = (a_larger) ? b_sign     : a_sign;
    assign small_regime   = (a_larger) ? b_regime   : a_regime;
    assign small_exponent = (a_larger) ? b_exponent : a_exponent;
    assign small_mantissa = (a_larger) ? b_mantissa : a_mantissa;

endmodule : comparator
