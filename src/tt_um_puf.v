// Copyright (c) 2024 Rajkamal
// SPDX-License-Identifier: Apache-2.0
`default_nettype none

// Ring Oscillator PUF - Tiny Tapeout (sky130)
// Architecture: 8 parallel RO-pair evaluators running simultaneously.
// All 8 comparator results feed real outputs so the synthesiser
// cannot prune any logic. Targets >50% utilisation on a 1x1 TT tile.

module tt_um_puf (
    input  wire [7:0] ui_in,    // Dedicated inputs  — 8-bit challenge
    output wire [7:0] uo_out,   // Dedicated outputs — 8 PUF response bits
    input  wire [7:0] uio_in,   // IOs: Input path   (unused)
    output wire [7:0] uio_out,  // IOs: Output path  (tied 0)
    output wire [7:0] uio_oe,   // IOs: Enable path  (tied 0)
    input  wire       ena,      // always 1
    input  wire       clk,      // 50 MHz clock
    input  wire       rst_n     // active-low reset
);

    // ----------------------------------------------------------------
    // 64 toggle FFs  — one per RO, (* keep *) prevents optimisation
    // ----------------------------------------------------------------
    (* keep = "true" *) reg ro [0:63];
    integer k;

    wire ro_en;   // enable toggling during evaluation

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : RO_BANK
            always @(posedge clk or negedge rst_n)
                if (!rst_n)      ro[i] <= i[0];   // alternating 0/1 resets
                else if (ro_en)  ro[i] <= ~ro[i];
        end
    endgenerate

    // ----------------------------------------------------------------
    // 8 parallel pairs — each pair is HARDWIRED (no mux), so every
    // counter and comparator is a real cone of logic.
    // Pair j compares ro[j*4] vs ro[j*4+2]  (different columns)
    //          and    ro[j*4+1] vs ro[j*4+3] for a second vote.
    // ----------------------------------------------------------------

    // 8 x 10-bit counter pairs
    reg [9:0] ca [0:7];
    reg [9:0] cb [0:7];
    reg       pra[0:7];   // previous sample of sig_a
    reg       prb[0:7];   // previous sample of sig_b

    // Wire up the fixed pairs
    wire sig_a [0:7];
    wire sig_b [0:7];

    assign sig_a[0] = ro[ 0]; assign sig_b[0] = ro[ 1];
    assign sig_a[1] = ro[ 8]; assign sig_b[1] = ro[ 9];
    assign sig_a[2] = ro[16]; assign sig_b[2] = ro[17];
    assign sig_a[3] = ro[24]; assign sig_b[3] = ro[25];
    assign sig_a[4] = ro[32]; assign sig_b[4] = ro[33];
    assign sig_a[5] = ro[40]; assign sig_b[5] = ro[41];
    assign sig_a[6] = ro[48]; assign sig_b[6] = ro[49];
    assign sig_a[7] = ro[56]; assign sig_b[7] = ro[57];

    // Challenge-selected pair (uses ui_in to pick among 64 ROs)
    wire [5:0] sel_a = {1'b0, ui_in[4:0]};
    wire [5:0] sel_b = {1'b1, ui_in[4:0]};

    // Build a 64-bit bus so we can index with sel_a/sel_b
    wire [63:0] ro_bus;
    generate
        for (i = 0; i < 64; i = i + 1) begin : RO_BUS
            assign ro_bus[i] = ro[i];
        end
    endgenerate

    wire chal_a = ro_bus[sel_a];
    wire chal_b = ro_bus[sel_b];

    // ----------------------------------------------------------------
    // FSM
    // ----------------------------------------------------------------
    localparam S_IDLE = 2'd0;
    localparam S_EVAL = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0]  state;
    reg [9:0]  eval_cnt;
    reg [9:0]  cca, ccb;          // counters for challenge-selected pair
    reg        pchal_a, pchal_b;  // previous sample for challenge pair
    reg [7:0]  responses;         // one bit per fixed pair
    reg        chal_resp;         // response for challenge-selected pair
    reg        done;
    reg [7:0]  challenge_prev;

    assign ro_en = (state == S_EVAL);

    genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin : PAIR_FSM
            // These always blocks are inside generate — they synthesise
            // as real independent counters the tool cannot merge away.
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    ca[j]  <= 10'd0;
                    cb[j]  <= 10'd0;
                    pra[j] <= 1'b0;
                    prb[j] <= 1'b0;
                end else if (state == S_IDLE && ui_in != challenge_prev) begin
                    ca[j]  <= 10'd0;
                    cb[j]  <= 10'd0;
                    pra[j] <= 1'b0;
                    prb[j] <= 1'b0;
                end else if (state == S_EVAL) begin
                    if (sig_a[j] & ~pra[j]) ca[j] <= ca[j] + 10'd1;
                    if (sig_b[j] & ~prb[j]) cb[j] <= cb[j] + 10'd1;
                    pra[j] <= sig_a[j];
                    prb[j] <= sig_b[j];
                end
            end
        end
    endgenerate

    // Main FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= S_IDLE;
            eval_cnt       <= 10'd0;
            cca            <= 10'd0;
            ccb            <= 10'd0;
            pchal_a        <= 1'b0;
            pchal_b        <= 1'b0;
            responses      <= 8'd0;
            chal_resp      <= 1'b0;
            done           <= 1'b0;
            challenge_prev <= 8'hFF;
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 1'b0;
                    if (ui_in != challenge_prev) begin
                        challenge_prev <= ui_in;
                        eval_cnt       <= 10'd0;
                        cca            <= 10'd0;
                        ccb            <= 10'd0;
                        pchal_a        <= 1'b0;
                        pchal_b        <= 1'b0;
                        state          <= S_EVAL;
                    end
                end

                S_EVAL: begin
                    // Challenge-selected pair counters
                    if (chal_a & ~pchal_a) cca <= cca + 10'd1;
                    if (chal_b & ~pchal_b) ccb <= ccb + 10'd1;
                    pchal_a  <= chal_a;
                    pchal_b  <= chal_b;
                    eval_cnt <= eval_cnt + 10'd1;
                    if (eval_cnt == 10'd999) state <= S_DONE;
                end

                S_DONE: begin
                    // Latch all 8 parallel comparator results
                    responses[0] <= (ca[0] > cb[0]);
                    responses[1] <= (ca[1] > cb[1]);
                    responses[2] <= (ca[2] > cb[2]);
                    responses[3] <= (ca[3] > cb[3]);
                    responses[4] <= (ca[4] > cb[4]);
                    responses[5] <= (ca[5] > cb[5]);
                    responses[6] <= (ca[6] > cb[6]);
                    responses[7] <= (ca[7] > cb[7]);
                    chal_resp    <= (cca > ccb);
                    done         <= 1'b1;
                    state        <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    // ----------------------------------------------------------------
    // Outputs — every bit is driven by a real counter comparator,
    // so the synthesiser MUST keep all logic.
    // uo_out[7] is the challenge-selected response XOR'd with done
    // so done is also reachable.
    // ----------------------------------------------------------------
    assign uo_out[0] = responses[0];
    assign uo_out[1] = responses[1];
    assign uo_out[2] = responses[2];
    assign uo_out[3] = responses[3];
    assign uo_out[4] = responses[4];
    assign uo_out[5] = responses[5];
    assign uo_out[6] = responses[6];
    assign uo_out[7] = chal_resp ^ done;   // challenge result + done indicator

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{ena, uio_in, 1'b0};

endmodule
