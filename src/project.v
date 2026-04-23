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

    localparam [1:0] S_IDLE = 2'd0;
    localparam [1:0] S_EVAL = 2'd1;
    localparam [1:0] S_DONE = 2'd2;

    reg [1:0] state;
    reg [7:0] eval_cnt;
    reg [7:0] counter_a;
    reg [7:0] counter_b;
    reg       response;
    reg       done;
    reg [7:0] challenge_prev;
    reg       prev_a;
    reg       prev_b;

    reg ro0,  ro1,  ro2,  ro3,  ro4,  ro5,  ro6,  ro7;
    reg ro8,  ro9,  ro10, ro11, ro12, ro13, ro14, ro15;

    wire ro_en;
    assign ro_en = (state == S_EVAL) ? 1'b1 : 1'b0;

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

    wire sig_a_w;
    wire sig_b_w;

    assign sig_a_w =
        (ui_in[3:0] == 4'd1)  ? ro1  :
        (ui_in[3:0] == 4'd2)  ? ro2  :
        (ui_in[3:0] == 4'd3)  ? ro3  :
        (ui_in[3:0] == 4'd4)  ? ro4  :
        (ui_in[3:0] == 4'd5)  ? ro5  :
        (ui_in[3:0] == 4'd6)  ? ro6  :
        (ui_in[3:0] == 4'd7)  ? ro7  :
        (ui_in[3:0] == 4'd8)  ? ro8  :
        (ui_in[3:0] == 4'd9)  ? ro9  :
        (ui_in[3:0] == 4'd10) ? ro10 :
        (ui_in[3:0] == 4'd11) ? ro11 :
        (ui_in[3:0] == 4'd12) ? ro12 :
        (ui_in[3:0] == 4'd13) ? ro13 :
        (ui_in[3:0] == 4'd14) ? ro14 :
        (ui_in[3:0] == 4'd15) ? ro15 : ro0;

    assign sig_b_w =
        (ui_in[7:4] == 4'd1)  ? ro1  :
        (ui_in[7:4] == 4'd2)  ? ro2  :
        (ui_in[7:4] == 4'd3)  ? ro3  :
        (ui_in[7:4] == 4'd4)  ? ro4  :
        (ui_in[7:4] == 4'd5)  ? ro5  :
        (ui_in[7:4] == 4'd6)  ? ro6  :
        (ui_in[7:4] == 4'd7)  ? ro7  :
        (ui_in[7:4] == 4'd8)  ? ro8  :
        (ui_in[7:4] == 4'd9)  ? ro9  :
        (ui_in[7:4] == 4'd10) ? ro10 :
        (ui_in[7:4] == 4'd11) ? ro11 :
        (ui_in[7:4] == 4'd12) ? ro12 :
        (ui_in[7:4] == 4'd13) ? ro13 :
        (ui_in[7:4] == 4'd14) ? ro14 :
        (ui_in[7:4] == 4'd15) ? ro15 : ro0;

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
                    if (sig_a_w & ~prev_a) counter_a <= counter_a + 8'd1;
                    if (sig_b_w & ~prev_b) counter_b <= counter_b + 8'd1;
                    prev_a   <= sig_a_w;
                    prev_b   <= sig_b_w;
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
    assign uio_out     = 8'b0;
    assign uio_oe      = 8'b0;

    wire _unused = &{ena, uio_in, 1'b0};

endmodule
