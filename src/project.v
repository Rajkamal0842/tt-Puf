`default_nettype none
`timescale 1ns / 1ps

// verilator lint_off UNOPTFLAT
module ro_cell (
    input  wire i_enable,
    output wire o_osc_out
);
    (* keep = "true" *) wire w1, w2, w3, w4, w5;
    assign w1 = ~(i_enable & w5); 
    assign w2 = ~w1;
    assign w3 = ~w2;
    assign w4 = ~w3;
    assign w5 = ~w4;
    assign o_osc_out = w5;
endmodule

module Puf (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire [7:0] i_challenge,
    output reg        o_response,
    output reg        o_done,
    output wire [5:0] o_debug
);
    wire [3:0] w_sel_a = i_challenge[3:0];
    wire [3:0] w_sel_b = i_challenge[7:4];
    wire [15:0] w_ros;
    wire clk_a, clk_b;
    reg r_en, r_clr;
    reg [2:0] state;
    reg [7:0] timer;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : ro_gen
            ro_cell inst (.i_enable(r_en), .o_osc_out(w_ros[i]));
        end
    endgenerate

    assign clk_a = w_ros[w_sel_a];
    assign clk_b = w_ros[w_sel_b];

    reg [7:0] cnt_a, cnt_b;
    always @(posedge clk_a or posedge r_clr) if (r_clr) cnt_a <= 0; else cnt_a <= cnt_a + 1;
    always @(posedge clk_b or posedge r_clr) if (r_clr) cnt_b <= 0; else cnt_b <= cnt_b + 1;

    assign o_debug = cnt_a[7:2];

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= 0; r_en <= 0; r_clr <= 1; o_done <= 0;
        end else begin
            case (state)
                0: begin r_clr <= 0; timer <= 0; state <= 1; end
                1: begin r_en <= 1; if (timer == 200) state <= 2; else timer <= timer + 1; end
                2: begin r_en <= 0; state <= 3; end
                3: begin o_response <= (cnt_a > cnt_b); o_done <= 1; state <= 4; end
                4: state <= 4;
            endcase
        end
    end
endmodule

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
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // This part was missing in your screenshot!
    Puf core (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_challenge(ui_in),
        .o_response(uo_out[0]),
        .o_done(uo_out[1]),
        .o_debug(uo_out[7:2])
    );
endmodule
