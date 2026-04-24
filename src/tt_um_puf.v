// Copyright (c) 2024 Your Name
// SPDX-License-Identifier: Apache-2.0
`default_nettype none

// Ring Oscillator PUF - Tiny Tapeout (sky130)
// 32 ROs, 10-bit counters, 1000-cycle evaluation window

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

    // Challenge selects two ROs to race
    wire [4:0] sel_a = {1'b0, ui_in[3:0]};
    wire [4:0] sel_b = {1'b1, ui_in[7:4], 1'b0};

    wire ro_en;

    // 32 independent toggle flip-flops — PUF entropy sources
    (* keep = "true" *) reg ro0,  ro1,  ro2,  ro3;
    (* keep = "true" *) reg ro4,  ro5,  ro6,  ro7;
    (* keep = "true" *) reg ro8,  ro9,  ro10, ro11;
    (* keep = "true" *) reg ro12, ro13, ro14, ro15;
    (* keep = "true" *) reg ro16, ro17, ro18, ro19;
    (* keep = "true" *) reg ro20, ro21, ro22, ro23;
    (* keep = "true" *) reg ro24, ro25, ro26, ro27;
    (* keep = "true" *) reg ro28, ro29, ro30, ro31;

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

    wire [31:0] ro_bus = {ro31,ro30,ro29,ro28,ro27,ro26,ro25,ro24,
                          ro23,ro22,ro21,ro20,ro19,ro18,ro17,ro16,
                          ro15,ro14,ro13,ro12,ro11,ro10,ro9, ro8,
                          ro7, ro6, ro5, ro4, ro3, ro2, ro1, ro0};

    wire sig_a = ro_bus[sel_a];
    wire sig_b = ro_bus[sel_b];

    // FSM states
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
                        state          <= S_EVAL;
                    end
                end
                S_EVAL: begin
                    if (sig_a & ~prev_a) counter_a <= counter_a + 10'd1;
                    if (sig_b & ~prev_b) counter_b <= counter_b + 10'd1;
                    prev_a   <= sig_a;
                    prev_b   <= sig_b;
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

    assign uo_out[0]   = response;
    assign uo_out[1]   = done;
    assign uo_out[7:2] = counter_a[9:4];
    assign uio_out     = 8'b0;
    assign uio_oe      = 8'b0;

    wire _unused = &{ena, uio_in, 1'b0};

endmodule
