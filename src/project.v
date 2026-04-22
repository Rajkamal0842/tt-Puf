`default_nettype none

module tt_um_puf (
    input  wire [7:0] ui_in,    // Challenge bits (not used in simple RO, but required for top)
    output wire [7:0] uo_out,   // Response bit on uo_out[0]
    input  wire [7:0] uio_in,   // uio_in[0] is the Enable signal
    output wire [7:0] uio_out,  // Not used
    output wire [7:0] uio_oe,   // Not used
    input  wire       ena,      // Power enable
    input  wire       clk,      // System clock
    input  wire       rst_n     // Reset
);

    // PUF Enable signal from first bidirectional pin
    wire en = uio_in[0];

    // RING OSCILLATOR 1 (Upper Branch)
    (* keep = "true" *) wire [4:0] ro1;
    assign ro1[0] = ~(en & ro1[4]);
    assign ro1[1] = ~ro1[0];
    assign ro1[2] = ~ro1[1];
    assign ro1[3] = ~ro1[2];
    assign ro1[4] = ~ro1[3];

    // RING OSCILLATOR 2 (Lower Branch)
    (* keep = "true" *) wire [4:0] ro2;
    assign ro2[0] = ~(en & ro2[4]);
    assign ro2[1] = ~ro2[0];
    assign ro2[2] = ~ro2[1];
    assign ro2[3] = ~ro2[2];
    assign ro2[4] = ~ro2[3];

    // XOR comparison creates a unique phase-beat frequency
    wire puf_core = ro1[4] ^ ro2[4];

    // Assign result to the first output pin
    assign uo_out = {7'b0, puf_core};
    
    // Set all other outputs/enables to zero
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
