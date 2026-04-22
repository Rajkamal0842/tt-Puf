`default_nettype none

module tt_um_puf (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire en = uio_in[0];

    (* keep = "true" *) wire [4:0] ro1;
    assign ro1[0] = ~(en & ro1[4]);
    assign ro1[1] = ~ro1[0];
    assign ro1[2] = ~ro1[1];
    assign ro1[3] = ~ro1[2];
    assign ro1[4] = ~ro1[3];

    (* keep = "true" *) wire [4:0] ro2;
    assign ro2[0] = ~(en & ro2[4]);
    assign ro2[1] = ~ro2[0];
    assign ro2[2] = ~ro2[1];
    assign ro2[3] = ~ro2[2];
    assign ro2[4] = ~ro2[3];

    wire puf_core = ro1[4] ^ ro2[4];

    assign uo_out = {7'b0, puf_core};
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
