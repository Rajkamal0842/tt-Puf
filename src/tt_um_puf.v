`default_nettype none

// Ring Oscillator PUF - Tiny Tapeout (sky130)
//
// Each RO bit is an independent always block — no for-loop, no integer
// variable — so Yosys synthesis checks pass cleanly.
// challenge_prev inits to 0xFF so challenge 0x00 triggers on first cycle.

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

    wire [3:0] sel_a = ui_in[3:0];
    wire [3:0] sel_b = ui_in[7:4];

    // ----------------------------------------------------------------
    // RO bank — 16 independent toggle flip-flops gated by ro_en.
    // Each bit is a separate always block: no for-loop, no integer.
    // (* keep *) prevents Yosys from merging/optimising them away.
    // In silicon, distinct placement of each FF produces unique
    // routing delays — that variation IS the PUF entropy.
    // ----------------------------------------------------------------
    wire ro_en;

    (* keep = "true" *) reg ro0,  ro1,  ro2,  ro3;
    (* keep = "true" *) reg ro4,  ro5,  ro6,  ro7;
    (* keep = "true" *) reg ro8,  ro9,  ro10, ro11;
    (* keep = "true" *) reg ro12, ro13, ro14, ro15;

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

    // Collect into a bus for the MUX
    wire [15:0] ro_bus = {ro15,ro14,ro13,ro12,ro11,ro10,ro9,ro8,
                          ro7, ro6, ro5, ro4, ro3, ro2, ro1, ro0};

    wire sig_a = ro_bus[sel_a];
    wire sig_b = ro_bus[sel_b];

    // ----------------------------------------------------------------
    // FSM
    // ----------------------------------------------------------------
    localparam S_IDLE = 2'd0;
    localparam S_EVAL = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0]  state;
    reg [7:0]  eval_cnt;
    reg [7:0]  counter_a;
    reg [7:0]  counter_b;
    reg        response;
    reg        done;
    reg [7:0]  challenge_prev;
    reg        prev_a, prev_b;

    assign ro_en = (state == S_EVAL);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= S_IDLE;
            eval_cnt       <= 8'd0;
            counter_a      <= 8'd0;
            counter_b      <= 8'd0;
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
                        counter_a      <= 8'd0;
                        counter_b      <= 8'd0;
                        eval_cnt       <= 8'd0;
                        prev_a         <= 1'b0;
                        prev_b         <= 1'b0;
                        state          <= S_EVAL;
                    end
                end
                S_EVAL: begin
                    if (sig_a & ~prev_a) counter_a <= counter_a + 8'd1;
                    if (sig_b & ~prev_b) counter_b <= counter_b + 8'd1;
                    prev_a   <= sig_a;
                    prev_b   <= sig_b;
                    eval_cnt <= eval_cnt + 8'd1;
                    if (eval_cnt == 8'd199) state <= S_DONE;
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
    assign uo_out[7:2] = counter_a[7:2];
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{ena, uio_in, 1'b0};

endmodule
