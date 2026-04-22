`default_nettype none

/*
 * tt_um_puf.v
 *
 * Ring Oscillator Physical Unclonable Function (RO-PUF)
 *
 * Architecture:
 *   - 16 Ring Oscillators (ROs), each a 5-inverter chain
 *   - Two 16-to-1 MUXes select RO_A and RO_B from ui_in[3:0] / ui_in[7:4]
 *   - Both selected ROs run for a fixed 200-cycle evaluation window
 *   - Two 8-bit counters count oscillations during the window
 *   - FSM compares counters → 1-bit response on uo_out[0]
 *   - uo_out[1] = done flag
 *   - uo_out[7:2] = upper 6 bits of counter A (debug)
 *
 * Pinout:
 *   ui_in[3:0]  → select RO_A (0–15)
 *   ui_in[7:4]  → select RO_B (0–15)
 *   uo_out[0]   → PUF response bit
 *   uo_out[1]   → done flag (high when result is valid)
 *   uo_out[7:2] → counter_a[7:2] (debug, upper 6 bits)
 *   uio_in[0]   → (unused, kept for compatibility)
 *   uio_out     → 8'b0
 *   uio_oe      → 8'b0
 */

module tt_um_puf (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // Bidirectional IOs: input path
    output wire [7:0] uio_out,  // Bidirectional IOs: output path
    output wire [7:0] uio_oe,   // Bidirectional IOs: enable (1=output)
    input  wire       ena,      // Design enable (active high)
    input  wire       clk,      // System clock
    input  wire       rst_n     // Active-low reset
);

    // ----------------------------------------------------------------
    // Challenge decode
    // ----------------------------------------------------------------
    wire [3:0] sel_a = ui_in[3:0];   // selects RO for counter A
    wire [3:0] sel_b = ui_in[7:4];   // selects RO for counter B

    // ----------------------------------------------------------------
    // FSM states
    // ----------------------------------------------------------------
    localparam S_IDLE  = 2'd0;
    localparam S_EVAL  = 2'd1;
    localparam S_DONE  = 2'd2;

    reg [1:0]  state;
    reg [7:0]  eval_cnt;    // counts evaluation window (0–199)
    reg [7:0]  counter_a;   // oscillation counter for RO_A
    reg [7:0]  counter_b;   // oscillation counter for RO_B
    reg        response;    // 1-bit PUF output
    reg        done;        // result-valid flag

    // Previous challenge — used to detect changes and re-trigger
    reg [7:0]  challenge_prev;

    // ----------------------------------------------------------------
    // Ring Oscillator bank — 16 ROs, each a 5-stage inverter ring
    // (* keep *) prevents synthesis tools from optimising them away
    // The enable signal gates oscillation: when en=0 the ring is frozen
    // ----------------------------------------------------------------
    wire ro_enable;   // gated by FSM
    assign ro_enable = (state == S_EVAL);

    // Macro to instantiate one RO.  Each ring is structurally unique
    // because the synthesis tool will place/route them differently,
    // introducing process-variation mismatches — that IS the PUF.
    (* keep = "true" *) wire [15:0] ro_out;   // output tap of each RO

    // RO 0
    (* keep = "true" *) wire [4:0] ro0;
    assign ro0[0] = ~(ro_enable & ro0[4]);
    assign ro0[1] = ~ro0[0];  assign ro0[2] = ~ro0[1];
    assign ro0[3] = ~ro0[2];  assign ro0[4] = ~ro0[3];
    assign ro_out[0] = ro0[4];

    // RO 1
    (* keep = "true" *) wire [4:0] ro1;
    assign ro1[0] = ~(ro_enable & ro1[4]);
    assign ro1[1] = ~ro1[0];  assign ro1[2] = ~ro1[1];
    assign ro1[3] = ~ro1[2];  assign ro1[4] = ~ro1[3];
    assign ro_out[1] = ro1[4];

    // RO 2
    (* keep = "true" *) wire [4:0] ro2;
    assign ro2[0] = ~(ro_enable & ro2[4]);
    assign ro2[1] = ~ro2[0];  assign ro2[2] = ~ro2[1];
    assign ro2[3] = ~ro2[2];  assign ro2[4] = ~ro2[3];
    assign ro_out[2] = ro2[4];

    // RO 3
    (* keep = "true" *) wire [4:0] ro3;
    assign ro3[0] = ~(ro_enable & ro3[4]);
    assign ro3[1] = ~ro3[0];  assign ro3[2] = ~ro3[1];
    assign ro3[3] = ~ro3[2];  assign ro3[4] = ~ro3[3];
    assign ro_out[3] = ro3[4];

    // RO 4
    (* keep = "true" *) wire [4:0] ro4;
    assign ro4[0] = ~(ro_enable & ro4[4]);
    assign ro4[1] = ~ro4[0];  assign ro4[2] = ~ro4[1];
    assign ro4[3] = ~ro4[2];  assign ro4[4] = ~ro4[3];
    assign ro_out[4] = ro4[4];

    // RO 5
    (* keep = "true" *) wire [4:0] ro5;
    assign ro5[0] = ~(ro_enable & ro5[4]);
    assign ro5[1] = ~ro5[0];  assign ro5[2] = ~ro5[1];
    assign ro5[3] = ~ro5[2];  assign ro5[4] = ~ro5[3];
    assign ro_out[5] = ro5[4];

    // RO 6
    (* keep = "true" *) wire [4:0] ro6;
    assign ro6[0] = ~(ro_enable & ro6[4]);
    assign ro6[1] = ~ro6[0];  assign ro6[2] = ~ro6[1];
    assign ro6[3] = ~ro6[2];  assign ro6[4] = ~ro6[3];
    assign ro_out[6] = ro6[4];

    // RO 7
    (* keep = "true" *) wire [4:0] ro7;
    assign ro7[0] = ~(ro_enable & ro7[4]);
    assign ro7[1] = ~ro7[0];  assign ro7[2] = ~ro7[1];
    assign ro7[3] = ~ro7[2];  assign ro7[4] = ~ro7[3];
    assign ro_out[7] = ro7[4];

    // RO 8
    (* keep = "true" *) wire [4:0] ro8;
    assign ro8[0] = ~(ro_enable & ro8[4]);
    assign ro8[1] = ~ro8[0];  assign ro8[2] = ~ro8[1];
    assign ro8[3] = ~ro8[2];  assign ro8[4] = ~ro8[3];
    assign ro_out[8] = ro8[4];

    // RO 9
    (* keep = "true" *) wire [4:0] ro9;
    assign ro9[0] = ~(ro_enable & ro9[4]);
    assign ro9[1] = ~ro9[0];  assign ro9[2] = ~ro9[1];
    assign ro9[3] = ~ro9[2];  assign ro9[4] = ~ro9[3];
    assign ro_out[9] = ro9[4];

    // RO 10
    (* keep = "true" *) wire [4:0] ro10;
    assign ro10[0] = ~(ro_enable & ro10[4]);
    assign ro10[1] = ~ro10[0]; assign ro10[2] = ~ro10[1];
    assign ro10[3] = ~ro10[2]; assign ro10[4] = ~ro10[3];
    assign ro_out[10] = ro10[4];

    // RO 11
    (* keep = "true" *) wire [4:0] ro11;
    assign ro11[0] = ~(ro_enable & ro11[4]);
    assign ro11[1] = ~ro11[0]; assign ro11[2] = ~ro11[1];
    assign ro11[3] = ~ro11[2]; assign ro11[4] = ~ro11[3];
    assign ro_out[11] = ro11[4];

    // RO 12
    (* keep = "true" *) wire [4:0] ro12;
    assign ro12[0] = ~(ro_enable & ro12[4]);
    assign ro12[1] = ~ro12[0]; assign ro12[2] = ~ro12[1];
    assign ro12[3] = ~ro12[2]; assign ro12[4] = ~ro12[3];
    assign ro_out[12] = ro12[4];

    // RO 13
    (* keep = "true" *) wire [4:0] ro13;
    assign ro13[0] = ~(ro_enable & ro13[4]);
    assign ro13[1] = ~ro13[0]; assign ro13[2] = ~ro13[1];
    assign ro13[3] = ~ro13[2]; assign ro13[4] = ~ro13[3];
    assign ro_out[13] = ro13[4];

    // RO 14
    (* keep = "true" *) wire [4:0] ro14;
    assign ro14[0] = ~(ro_enable & ro14[4]);
    assign ro14[1] = ~ro14[0]; assign ro14[2] = ~ro14[1];
    assign ro14[3] = ~ro14[2]; assign ro14[4] = ~ro14[3];
    assign ro_out[14] = ro14[4];

    // RO 15
    (* keep = "true" *) wire [4:0] ro15;
    assign ro15[0] = ~(ro_enable & ro15[4]);
    assign ro15[1] = ~ro15[0]; assign ro15[2] = ~ro15[1];
    assign ro15[3] = ~ro15[2]; assign ro15[4] = ~ro15[3];
    assign ro_out[15] = ro15[4];

    // ----------------------------------------------------------------
    // 16-to-1 MUXes — select which RO feeds each counter
    // ----------------------------------------------------------------
    wire selected_a = ro_out[sel_a];
    wire selected_b = ro_out[sel_b];

    // ----------------------------------------------------------------
    // Edge-detect registers for counting oscillations synchronously
    // ----------------------------------------------------------------
    reg prev_a, prev_b;

    // ----------------------------------------------------------------
    // FSM + counters
    // ----------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= S_IDLE;
            eval_cnt       <= 8'd0;
            counter_a      <= 8'd0;
            counter_b      <= 8'd0;
            response       <= 1'b0;
            done           <= 1'b0;
            challenge_prev <= 8'd0;
            prev_a         <= 1'b0;
            prev_b         <= 1'b0;
        end else begin
            case (state)
                // ------------------------------------------------
                S_IDLE: begin
                    done      <= 1'b0;
                    // Start a new evaluation whenever the challenge changes
                    // (or on the very first cycle after reset)
                    if (ui_in != challenge_prev) begin
                        challenge_prev <= ui_in;
                        counter_a      <= 8'd0;
                        counter_b      <= 8'd0;
                        eval_cnt       <= 8'd0;
                        prev_a         <= 1'b0;
                        prev_b         <= 1'b0;
                        state          <= S_EVAL;
                    end
                end

                // ------------------------------------------------
                S_EVAL: begin
                    // Count rising edges of each selected RO
                    if (selected_a && !prev_a)
                        counter_a <= counter_a + 8'd1;
                    if (selected_b && !prev_b)
                        counter_b <= counter_b + 8'd1;

                    prev_a   <= selected_a;
                    prev_b   <= selected_b;
                    eval_cnt <= eval_cnt + 8'd1;

                    // 200-cycle window
                    if (eval_cnt == 8'd199) begin
                        state <= S_DONE;
                    end
                end

                // ------------------------------------------------
                S_DONE: begin
                    // RO with higher count runs faster → response = 1
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
    assign uo_out[0]   = response;          // PUF response bit
    assign uo_out[1]   = done;              // result valid flag
    assign uo_out[7:2] = counter_a[7:2];   // debug: upper 6 bits of counter A

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Silence unused-signal warnings
    wire _unused = &{ena, uio_in, 1'b0};

endmodule
