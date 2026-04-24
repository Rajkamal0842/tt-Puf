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

  // ----------------------------------------------------------------
  // 32 shift-register ring oscillators, each different depth+feedback
  // Using only 1-bit regs to avoid bit-width errors
  // ----------------------------------------------------------------
  (* keep = "true" *) reg [2:0]  ro0;
  (* keep = "true" *) reg [4:0]  ro1;
  (* keep = "true" *) reg [6:0]  ro2;
  (* keep = "true" *) reg [8:0]  ro3;
  (* keep = "true" *) reg [10:0] ro4;
  (* keep = "true" *) reg [12:0] ro5;
  (* keep = "true" *) reg [14:0] ro6;
  (* keep = "true" *) reg [16:0] ro7;
  (* keep = "true" *) reg [18:0] ro8;
  (* keep = "true" *) reg [20:0] ro9;
  (* keep = "true" *) reg [22:0] ro10;
  (* keep = "true" *) reg [24:0] ro11;
  (* keep = "true" *) reg [26:0] ro12;
  (* keep = "true" *) reg [28:0] ro13;
  (* keep = "true" *) reg [30:0] ro14;
  (* keep = "true" *) reg [32:0] ro15;
  (* keep = "true" *) reg [34:0] ro16;
  (* keep = "true" *) reg [36:0] ro17;
  (* keep = "true" *) reg [38:0] ro18;
  (* keep = "true" *) reg [40:0] ro19;
  (* keep = "true" *) reg [42:0] ro20;
  (* keep = "true" *) reg [44:0] ro21;
  (* keep = "true" *) reg [46:0] ro22;
  (* keep = "true" *) reg [48:0] ro23;
  (* keep = "true" *) reg [50:0] ro24;
  (* keep = "true" *) reg [52:0] ro25;
  (* keep = "true" *) reg [54:0] ro26;
  (* keep = "true" *) reg [56:0] ro27;
  (* keep = "true" *) reg [58:0] ro28;
  (* keep = "true" *) reg [60:0] ro29;
  (* keep = "true" *) reg [62:0] ro30;
  (* keep = "true" *) reg [63:0] ro31;

  wire ro_en;

  // Each RO shifts and feeds back with unique XOR tap
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro0 <= 3'b001;
    else if (ro_en) ro0 <= {ro0[1:0], ro0[2] ^ ro0[1]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro1 <= 5'b00001;
    else if (ro_en) ro1 <= {ro1[3:0], ro1[4] ^ ro1[2]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro2 <= 7'b0000001;
    else if (ro_en) ro2 <= {ro2[5:0], ro2[6] ^ ro2[5]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro3 <= 9'b000000001;
    else if (ro_en) ro3 <= {ro3[7:0], ro3[8] ^ ro3[4]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro4 <= 11'b00000000001;
    else if (ro_en) ro4 <= {ro4[9:0], ro4[10] ^ ro4[8]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro5 <= 13'b0000000000001;
    else if (ro_en) ro5 <= {ro5[11:0], ro5[12] ^ ro5[11]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro6 <= 15'b000000000000001;
    else if (ro_en) ro6 <= {ro6[13:0], ro6[14] ^ ro6[13]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro7 <= 17'b00000000000000001;
    else if (ro_en) ro7 <= {ro7[15:0], ro7[16] ^ ro7[13]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro8 <= 19'b0000000000000000001;
    else if (ro_en) ro8 <= {ro8[17:0], ro8[18] ^ ro8[17] ^ ro8[16] ^ ro8[13]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro9 <= 21'b000000000000000000001;
    else if (ro_en) ro9 <= {ro9[19:0], ro9[20] ^ ro9[18]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro10 <= 23'b00000000000000000000001;
    else if (ro_en) ro10 <= {ro10[21:0], ro10[22] ^ ro10[20]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro11 <= 25'b0000000000000000000000001;
    else if (ro_en) ro11 <= {ro11[23:0], ro11[24] ^ ro11[21]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro12 <= 27'b000000000000000000000000001;
    else if (ro_en) ro12 <= {ro12[25:0], ro12[26] ^ ro12[24] ^ ro12[1] ^ ro12[0]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro13 <= 29'b00000000000000000000000000001;
    else if (ro_en) ro13 <= {ro13[27:0], ro13[28] ^ ro13[26]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro14 <= 31'b0000000000000000000000000000001;
    else if (ro_en) ro14 <= {ro14[29:0], ro14[30] ^ ro14[27]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro15 <= 33'b000000000000000000000000000000001;
    else if (ro_en) ro15 <= {ro15[31:0], ro15[32] ^ ro15[19]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro16 <= 35'b00000000000000000000000000000000001;
    else if (ro_en) ro16 <= {ro16[33:0], ro16[34] ^ ro16[32]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro17 <= 37'b0000000000000000000000000000000000001;
    else if (ro_en) ro17 <= {ro17[35:0], ro17[36] ^ ro17[34] ^ ro17[1] ^ ro17[0]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro18 <= 39'b000000000000000000000000000000000000001;
    else if (ro_en) ro18 <= {ro18[37:0], ro18[38] ^ ro18[34]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro19 <= 41'b00000000000000000000000000000000000000001;
    else if (ro_en) ro19 <= {ro19[39:0], ro19[40] ^ ro19[37]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro20 <= 43'b0000000000000000000000000000000000000000001;
    else if (ro_en) ro20 <= {ro20[41:0], ro20[42] ^ ro20[41] ^ ro20[37] ^ ro20[36]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro21 <= 45'b000000000000000000000000000000000000000000001;
    else if (ro_en) ro21 <= {ro21[43:0], ro21[44] ^ ro21[42] ^ ro21[1] ^ ro21[0]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro22 <= 47'b00000000000000000000000000000000000000000000001;
    else if (ro_en) ro22 <= {ro22[45:0], ro22[46] ^ ro22[42]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro23 <= 49'b0000000000000000000000000000000000000000000000001;
    else if (ro_en) ro23 <= {ro23[47:0], ro23[48] ^ ro23[39]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro24 <= 51'b000000000000000000000000000000000000000000000000001;
    else if (ro_en) ro24 <= {ro24[49:0], ro24[50] ^ ro24[48] ^ ro24[35] ^ ro24[33]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro25 <= 53'b00000000000000000000000000000000000000000000000000001;
    else if (ro_en) ro25 <= {ro25[51:0], ro25[52] ^ ro25[51]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro26 <= 55'b0000000000000000000000000000000000000000000000000000001;
    else if (ro_en) ro26 <= {ro26[53:0], ro26[54] ^ ro26[30]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro27 <= 57'b000000000000000000000000000000000000000000000000000000001;
    else if (ro_en) ro27 <= {ro27[55:0], ro27[56] ^ ro27[49]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro28 <= 59'b00000000000000000000000000000000000000000000000000000000001;
    else if (ro_en) ro28 <= {ro28[57:0], ro28[58] ^ ro28[57] ^ ro28[54] ^ ro28[53]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro29 <= 61'b0000000000000000000000000000000000000000000000000000000000001;
    else if (ro_en) ro29 <= {ro29[59:0], ro29[60] ^ ro29[45]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro30 <= 63'b000000000000000000000000000000000000000000000000000000000000001;
    else if (ro_en) ro30 <= {ro30[61:0], ro30[62] ^ ro30[61]};
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro31 <= 64'h0000000000000001;
    else if (ro_en) ro31 <= {ro31[62:0], ro31[63] ^ ro31[62] ^ ro31[60] ^ ro31[59]};
  end

  // 32 toggle flip-flops — one per RO output bit
  (* keep = "true" *) reg [31:0] tog;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) tog <= 32'b0;
    else if (ro_en) begin
      tog[0]  <= tog[0]  ^ ro0[0];
      tog[1]  <= tog[1]  ^ ro1[0];
      tog[2]  <= tog[2]  ^ ro2[0];
      tog[3]  <= tog[3]  ^ ro3[0];
      tog[4]  <= tog[4]  ^ ro4[0];
      tog[5]  <= tog[5]  ^ ro5[0];
      tog[6]  <= tog[6]  ^ ro6[0];
      tog[7]  <= tog[7]  ^ ro7[0];
      tog[8]  <= tog[8]  ^ ro8[0];
      tog[9]  <= tog[9]  ^ ro9[0];
      tog[10] <= tog[10] ^ ro10[0];
      tog[11] <= tog[11] ^ ro11[0];
      tog[12] <= tog[12] ^ ro12[0];
      tog[13] <= tog[13] ^ ro13[0];
      tog[14] <= tog[14] ^ ro14[0];
      tog[15] <= tog[15] ^ ro15[0];
      tog[16] <= tog[16] ^ ro16[0];
      tog[17] <= tog[17] ^ ro17[0];
      tog[18] <= tog[18] ^ ro18[0];
      tog[19] <= tog[19] ^ ro19[0];
      tog[20] <= tog[20] ^ ro20[0];
      tog[21] <= tog[21] ^ ro21[0];
      tog[22] <= tog[22] ^ ro22[0];
      tog[23] <= tog[23] ^ ro23[0];
      tog[24] <= tog[24] ^ ro24[0];
      tog[25] <= tog[25] ^ ro25[0];
      tog[26] <= tog[26] ^ ro26[0];
      tog[27] <= tog[27] ^ ro27[0];
      tog[28] <= tog[28] ^ ro28[0];
      tog[29] <= tog[29] ^ ro29[0];
      tog[30] <= tog[30] ^ ro30[0];
      tog[31] <= tog[31] ^ ro31[0];
    end
  end

  // 8 x 16-bit counter pairs
  (* keep = "true" *) reg [15:0] cntA [0:7];
  (* keep = "true" *) reg [15:0] cntB [0:7];

  integer i;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cntA[0]<=0; cntA[1]<=0; cntA[2]<=0; cntA[3]<=0;
      cntA[4]<=0; cntA[5]<=0; cntA[6]<=0; cntA[7]<=0;
      cntB[0]<=0; cntB[1]<=0; cntB[2]<=0; cntB[3]<=0;
      cntB[4]<=0; cntB[5]<=0; cntB[6]<=0; cntB[7]<=0;
    end else if (ro_en) begin
      if (tog[0])  cntA[0] <= cntA[0] + 1;
      if (tog[1])  cntB[0] <= cntB[0] + 1;
      if (tog[2])  cntA[1] <= cntA[1] + 1;
      if (tog[3])  cntB[1] <= cntB[1] + 1;
      if (tog[4])  cntA[2] <= cntA[2] + 1;
      if (tog[5])  cntB[2] <= cntB[2] + 1;
      if (tog[6])  cntA[3] <= cntA[3] + 1;
      if (tog[7])  cntB[3] <= cntB[3] + 1;
      if (tog[8])  cntA[4] <= cntA[4] + 1;
      if (tog[9])  cntB[4] <= cntB[4] + 1;
      if (tog[10]) cntA[5] <= cntA[5] + 1;
      if (tog[11]) cntB[5] <= cntB[5] + 1;
      if (tog[12]) cntA[6] <= cntA[6] + 1;
      if (tog[13]) cntB[6] <= cntB[6] + 1;
      if (tog[14]) cntA[7] <= cntA[7] + 1;
      if (tog[15]) cntB[7] <= cntB[7] + 1;
    end
  end

  // 32-bit Galois LFSR
  (* keep = "true" *) reg [31:0] lfsr;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) lfsr <= 32'hACE1_2345;
    else lfsr <= {1'b0, lfsr[31:1]} ^ (lfsr[0] ? 32'h8000_0062 : 32'h0);
  end

  // 16-bit LFSR
  (* keep = "true" *) reg [15:0] lfsr16;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) lfsr16 <= 16'hACE1;
    else lfsr16 <= {1'b0, lfsr16[15:1]} ^ (lfsr16[0] ? 16'hB400 : 16'h0);
  end

  // CRC-32 over tog[7:0] XOR lfsr[7:0]
  (* keep = "true" *) reg [31:0] crc32;
  wire [7:0] crc_in = tog[7:0] ^ lfsr[7:0];
  wire [31:0] crc32_next;

  assign crc32_next[0]  = crc32[24]^crc32[30]^crc_in[0]^crc_in[6];
  assign crc32_next[1]  = crc32[24]^crc32[25]^crc32[30]^crc32[31]^crc_in[0]^crc_in[1]^crc_in[6]^crc_in[7];
  assign crc32_next[2]  = crc32[24]^crc32[25]^crc32[26]^crc32[30]^crc32[31]^crc_in[0]^crc_in[1]^crc_in[2]^crc_in[6]^crc_in[7];
  assign crc32_next[3]  = crc32[25]^crc32[26]^crc32[27]^crc32[31]^crc_in[1]^crc_in[2]^crc_in[3]^crc_in[7];
  assign crc32_next[4]  = crc32[24]^crc32[26]^crc32[27]^crc32[28]^crc32[30]^crc_in[0]^crc_in[2]^crc_in[3]^crc_in[4]^crc_in[6];
  assign crc32_next[5]  = crc32[24]^crc32[25]^crc32[27]^crc32[28]^crc32[29]^crc32[30]^crc32[31]^crc_in[0]^crc_in[1]^crc_in[3]^crc_in[4]^crc_in[5]^crc_in[6]^crc_in[7];
  assign crc32_next[6]  = crc32[25]^crc32[26]^crc32[28]^crc32[29]^crc32[30]^crc32[31]^crc_in[1]^crc_in[2]^crc_in[4]^crc_in[5]^crc_in[6]^crc_in[7];
  assign crc32_next[7]  = crc32[24]^crc32[26]^crc32[27]^crc32[29]^crc32[31]^crc_in[0]^crc_in[2]^crc_in[3]^crc_in[5]^crc_in[7];
  assign crc32_next[8]  = crc32[0]^crc32[24]^crc32[25]^crc32[27]^crc32[28]^crc_in[0]^crc_in[1]^crc_in[3]^crc_in[4];
  assign crc32_next[9]  = crc32[1]^crc32[25]^crc32[26]^crc32[28]^crc32[29]^crc_in[1]^crc_in[2]^crc_in[4]^crc_in[5];
  assign crc32_next[10] = crc32[2]^crc32[24]^crc32[26]^crc32[27]^crc32[29]^crc_in[0]^crc_in[2]^crc_in[3]^crc_in[5];
  assign crc32_next[11] = crc32[3]^crc32[24]^crc32[25]^crc32[27]^crc32[28]^crc_in[0]^crc_in[1]^crc_in[3]^crc_in[4];
  assign crc32_next[12] = crc32[4]^crc32[24]^crc32[25]^crc32[26]^crc32[28]^crc32[29]^crc32[30]^crc_in[0]^crc_in[1]^crc_in[2]^crc_in[4]^crc_in[5]^crc_in[6];
  assign crc32_next[13] = crc32[5]^crc32[25]^crc32[26]^crc32[27]^crc32[29]^crc32[30]^crc32[31]^crc_in[1]^crc_in[2]^crc_in[3]^crc_in[5]^crc_in[6]^crc_in[7];
  assign crc32_next[14] = crc32[6]^crc32[26]^crc32[27]^crc32[28]^crc32[30]^crc32[31]^crc_in[2]^crc_in[3]^crc_in[4]^crc_in[6]^crc_in[7];
  assign crc32_next[15] = crc32[7]^crc32[27]^crc32[28]^crc32[29]^crc32[31]^crc_in[3]^crc_in[4]^crc_in[5]^crc_in[7];
  assign crc32_next[16] = crc32[8]^crc32[24]^crc32[28]^crc32[29]^crc_in[0]^crc_in[4]^crc_in[5];
  assign crc32_next[17] = crc32[9]^crc32[25]^crc32[29]^crc32[30]^crc_in[1]^crc_in[5]^crc_in[6];
  assign crc32_next[18] = crc32[10]^crc32[26]^crc32[30]^crc32[31]^crc_in[2]^crc_in[6]^crc_in[7];
  assign crc32_next[19] = crc32[11]^crc32[27]^crc32[31]^crc_in[3]^crc_in[7];
  assign crc32_next[20] = crc32[12]^crc32[28]^crc_in[4];
  assign crc32_next[21] = crc32[13]^crc32[29]^crc_in[5];
  assign crc32_next[22] = crc32[14]^crc32[24]^crc_in[0];
  assign crc32_next[23] = crc32[15]^crc32[24]^crc32[25]^crc32[30]^crc_in[0]^crc_in[1]^crc_in[6];
  assign crc32_next[24] = crc32[16]^crc32[25]^crc32[26]^crc32[31]^crc_in[1]^crc_in[2]^crc_in[7];
  assign crc32_next[25] = crc32[17]^crc32[26]^crc32[27]^crc_in[2]^crc_in[3];
  assign crc32_next[26] = crc32[18]^crc32[24]^crc32[27]^crc32[28]^crc32[30]^crc_in[0]^crc_in[3]^crc_in[4]^crc_in[6];
  assign crc32_next[27] = crc32[19]^crc32[25]^crc32[28]^crc32[29]^crc32[31]^crc_in[1]^crc_in[4]^crc_in[5]^crc_in[7];
  assign crc32_next[28] = crc32[20]^crc32[26]^crc32[29]^crc32[30]^crc_in[2]^crc_in[5]^crc_in[6];
  assign crc32_next[29] = crc32[21]^crc32[27]^crc32[30]^crc32[31]^crc_in[3]^crc_in[6]^crc_in[7];
  assign crc32_next[30] = crc32[22]^crc32[28]^crc32[31]^crc_in[4]^crc_in[7];
  assign crc32_next[31] = crc32[23]^crc32[29]^crc_in[5];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) crc32 <= 32'hFFFF_FFFF;
    else crc32 <= crc32_next;
  end

  // CRC-16 over tog[15:8] XOR lfsr16[7:0]
  (* keep = "true" *) reg [15:0] crc16;
  wire [7:0] crc16_in = tog[15:8] ^ lfsr16[7:0];
  wire [15:0] crc16_next;

  assign crc16_next[0]  = crc16[8]^crc16[12]^crc16_in[0]^crc16_in[4];
  assign crc16_next[1]  = crc16[9]^crc16[13]^crc16_in[1]^crc16_in[5];
  assign crc16_next[2]  = crc16[10]^crc16[14]^crc16_in[2]^crc16_in[6];
  assign crc16_next[3]  = crc16[11]^crc16[15]^crc16_in[3]^crc16_in[7];
  assign crc16_next[4]  = crc16[12]^crc16_in[4];
  assign crc16_next[5]  = crc16[13]^crc16_in[5];
  assign crc16_next[6]  = crc16[14]^crc16_in[6];
  assign crc16_next[7]  = crc16[15]^crc16_in[7];
  assign crc16_next[8]  = crc16[0];
  assign crc16_next[9]  = crc16[1];
  assign crc16_next[10] = crc16[2];
  assign crc16_next[11] = crc16[3];
  assign crc16_next[12] = crc16[4]^crc16[8]^crc16[12]^crc16_in[0]^crc16_in[4];
  assign crc16_next[13] = crc16[5]^crc16[9]^crc16[13]^crc16_in[1]^crc16_in[5];
  assign crc16_next[14] = crc16[6]^crc16[10]^crc16[14]^crc16_in[2]^crc16_in[6];
  assign crc16_next[15] = crc16[7]^crc16[11]^crc16[15]^crc16_in[3]^crc16_in[7];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) crc16 <= 16'hFFFF;
    else crc16 <= crc16_next;
  end

  // Hamming weight trees
  wire [4:0] ham1 = tog[0]+tog[1]+tog[2]+tog[3]+tog[4]+tog[5]+tog[6]+tog[7]+
                    tog[8]+tog[9]+tog[10]+tog[11]+tog[12]+tog[13]+tog[14]+tog[15];
  wire [4:0] ham2 = tog[16]+tog[17]+tog[18]+tog[19]+tog[20]+tog[21]+tog[22]+tog[23]+
                    tog[24]+tog[25]+tog[26]+tog[27]+tog[28]+tog[29]+tog[30]+tog[31];

  // Pipeline registers
  (* keep = "true" *) reg [7:0] pipe1, pipe2, pipe3, pipe4;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pipe1 <= 8'h0; pipe2 <= 8'h0; pipe3 <= 8'h0; pipe4 <= 8'h0;
    end else begin
      pipe1 <= crc32[7:0]   ^ tog[7:0];
      pipe2 <= crc32[15:8]  ^ lfsr[7:0];
      pipe3 <= crc16[7:0]   ^ tog[15:8];
      pipe4 <= {ham1[4:0], ham2[2:0]} ^ lfsr16[7:0];
    end
  end

  // FSM
  localparam S_IDLE = 2'd0;
  localparam S_EVAL = 2'd1;
  localparam S_DONE = 2'd2;

  reg [1:0]  state;
  reg [9:0]  eval_cnt;
  reg        response;
  reg        done;

  assign ro_en = (state == S_EVAL);

  // Challenge mux for debug output
  wire [2:0] sel = ui_in[2:0];
  wire [15:0] selA = cntA[sel];
  wire [15:0] selB = cntB[sel];
  wire [7:0]  debug_out = (selA ^ selB ^ pipe1 ^ crc32[7:0]) & 8'hFC;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state    <= S_IDLE;
      eval_cnt <= 10'd0;
      response <= 1'b0;
      done     <= 1'b0;
    end else begin
      case (state)
        S_IDLE: begin
          done <= 1'b0;
          state    <= S_EVAL;
          eval_cnt <= 10'd0;
        end
        S_EVAL: begin
          eval_cnt <= eval_cnt + 10'd1;
          if (eval_cnt == 10'd1022) state <= S_DONE;
        end
        S_DONE: begin
          response <= crc32[0] ^ crc16[0] ^ ham1[0] ^ ham2[0] ^
                      pipe1[0] ^ pipe2[0] ^ pipe3[0] ^ pipe4[0];
          done     <= 1'b1;
          state    <= S_IDLE;
        end
        default: state <= S_IDLE;
      endcase
    end
  end

  assign uo_out[0]   = response;
  assign uo_out[1]   = done;
  assign uo_out[7:2] = debug_out[7:2];
  assign uio_out     = 8'b0;
  assign uio_oe      = 8'b0;

  wire _unused = &{ena, uio_in, 1'b0};

endmodule
