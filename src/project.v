`default_nettype none

module tt_um_puf (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Use uio_in[0] as the Enable signal for the PUF
    wire en = uio_in[0];

    // Ring Oscillator 1
    (* keep = "true" *) wire [4:0] ro1;
    assign ro1[0] = ~(en & ro1[4]);
    assign ro1[1] = ~ro1[0];
    assign ro1[2] = ~ro1[1];
    assign ro1[3] = ~ro1[2];
    assign ro1[4] = ~ro1[3];

    // Ring Oscillator 2
    (* keep = "true" *) wire [4:0] ro2;
    assign ro2[0] = ~(en & ro2[4]);
    assign ro2[1] = ~ro2[0];
    assign ro2[2] = ~ro2[1];
    assign ro2[3] = ~ro2[2];
    assign ro2[4] = ~ro2[3];

    // XOR the outputs to create the PUF response
    wire puf_core = ro1[4] ^ ro2[4];

    // Output mapping
    assign uo_out = {7'b0, puf_core}; // Result on uo_out[0]
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
