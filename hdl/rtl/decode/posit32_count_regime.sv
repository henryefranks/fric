import posit_types::*;

module count_regime_16 (
    input  logic [15:0] in,

    output logic [3:0] c,
    output logic valid
);

    logic [1:0] counts [3:0];
    logic [3:0] valids;
    logic [1:0] select;

    generate
        for (genvar j = 0; j < 4; j += 1) begin
            priority_encoder_4 i_priority_encoder_4 (
                .leading_bit( in[15] ),
                .slice( in[ (4*j) +: 4 ] ),
                .count( counts[j] ),
                .valid( valids[j] )
            );
        end

        priority_encoder_4 i_priority_encoder_4_valid (
            .leading_bit( 1'b0 ),
            .slice( valids ),
            .count( select ),
            .valid( valid )
        );

        mux #( .WIDTH(2), .NUM_INPUTS(4) ) i_mux(
            .sel( select ),
            .i( counts ),
            .o( c[1:0] )
        );
    endgenerate   

    assign c[3:2] = select;

endmodule

module posit32_count_regime (
    input  posit32_t i,

    output logic [4:0] c,
    output logic valid
);

    /* COUNT THE NUMBER OF LEADING ZEROS/ONES TO FIND THE REGIME LENGTH */

    /* see posit_variable_count_regime.sv for a detailed explanation. */

    logic leading_bit;
    logic [31:0] intr_v; // intermediate 32b vector

    logic [1:0] valids;
    logic [3:0] counts [1:0];
    logic select;

    // basically sign extend by 1 bit
    assign intr_v[31] = i.ref_block[30];
    assign intr_v[30:0] = i.ref_block;

    /* we can't use recursive statement because verilator is a pain, so instead
       we construct a balanced mux tree from sets of pre-defined priority
       encoders */
    /* our tree looks like this:

        --4--[PE]--3--[       ]
        --4--[PE]--3--[ 4-way ]--4--+
        --4--[PE]--3--[  mux  ]     |
        --4--[PE]--3--[       ]     +--[ bit shift + ]
                                       [    2-way    ]---5---
        --4--[PE]--3--[       ]     +--[     mux     ]
        --4--[PE]--3--[ 4-way ]     |
        --4--[PE]--3--[  mux  ]--4--+
        --4--[PE]--3--[       ]

       where the muxes are selected through priority encoding of valid bits.

       Each of the 16-bit halves are instances of count_regime_16,
       which handles any nested PE generation as well as offsetting the output
       of each PE to account for its position within the 16b slice.
     */
    generate
        for (genvar j = 0; j < 2; j++) begin

            count_regime_16 i_count_regime_16(
                .in( intr_v[ (16*j) +: 16 ] ),
                .c( counts[j] ),
                .valid( valids[j] )
            );

        end

        /* FIXME: mux ordering and offset bits are broken! */

        priority_encoder_2 i_priority_encoder_2 (
            .slice( {<<2{valids}} ), // FIXME: is this the correct way round?
            .count( select ),
            .valid( valid )
        );

        mux #( .WIDTH(4), .NUM_INPUTS(2) ) i_mux_2(
            .sel( select ),
            .i( counts ),
            .o( c[3:0] )
        );

    endgenerate

    assign c[4] = select;

endmodule

module posit32_regime_tb (
    input  logic [31:0] i,

    output logic [4:0] c,
    output logic valid
);

    posit32_t tmp;

    assign tmp = i;

    posit32_count_regime i_posit32_count_regime(
        .i(tmp), .c(c), .valid(valid)
    );

endmodule