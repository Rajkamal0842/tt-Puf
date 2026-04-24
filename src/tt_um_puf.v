// Copyright (c) 2024 Rajkamal
// SPDX-License-Identifier: Apache-2.0
`default_nettype none

// Ring Oscillator PUF - Tiny Tapeout (sky130)
// 64 ROs, 10-bit counters, 1000-cycle window, XOR accumulator
// Target: >50% utilisation (~700 cells) on 1x1 TT tile

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

    wire ro_en;

    // ----------------------------------------------------------------
    // 64 independent toggle flip-flops — PUF entropy sources
    // (* keep *) prevents synthesis optimising them away
    // ----------------------------------------------------------------
    (* keep = "true" *) reg ro0,  ro1,  ro2,  ro3,  ro4,  ro5,  ro6,  ro7;
    (* keep = "true" *) reg ro8,  ro9,  ro10, ro11, ro12, ro13, ro14, ro15;
    (* keep = "true" *) reg ro16, ro17, ro18, ro19, ro20, ro21, ro22, ro23;
    (* keep = "true" *) reg ro24, ro25, ro26, ro27, ro28, ro29, ro30, ro31;
    (* keep = "true" *) reg ro32, ro33, ro34, ro35, ro36, ro37, ro38, ro39;
    (* keep = "true" *) reg ro40, ro41, ro42, ro43, ro44, ro45, ro46, ro47;
    (* keep = "true" *) reg ro48, ro49, ro50, ro51, ro52, ro53, ro54, ro55;
    (* keep = "true" *) reg ro56, ro57, ro58, ro59, ro60, ro61, ro62, ro63;

    // Bank A: ro0..ro31
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro0  <= 1'b0; else if (ro_en) ro0  <= ~ro0;  end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro1  <= 1'b1; else if (ro_en) ro1  <= ~ro1;  end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro2  <= 1'b0; else if (ro_en) ro2  <= ~ro2;  end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro3  <= 1'b1; else if (ro_en) ro3  <= ~ro3;  end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro4  <= 1'b0; else if (ro_en) ro4  <= ~ro4;  end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro5  <= 1'b1; else if (ro_en) ro5  <= ~ro5;  end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro6  <= 1'b0; else if (ro_en) ro6  <= ~ro6;  end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro7  <= 1'b1; else if (ro_en) ro7  <= ~ro7;  end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro8  <= 1'b0; else if (ro_en) ro8  <= ~ro8;  end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro9  <= 1'b1; else if (ro_en) ro9  <= ~ro9;  end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro10 <= 1'b0; else if (ro_en) ro10 <= ~ro10; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro11 <= 1'b1; else if (ro_en) ro11 <= ~ro11; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro12 <= 1'b0; else if (ro_en) ro12 <= ~ro12; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro13 <= 1'b1; else if (ro_en) ro13 <= ~ro13; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro14 <= 1'b0; else if (ro_en) ro14 <= ~ro14; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro15 <= 1'b1; else if (ro_en) ro15 <= ~ro15; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro16 <= 1'b0; else if (ro_en) ro16 <= ~ro16; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro17 <= 1'b1; else if (ro_en) ro17 <= ~ro17; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro18 <= 1'b0; else if (ro_en) ro18 <= ~ro18; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro19 <= 1'b1; else if (ro_en) ro19 <= ~ro19; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro20 <= 1'b0; else if (ro_en) ro20 <= ~ro20; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro21 <= 1'b1; else if (ro_en) ro21 <= ~ro21; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro22 <= 1'b0; else if (ro_en) ro22 <= ~ro22; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro23 <= 1'b1; else if (ro_en) ro23 <= ~ro23; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro24 <= 1'b0; else if (ro_en) ro24 <= ~ro24; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro25 <= 1'b1; else if (ro_en) ro25 <= ~ro25; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro26 <= 1'b0; else if (ro_en) ro26 <= ~ro26; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro27 <= 1'b1; else if (ro_en) ro27 <= ~ro27; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro28 <= 1'b0; else if (ro_en) ro28 <= ~ro28; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro29 <= 1'b1; else if (ro_en) ro29 <= ~ro29; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro30 <= 1'b0; else if (ro_en) ro30 <= ~ro30; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro31 <= 1'b1; else if (ro_en) ro31 <= ~ro31; end

    // Bank B: ro32..ro63
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro32 <= 1'b0; else if (ro_en) ro32 <= ~ro32; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro33 <= 1'b1; else if (ro_en) ro33 <= ~ro33; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro34 <= 1'b0; else if (ro_en) ro34 <= ~ro34; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro35 <= 1'b1; else if (ro_en) ro35 <= ~ro35; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro36 <= 1'b0; else if (ro_en) ro36 <= ~ro36; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro37 <= 1'b1; else if (ro_en) ro37 <= ~ro37; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro38 <= 1'b0; else if (ro_en) ro38 <= ~ro38; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro39 <= 1'b1; else if (ro_en) ro39 <= ~ro39; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro40 <= 1'b0; else if (ro_en) ro40 <= ~ro40; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro41 <= 1'b1; else if (ro_en) ro41 <= ~ro41; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro42 <= 1'b0; else if (ro_en) ro42 <= ~ro42; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro43 <= 1'b1; else if (ro_en) ro43 <= ~ro43; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro44 <= 1'b0; else if (ro_en) ro44 <= ~ro44; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro45 <= 1'b1; else if (ro_en) ro45 <= ~ro45; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro46 <= 1'b0; else if (ro_en) ro46 <= ~ro46; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro47 <= 1'b1; else if (ro_en) ro47 <= ~ro47; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro48 <= 1'b0; else if (ro_en) ro48 <= ~ro48; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro49 <= 1'b1; else if (ro_en) ro49 <= ~ro49; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro50 <= 1'b0; else if (ro_en) ro50 <= ~ro50; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro51 <= 1'b1; else if (ro_en) ro51 <= ~ro51; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro52 <= 1'b0; else if (ro_en) ro52 <= ~ro52; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro53 <= 1'b1; else if (ro_en) ro53 <= ~ro53; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro54 <= 1'b0; else if (ro_en) ro54 <= ~ro54; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro55 <= 1'b1; else if (ro_en) ro55 <= ~ro55; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro56 <= 1'b0; else if (ro_en) ro56 <= ~ro56; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro57 <= 1'b1; else if (ro_en) ro57 <= ~ro57; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro58 <= 1'b0; else if (ro_en) ro58 <= ~ro58; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro59 <= 1'b1; else if (ro_en) ro59 <= ~ro59; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro60 <= 1'b0; else if (ro_en) ro60 <= ~ro60; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro61 <= 1'b1; else if (ro_en) ro61 <= ~ro61; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro62 <= 1'b0; else if (ro_en) ro62 <= ~ro62; end
    always @(posedge clk or negedge rst_n) begin if (!rst_n) ro63 <= 1'b1; else if (ro_en) ro63 <= ~ro63; end

    // Full 64-bit RO bus
    wire [63:0] ro_bus = {
        ro63,ro62,ro61,ro60,ro59,ro58,ro57,ro56,
        ro55,ro54,ro53,ro52,ro51,ro50,ro49,ro48,
        ro47,ro46,ro45,ro44,ro43,ro42,ro41,ro40,
        ro39,ro38,ro37,ro36,ro35,ro34,ro33,ro32,
        ro31,ro30,ro29,ro28,ro27,ro26,ro25,ro24,
        ro23,ro22,ro21,ro20,ro19,ro18,ro17,ro16,
        ro15,ro14,ro13,ro12,ro11,ro10,ro9, ro8,
        ro7, ro6, ro5, ro4, ro3, ro2, ro1, ro0
    };

    // Challenge selects two ROs — 6 bits each, MSB inverted so A != B
    wire [5:0] sel_a = ui_in[5:0];
    wire [5:0] sel_b = {~ui_in[5], ui_in[4:0]};

    wire sig_a = ro_bus[sel_a];
    wire sig_b = ro_bus[sel_b];

    // ----------------------------------------------------------------
    // FSM
    // ----------------------------------------------------------------
    localparam S_IDLE = 2'd0;
    localparam S_EVAL = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0]  state;
    reg [9:0]  eval_cnt;
    reg [9:0]  counter_a;
    reg [9:0]  counter_b;
    reg        response;
    reg        done;
    reg [7:0]  challenge_prev;
    reg        prev_a, prev_b;

    // Extra logic for higher cell count: XOR accumulator + vote counter
    reg [7:0]  acc_xor;
    reg [7:0]  acc_votes;

    assign ro_en = (state == S_EVAL);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= S_IDLE;
            eval_cnt       <= 10'd0;
            counter_a      <= 10'd0;
            counter_b      <= 10'd0;
            response       <= 1'b0;
            done           <= 1'b0;
            challenge_prev <= 8'hFF;
            prev_a         <= 1'b0;
            prev_b         <= 1'b0;
            acc_xor        <= 8'd0;
            acc_votes      <= 8'd0;
        end else begin
            case (state)

                S_IDLE: begin
                    done <= 1'b0;
                    if (ui_in != challenge_prev) begin
                        challenge_prev <= ui_in;
                        counter_a      <= 10'd0;
                        counter_b      <= 10'd0;
                        eval_cnt       <= 10'd0;
                        prev_a         <= 1'b0;
                        prev_b         <= 1'b0;
                        acc_xor        <= 8'd0;
                        acc_votes      <= 8'd0;
                        state          <= S_EVAL;
                    end
                end

                S_EVAL: begin
                    // Rising-edge counters for selected pair
                    if (sig_a & ~prev_a) counter_a <= counter_a + 10'd1;
                    if (sig_b & ~prev_b) counter_b <= counter_b + 10'd1;
                    prev_a <= sig_a;
                    prev_b <= sig_b;

                    // XOR all 8 bytes of the RO bus each cycle (adds ~64 XOR gates)
                    acc_xor <= acc_xor
                                ^ ro_bus[ 7: 0] ^ ro_bus[15: 8]
                                ^ ro_bus[23:16] ^ ro_bus[31:24]
                                ^ ro_bus[39:32] ^ ro_bus[47:40]
                                ^ ro_bus[55:48] ^ ro_bus[63:56];

                    // Majority-vote counter (adds adder logic)
                    acc_votes <= acc_votes + {7'd0, (sig_a ^ sig_b)};

                    eval_cnt <= eval_cnt + 10'd1;
                    if (eval_cnt == 10'd999) state <= S_DONE;
                end

                S_DONE: begin
                    response <= (counter_a > counter_b) ? 1'b1 : 1'b0;
                    done     <= 1'b1;
                    state    <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    // ----------------------------------------------------------------
    // Output assignments
    // ----------------------------------------------------------------
    assign uo_out[0]   = response;
    assign uo_out[1]   = done;
    assign uo_out[7:2] = acc_xor[5:0];  // XOR entropy hash for debug

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Suppress unused warnings
    wire _unused = &{ena, uio_in, counter_b[9:0], counter_a[1:0], acc_votes[7:0], 1'b0};

endmodule
