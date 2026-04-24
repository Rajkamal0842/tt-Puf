/* verilator lint_off UNUSEDSIGNAL */
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

  // ── Bidirectional pins unused ─────────────────────────────────────────────
  assign uio_out = 8'h00;
  assign uio_oe  = 8'h00;

  // ── Challenge select ──────────────────────────────────────────────────────
  wire [2:0] sel = ui_in[2:0];

  // =========================================================================
  // 16 Ring Oscillators (shift-register style, each structurally unique)
  // Depths 3..18, each with a unique feedback tap so synth cannot merge them.
  // Each RO is kept alive by (* keep *) and drives a toggle FF.
  // Total FFs for ROs: sum of depths = 3+4+5+6+7+8+9+10+11+12+7+8+9+10+11+12
  // = 132 FFs  →  compact but unique
  // =========================================================================

  (* keep = "true" *) reg [2:0]  ro0;
  (* keep = "true" *) reg [3:0]  ro1;
  (* keep = "true" *) reg [4:0]  ro2;
  (* keep = "true" *) reg [5:0]  ro3;
  (* keep = "true" *) reg [6:0]  ro4;
  (* keep = "true" *) reg [7:0]  ro5;
  (* keep = "true" *) reg [8:0]  ro6;
  (* keep = "true" *) reg [9:0]  ro7;
  (* keep = "true" *) reg [10:0] ro8;
  (* keep = "true" *) reg [11:0] ro9;
  (* keep = "true" *) reg [6:0]  ro10;
  (* keep = "true" *) reg [7:0]  ro11;
  (* keep = "true" *) reg [8:0]  ro12;
  (* keep = "true" *) reg [9:0]  ro13;
  (* keep = "true" *) reg [10:0] ro14;
  (* keep = "true" *) reg [11:0] ro15;

  always @(posedge clk) begin
    ro0  <= {ro0 [1:0], ro0 [2]^ro0 [0]};
    ro1  <= {ro1 [2:0], ro1 [3]^ro1 [1]};
    ro2  <= {ro2 [3:0], ro2 [4]^ro2 [2]^ro2[0]};
    ro3  <= {ro3 [4:0], ro3 [5]^ro3 [3]^ro3[1]};
    ro4  <= {ro4 [5:0], ro4 [6]^ro4 [4]^ro4[2]};
    ro5  <= {ro5 [6:0], ro5 [7]^ro5 [5]^ro5[3]^ro5[0]};
    ro6  <= {ro6 [7:0], ro6 [8]^ro6 [6]^ro6[4]^ro6[1]};
    ro7  <= {ro7 [8:0], ro7 [9]^ro7 [7]^ro7[5]^ro7[2]};
    ro8  <= {ro8 [9:0], ro8 [10]^ro8[8]^ro8[6]^ro8[3]};
    ro9  <= {ro9 [10:0],ro9 [11]^ro9[9]^ro9[7]^ro9[4]};
    ro10 <= {ro10[5:0], ro10[6]^ro10[4]^ro10[2]^ro10[1]};
    ro11 <= {ro11[6:0], ro11[7]^ro11[5]^ro11[3]^ro11[2]};
    ro12 <= {ro12[7:0], ro12[8]^ro12[6]^ro12[4]^ro12[3]};
    ro13 <= {ro13[8:0], ro13[9]^ro13[7]^ro13[5]^ro13[4]};
    ro14 <= {ro14[9:0], ro14[10]^ro14[8]^ro14[6]^ro14[5]};
    ro15 <= {ro15[10:0],ro15[11]^ro15[9]^ro15[7]^ro15[6]};
  end

  // ── Toggle FFs (one per RO) ───────────────────────────────────────────────
  (* keep = "true" *) reg [15:0] tog;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) tog <= 16'h0000;
    else tog <= tog ^ {ro15[0],ro14[0],ro13[0],ro12[0],
                       ro11[0],ro10[0],ro9[0], ro8[0],
                       ro7[0], ro6[0], ro5[0], ro4[0],
                       ro3[0], ro2[0], ro1[0], ro0[0]};
  end

  // =========================================================================
  // Reset logic for ring oscillators — staggered seeds so all differ
  // =========================================================================
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ro0  <= 3'h1;  ro1  <= 4'h3;  ro2  <= 5'h05; ro3  <= 6'h09;
      ro4  <= 7'h11; ro5  <= 8'hA5; ro6  <= 9'h055;ro7  <= 10'h0F3;
      ro8  <= 11'h155;ro9 <=12'hA55;ro10 <= 7'h2B; ro11 <= 8'hD3;
      ro12 <= 9'h16D;ro13<=10'h39C;ro14 <=11'h5A3; ro15 <=12'hC9A;
    end else begin
      ro0  <= {ro0 [1:0], ro0 [2]^ro0 [0]};
      ro1  <= {ro1 [2:0], ro1 [3]^ro1 [1]};
      ro2  <= {ro2 [3:0], ro2 [4]^ro2 [2]^ro2[0]};
      ro3  <= {ro3 [4:0], ro3 [5]^ro3 [3]^ro3[1]};
      ro4  <= {ro4 [5:0], ro4 [6]^ro4 [4]^ro4[2]};
      ro5  <= {ro5 [6:0], ro5 [7]^ro5 [5]^ro5[3]^ro5[0]};
      ro6  <= {ro6 [7:0], ro6 [8]^ro6 [6]^ro6[4]^ro6[1]};
      ro7  <= {ro7 [8:0], ro7 [9]^ro7 [7]^ro7[5]^ro7[2]};
      ro8  <= {ro8 [9:0], ro8 [10]^ro8[8]^ro8[6]^ro8[3]};
      ro9  <= {ro9 [10:0],ro9 [11]^ro9[9]^ro9[7]^ro9[4]};
      ro10 <= {ro10[5:0], ro10[6]^ro10[4]^ro10[2]^ro10[1]};
      ro11 <= {ro11[6:0], ro11[7]^ro11[5]^ro11[3]^ro11[2]};
      ro12 <= {ro12[7:0], ro12[8]^ro12[6]^ro12[4]^ro12[3]};
      ro13 <= {ro13[8:0], ro13[9]^ro13[7]^ro13[5]^ro13[4]};
      ro14 <= {ro14[9:0], ro14[10]^ro14[8]^ro14[6]^ro14[5]};
      ro15 <= {ro15[10:0],ro15[11]^ro15[9]^ro15[7]^ro15[6]};
    end
  end

  // =========================================================================
  // FSM + 1023-cycle measurement window
  // =========================================================================
  reg [9:0] meas_cnt;
  reg       running, done_r;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      meas_cnt <= 10'd0;
      running  <= 1'b0;
      done_r   <= 1'b0;
    end else begin
      done_r <= 1'b0;
      if (!running) begin
        running  <= 1'b1;
        meas_cnt <= 10'd0;
      end else if (meas_cnt == 10'd1022) begin
        done_r  <= 1'b1;
        running <= 1'b0;
      end else begin
        meas_cnt <= meas_cnt + 10'd1;
      end
    end
  end

  // =========================================================================
  // 8 counter pairs (16-bit each) — count tog bits during window
  // =========================================================================
  reg [15:0] cntA0,cntB0, cntA1,cntB1, cntA2,cntB2, cntA3,cntB3;
  reg [15:0] cntA4,cntB4, cntA5,cntB5, cntA6,cntB6, cntA7,cntB7;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cntA0<=0;cntB0<=0; cntA1<=0;cntB1<=0;
      cntA2<=0;cntB2<=0; cntA3<=0;cntB3<=0;
      cntA4<=0;cntB4<=0; cntA5<=0;cntB5<=0;
      cntA6<=0;cntB6<=0; cntA7<=0;cntB7<=0;
    end else if (running) begin
      if (tog[0])  cntA0 <= cntA0 + 16'd1;
      if (tog[1])  cntB0 <= cntB0 + 16'd1;
      if (tog[2])  cntA1 <= cntA1 + 16'd1;
      if (tog[3])  cntB1 <= cntB1 + 16'd1;
      if (tog[4])  cntA2 <= cntA2 + 16'd1;
      if (tog[5])  cntB2 <= cntB2 + 16'd1;
      if (tog[6])  cntA3 <= cntA3 + 16'd1;
      if (tog[7])  cntB3 <= cntB3 + 16'd1;
      if (tog[8])  cntA4 <= cntA4 + 16'd1;
      if (tog[9])  cntB4 <= cntB4 + 16'd1;
      if (tog[10]) cntA5 <= cntA5 + 16'd1;
      if (tog[11]) cntB5 <= cntB5 + 16'd1;
      if (tog[12]) cntA6 <= cntA6 + 16'd1;
      if (tog[13]) cntB6 <= cntB6 + 16'd1;
      if (tog[14]) cntA7 <= cntA7 + 16'd1;
      if (tog[15]) cntB7 <= cntB7 + 16'd1;
    end
  end

  // ── PUF response bits (latched at done) ───────────────────────────────────
  reg [7:0] puf_bits;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) puf_bits <= 8'h00;
    else if (done_r) begin
      puf_bits[0] <= (cntA0 > cntB0);
      puf_bits[1] <= (cntA1 > cntB1);
      puf_bits[2] <= (cntA2 > cntB2);
      puf_bits[3] <= (cntA3 > cntB3);
      puf_bits[4] <= (cntA4 > cntB4);
      puf_bits[5] <= (cntA5 > cntB5);
      puf_bits[6] <= (cntA6 > cntB6);
      puf_bits[7] <= (cntA7 > cntB7);
    end
  end

  // =========================================================================
  // 32-bit Galois LFSR (taps 32,22,2,1)
  // =========================================================================
  reg [31:0] lfsr32;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) lfsr32 <= 32'hDEADBEEF;
    else lfsr32 <= {1'b0, lfsr32[31:1]} ^
                   (lfsr32[0] ? 32'h80200003 : 32'h0);
  end

  // =========================================================================
  // 16-bit LFSR (taps 16,15,13,4)
  // =========================================================================
  reg [15:0] lfsr16;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) lfsr16 <= 16'hACE1;
    else lfsr16 <= {1'b0, lfsr16[15:1]} ^
                   (lfsr16[0] ? 16'hB400 : 16'h0);
  end

  // =========================================================================
  // CRC-32/IEEE-802.3 — one byte per cycle over tog[7:0] ^ lfsr32[7:0]
  // =========================================================================
  reg [31:0] crc32;
  wire [7:0]  crc_in = tog[7:0] ^ lfsr32[7:0];

  function [31:0] crc32_byte;
    input [31:0] crc;
    input [7:0]  data;
    reg   [31:0] c;
    integer i;
    begin
      c = crc ^ {24'h0, data};
      for (i = 0; i < 8; i = i+1)
        c = c[0] ? ({1'b0,c[31:1]} ^ 32'hEDB88320) : {1'b0,c[31:1]};
      crc32_byte = c;
    end
  endfunction

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) crc32 <= 32'hFFFFFFFF;
    else        crc32 <= crc32_byte(crc32, crc_in);
  end

  // =========================================================================
  // CRC-16/CCITT — one byte per cycle over tog[15:8] ^ lfsr16[7:0]
  // =========================================================================
  reg [15:0] crc16;
  wire [7:0]  crc16_in = tog[15:8] ^ lfsr16[7:0];

  function [15:0] crc16_byte;
    input [15:0] crc;
    input [7:0]  data;
    reg   [15:0] c;
    integer i;
    begin
      c = crc ^ {8'h0, data};
      for (i = 0; i < 8; i = i+1)
        c = c[0] ? ({1'b0,c[15:1]} ^ 16'hA001) : {1'b0,c[15:1]};
      crc16_byte = c;
    end
  endfunction

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) crc16 <= 16'hFFFF;
    else        crc16 <= crc16_byte(crc16, crc16_in);
  end

  // =========================================================================
  // Hamming-weight popcount of tog[15:0] — 4-level adder tree
  // =========================================================================
  wire [1:0] h0 = {1'b0,tog[0]}  + {1'b0,tog[1]};
  wire [1:0] h1 = {1'b0,tog[2]}  + {1'b0,tog[3]};
  wire [1:0] h2 = {1'b0,tog[4]}  + {1'b0,tog[5]};
  wire [1:0] h3 = {1'b0,tog[6]}  + {1'b0,tog[7]};
  wire [1:0] h4 = {1'b0,tog[8]}  + {1'b0,tog[9]};
  wire [1:0] h5 = {1'b0,tog[10]} + {1'b0,tog[11]};
  wire [1:0] h6 = {1'b0,tog[12]} + {1'b0,tog[13]};
  wire [1:0] h7 = {1'b0,tog[14]} + {1'b0,tog[15]};
  wire [2:0] h8 = {1'b0,h0} + {1'b0,h1};
  wire [2:0] h9 = {1'b0,h2} + {1'b0,h3};
  wire [2:0] ha = {1'b0,h4} + {1'b0,h5};
  wire [2:0] hb = {1'b0,h6} + {1'b0,h7};
  wire [3:0] hc = {1'b0,h8} + {1'b0,h9};
  wire [3:0] hd = {1'b0,ha} + {1'b0,hb};
  wire [4:0] ham1 = {1'b0,hc} + {1'b0,hd};

  // =========================================================================
  // Two pipeline registers (keep area lean — just 2 × 8 = 16 FFs)
  // =========================================================================
  (* keep = "true" *) reg [7:0] pipe1, pipe2;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pipe1 <= 8'h00;
      pipe2 <= 8'h00;
    end else begin
      pipe1 <= tog[7:0]   ^ crc32[7:0]  ^ lfsr32[15:8];
      pipe2 <= tog[15:8]  ^ crc16[7:0]  ^ lfsr16[15:8];
    end
  end

  // =========================================================================
  // Mux selected counter pair for debug output
  // =========================================================================
  reg [15:0] selA, selB;
  always @(*) begin
    case (sel)
      3'd0: begin selA = cntA0; selB = cntB0; end
      3'd1: begin selA = cntA1; selB = cntB1; end
      3'd2: begin selA = cntA2; selB = cntB2; end
      3'd3: begin selA = cntA3; selB = cntB3; end
      3'd4: begin selA = cntA4; selB = cntB4; end
      3'd5: begin selA = cntA5; selB = cntB5; end
      3'd6: begin selA = cntA6; selB = cntB6; end
      default: begin selA = cntA7; selB = cntB7; end
    endcase
  end

  // =========================================================================
  // Debug output byte: XOR of selected counters, pipes, CRC, hamming
  // =========================================================================
  wire [7:0] debug_out = selA[7:0] ^ selB[7:0] ^ pipe1
                        ^ crc32[7:0] ^ {3'b0, ham1[4:0]};

  // =========================================================================
  // Output assignments
  // uo_out[0] = PUF response (XOR of all 8 puf_bits scrambled)
  // uo_out[1] = done pulse
  // uo_out[7:2] = debug_out[7:2]
  // =========================================================================
  wire puf_response = ^(puf_bits ^ crc32[7:0] ^ lfsr32[7:0]
                        ^ {3'b0, ham1[4:0]} ^ pipe2);

  assign uo_out[0]   = puf_response;
  assign uo_out[1]   = done_r;
  assign uo_out[7:2] = debug_out[7:2];

endmodule
/* verilator lint_on UNUSEDSIGNAL */
