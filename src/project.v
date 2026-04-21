`default_nettype none
`timescale 1ns / 1ps

module ro_cell (
    input  wire i_enable,  
    output wire o_osc_out  
);

    (* keep = "true" *) wire w_stage_1_nand;
    (* keep = "true" *) wire w_stage_2_inv;
    (* keep = "true" *) wire w_stage_3_inv;
    (* keep = "true" *) wire w_stage_4_inv;
    (* keep = "true" *) wire w_stage_5_inv;

    assign w_stage_1_nand = ~(i_enable & w_stage_5_inv); 
    assign w_stage_2_inv  = ~w_stage_1_nand;
    assign w_stage_3_inv  = ~w_stage_2_inv;
    assign w_stage_4_inv  = ~w_stage_3_inv;
    assign w_stage_5_inv  = ~w_stage_4_inv;

    assign o_osc_out = w_stage_5_inv;

endmodule

module Puf (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire [7:0] i_challenge,
    output reg        o_response,
    output reg        o_done,
    output wire [5:0] o_debug
);

    wire [3:0] w_sel_ro_a = i_challenge[3:0];
    wire [3:0] w_sel_ro_b = i_challenge[7:4];
    
    wire [15:0] w_ro_outputs; 
    wire        w_clk_domain_a;
    wire        w_clk_domain_b;

    reg r_ro_enable;             
    reg r_clear_counters;      

    localparam STATE_IDLE    = 3'd0;
    localparam STATE_CLEAR   = 3'd1;
    localparam STATE_EVAL    = 3'd2;
    localparam STATE_SETTLE  = 3'd3;
    localparam STATE_COMPARE = 3'd4;
    localparam STATE_DONE    = 3'd5;

    reg [2:0] r_current_state;
    
    localparam EVAL_WINDOW_MAX = 8'd200; 
    reg [7:0] r_eval_timer;
    reg [7:0] r_prev_challenge;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_ro_bank
            ro_cell inst_ro (
                .i_enable  (r_ro_enable),
                .o_osc_out (w_ro_outputs[i])
            );
        end
    endgenerate

    assign w_clk_domain_a = w_ro_outputs[w_sel_ro_a];
    assign w_clk_domain_b = w_ro_outputs[w_sel_ro_b];

    reg [7:0] r_count_a;
    reg [7:0] r_count_b;

    always @(posedge w_clk_domain_a or posedge r_clear_counters) begin
        if (r_clear_counters) r_count_a <= 8'b0;
        else                  r_count_a <= r_count_a + 1;
    end

    always @(posedge w_clk_domain_b or posedge r_clear_counters) begin
        if (r_clear_counters) r_count_b <= 8'b0;
        else                  r_count_b <= r_count_b + 1;
    end

    assign o_debug = r_count_a[7:2];

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_current_state  <= STATE_IDLE;
            r_ro_enable      <= 1'b0;
            r_clear_counters <= 1'b1;
            o_response       <= 1'b0;
            o_done           <= 1'b0;
            r_eval_timer     <= 8'd0;
            r_prev_challenge <= 8'd0;
        end else begin
            if (i_challenge != r_prev_challenge && r_current_state == STATE_DONE) begin
                r_current_state <= STATE_IDLE; 
            end

            case (r_current_state)
                STATE_IDLE: begin
                    o_done           <= 1'b0;
                    r_ro_enable      <= 1'b0;
                    r_clear_counters <= 1'b1; 
                    r_prev_challenge <= i_challenge;
                    r_current_state  <= STATE_CLEAR;
                end

                STATE_CLEAR: begin
                    r_clear_counters <= 1'b0; 
                    r_eval_timer     <= 8'd0;
                    r_current_state  <= STATE_EVAL;
                end

                STATE_EVAL: begin
                    r_ro_enable <= 1'b1; 
                    if (r_eval_timer >= EVAL_WINDOW_MAX) begin
                        r_ro_enable     <= 1'b0; 
                        r_current_state <= STATE_SETTLE;
                    end else begin
                        r_eval_timer <= r_eval_timer + 1;
                    end
                end

                STATE_SETTLE: begin
                    r_current_state <= STATE_COMPARE;
                end

                STATE_COMPARE: begin
                    if (r_count_a > r_count_b) begin
                        o_response <= 1'b1;
                    end else begin
                        o_response <= 1'b0;
                    end
                    r_current_state <= STATE_DONE;
                end

                STATE_DONE: begin
                    o_done <= 1'b1; 
                end

                default: r_current_state <= STATE_IDLE;
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

    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    Puf core_puf_inst (
        .i_clk       (clk),
        .i_rst_n     (rst_n),
        .i_challenge (ui_in),        
        .o_response  (uo_out[0]),    
        .o_done      (uo_out[1]),    
        .o_debug     (uo_out[7:2])   
    );

endmodule
