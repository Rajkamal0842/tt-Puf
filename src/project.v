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

  wire ro_en;

  // 32 shift-register ROs — depths 3 to 17, all unique feedback
  (* keep = "true" *) reg [2:0]  ro0;
  (* keep = "true" *) reg [3:0]  ro1;
  (* keep = "true" *) reg [4:0]  ro2;
  (* keep = "true" *) reg [4:0]  ro3;
  (* keep = "true" *) reg [5:0]  ro4;
  (* keep = "true" *) reg [5:0]  ro5;
  (* keep = "true" *) reg [6:0]  ro6;
  (* keep = "true" *) reg [6:0]  ro7;
  (* keep = "true" *) reg [7:0]  ro8;
  (* keep = "true" *) reg [7:0]  ro9;
  (* keep = "true" *) reg [8:0]  ro10;
  (* keep = "true" *) reg [8:0]  ro11;
  (* keep = "true" *) reg [9:0]  ro12;
  (* keep = "true" *) reg [9:0]  ro13;
  (* keep = "true" *) reg [10:0] ro14;
  (* keep = "true" *) reg [10:0] ro15;
  (* keep = "true" *) reg [11:0] ro16;
  (* keep = "true" *) reg [11:0] ro17;
  (* keep = "true" *) reg [12:0] ro18;
  (* keep = "true" *) reg [12:0] ro19;
  (* keep = "true" *) reg [13:0] ro20;
  (* keep = "true" *) reg [13:0] ro21;
  (* keep = "true" *) reg [14:0] ro22;
  (* keep = "true" *) reg [14:0] ro23;
  (* keep = "true" *) reg [15:0] ro24;
  (* keep = "true" *) reg [15:0] ro25;
  (* keep = "true" *) reg [16:0] ro26;
  (* keep = "true" *) reg [16:0] ro27;
  (* keep = "true" *) reg [15:0] ro28;
  (* keep = "true" *) reg [15:0] ro29;
  (* keep = "true" *) reg [14:0] ro30;
  (* keep = "true" *) reg [13:0] ro31;

  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro0  <= 3'h1;  else if (ro_en) ro0  <= {ro0[1:0],  ro0[2]^ro0[1]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro1  <= 4'h1;  else if (ro_en) ro1  <= {ro1[2:0],  ro1[3]^ro1[2]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro2  <= 5'h1;  else if (ro_en) ro2  <= {ro2[3:0],  ro2[4]^ro2[2]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro3  <= 5'h2;  else if (ro_en) ro3  <= {ro3[3:0],  ro3[4]^ro3[3]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro4  <= 6'h1;  else if (ro_en) ro4  <= {ro4[4:0],  ro4[5]^ro4[4]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro5  <= 6'h2;  else if (ro_en) ro5  <= {ro5[4:0],  ro5[5]^ro5[0]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro6  <= 7'h1;  else if (ro_en) ro6  <= {ro6[5:0],  ro6[6]^ro6[5]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro7  <= 7'h2;  else if (ro_en) ro7  <= {ro7[5:0],  ro7[6]^ro7[3]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro8  <= 8'h1;  else if (ro_en) ro8  <= {ro8[6:0],  ro8[7]^ro8[5]^ro8[4]^ro8[3]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro9  <= 8'h2;  else if (ro_en) ro9  <= {ro9[6:0],  ro9[7]^ro9[4]^ro9[3]^ro9[2]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro10 <= 9'h1;  else if (ro_en) ro10 <= {ro10[7:0], ro10[8]^ro10[4]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro11 <= 9'h2;  else if (ro_en) ro11 <= {ro11[7:0], ro11[8]^ro11[3]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro12 <= 10'h1; else if (ro_en) ro12 <= {ro12[8:0], ro12[9]^ro12[6]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro13 <= 10'h2; else if (ro_en) ro13 <= {ro13[8:0], ro13[9]^ro13[1]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro14 <= 11'h1; else if (ro_en) ro14 <= {ro14[9:0], ro14[10]^ro14[8]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro15 <= 11'h2; else if (ro_en) ro15 <= {ro15[9:0], ro15[10]^ro15[2]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro16 <= 12'h1; else if (ro_en) ro16 <= {ro16[10:0],ro16[11]^ro16[10]^ro16[9]^ro16[3]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro17 <= 12'h2; else if (ro_en) ro17 <= {ro17[10:0],ro17[11]^ro17[5]^ro17[3]^ro17[0]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro18 <= 13'h1; else if (ro_en) ro18 <= {ro18[11:0],ro18[12]^ro18[11]^ro18[10]^ro18[7]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro19 <= 13'h2; else if (ro_en) ro19 <= {ro19[11:0],ro19[12]^ro19[3]^ro19[2]^ro19[1]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro20 <= 14'h1; else if (ro_en) ro20 <= {ro20[12:0],ro20[13]^ro20[12]^ro20[11]^ro20[1]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro21 <= 14'h2; else if (ro_en) ro21 <= {ro21[12:0],ro21[13]^ro21[4]^ro21[2]^ro21[0]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro22 <= 15'h1; else if (ro_en) ro22 <= {ro22[13:0],ro22[14]^ro22[13]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro23 <= 15'h2; else if (ro_en) ro23 <= {ro23[13:0],ro23[14]^ro23[5]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro24 <= 16'h1; else if (ro_en) ro24 <= {ro24[14:0],ro24[15]^ro24[14]^ro24[12]^ro24[3]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro25 <= 16'h2; else if (ro_en) ro25 <= {ro25[14:0],ro25[15]^ro25[6]^ro25[4]^ro25[0]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro26 <= 17'h1; else if (ro_en) ro26 <= {ro26[15:0],ro26[16]^ro26[13]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro27 <= 17'h2; else if (ro_en) ro27 <= {ro27[15:0],ro27[16]^ro27[7]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro28 <= 16'h3; else if (ro_en) ro28 <= {ro28[14:0],ro28[15]^ro28[13]^ro28[4]^ro28[0]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro29 <= 16'h4; else if (ro_en) ro29 <= {ro29[14:0],ro29[15]^ro29[11]^ro29[2]^ro29[1]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro30 <= 15'h3; else if (ro_en) ro30 <= {ro30[13:0],ro30[14]^ro30[10]^ro30[4]^ro30[0]}; end
  always @(posedge clk or negedge rst_n) begin if (!rst_n) ro31 <= 14'h3; else if (ro_en) ro31 <= {ro31[12:0],ro31[13]^ro31[9]^ro31[6]^ro31[0]}; end

  // 32 toggle flip-flops
  (* keep = "true" *) reg [31:0] tog;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) tog <= 32'b0;
    else if (ro_en) begin
      tog[0]  <= tog[0]  ^ ro0[0];   tog[1]  <= tog[1]  ^ ro1[0];
      tog[2]  <= tog[2]  ^ ro2[0];   tog[3]  <= tog[3]  ^ ro3[0];
      tog[4]  <= tog[4]  ^ ro4[0];   tog[5]  <= tog[5]  ^ ro5[0];
      tog[6]  <= tog[6]  ^ ro6[0];   tog[7]  <= tog[7]  ^ ro7[0];
      tog[8]  <= tog[8]  ^ ro8[0];   tog[9]  <= tog[9]  ^ ro9[0];
      tog[10] <= tog[10] ^ ro10[0];  tog[11] <= tog[11] ^ ro11[0];
      tog[12] <= tog[12] ^ ro12[0];  tog[13] <= tog[13] ^ ro13[0];
      tog[14] <= tog[14] ^ ro14[0];  tog[15] <= tog[15] ^ ro15[0];
      tog[16] <= tog[16] ^ ro16[0];  tog[17] <= tog[17] ^ ro17[0];
      tog[18] <= tog[18] ^ ro18[0];  tog[19] <= tog[19] ^ ro19[0];
      tog[20] <= tog[20] ^ ro20[0];  tog[21] <= tog[21] ^ ro21[0];
      tog[22] <= tog[22] ^ ro22[0];  tog[23] <= tog[23] ^ ro23[0];
      tog[24] <= tog[24] ^ ro24[0];  tog[25] <= tog[25] ^ ro25[0];
      tog[26] <= tog[26] ^ ro26[0];  tog[27] <= tog[27] ^ ro27[0];
      tog[28] <= tog[28] ^ ro28[0];  tog[29] <= tog[29] ^ ro29[0];
      tog[30] <= tog[30] ^ ro30[0];  tog[31] <= tog[31] ^ ro31[0];
    end
  end

  // 8 x 16-bit counter pairs
  (* keep = "true" *) reg [15:0] cntA0,cntA1,cntA2,cntA3,cntA4,cntA5,cntA6,cntA7;
  (* keep = "true" *) reg [15:0] cntB0,cntB1,cntB2,cntB3,cntB4,cntB5,cntB6,cntB7;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cntA0<=0;cntA1<=0;cntA2<=0;cntA3<=0;
      cntA4<=0;cntA5<=0;cntA6<=0;cntA7<=0;
      cntB0<=0;cntB1<=0;cntB2<=0;cntB3<=0;
      cntB4<=0;cntB5<=0;cntB6<=0;cntB7<=0;
    end else if (ro_en) begin
      if (tog[0])  cntA0 <= cntA0+1; if (tog[1])  cntB0 <= cntB0+1;
      if (tog[2])  cntA1 <= cntA1+1; if (tog[3])  cntB1 <= cntB1+1;
      if (tog[4])  cntA2 <= cntA2+1; if (tog[5])  cntB2 <= cntB2+1;
      if (tog[6])  cntA3 <= cntA3+1; if (tog[7])  cntB3 <= cntB3+1;
      if (tog[8])  cntA4 <= cntA4+1; if (tog[9])  cntB4 <= cntB4+1;
      if (tog[10]) cntA5 <= cntA5+1; if (tog[11]) cntB5 <= cntB5+1;
      if (tog[12]) cntA6 <= cntA6+1; if (tog[13]) cntB6 <= cntB6+1;
      if (tog[14]) cntA7 <= cntA7+1; if (tog[15]) cntB7 <= cntB7+1;
    end
  end

  // 32-bit Galois LFSR
  (* keep = "true" *) reg [31:0] lfsr;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) lfsr <= 32'hACE12345;
    else lfsr <= {1'b0,lfsr[31:1]} ^ (lfsr[0] ? 32'h80000062 : 32'h0);
  end

  // 16-bit LFSR
  (* keep = "true" *) reg [15:0] lfsr16;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) lfsr16 <= 16'hACE1;
    else lfsr16 <= {1'b0,lfsr16[15:1]} ^ (lfsr16[0] ? 16'hB400 : 16'h0);
  end

  // CRC-32
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
    if (!rst_n) crc32 <= 32'hFFFFFFFF;
    else crc32 <= crc32_next;
  end

  // CRC-16
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

  // Hamming weight — explicit adder tree to avoid WIDTHEXPAND warnings
  wire [1:0] h1a = {1'b0,tog[0]}+{1'b0,tog[1]};
  wire [1:0] h1b = {1'b0,tog[2]}+{1'b0,tog[3]};
  wire [1:0] h1c = {1'b0,tog[4]}+{1'b0,tog[5]};
  wire [1:0] h1d = {1'b0,tog[6]}+{1'b0,tog[7]};
  wire [1:0] h1e = {1'b0,tog[8]}+{1'b0,tog[9]};
  wire [1:0] h1f = {1'b0,tog[10]}+{1'b0,tog[11]};
  wire [1:0] h1g = {1'b0,tog[12]}+{1'b0,tog[13]};
  wire [1:0] h1h = {1'b0,tog[14]}+{1'b0,tog[15]};
  wire [2:0] h2a = {1'b0,h1a}+{1'b0,h1b};
  wire [2:0] h2b = {1'b0,h1c}+{1'b0,h1d};
  wire [2:0] h2c = {1'b0,h1e}+{1'b0,h1f};
  wire [2:0] h2d = {1'b0,h1g}+{1'b0,h1h};
  wire [3:0] h3a = {1'b0,h2a}+{1'b0,h2b};
  wire [3:0] h3b = {1'b0,h2c}+{1'b0,h2d};
  wire [4:0] ham1 = {1'b0,h3a}+{1'b0,h3b};

  wire [1:0] h1i = {1'b0,tog[16]}+{1'b0,tog[17]};
  wire [1:0] h1j = {1'b0,tog[18]}+{1'b0,tog[19]};
  wire [1:0] h1k = {1'b0,tog[20]}+{1'b0,tog[21]};
  wire [1:0] h1l = {1'b0,tog[22]}+{1'b0,tog[23]};
  wire [1:0] h1m = {1'b0,tog[24]}+{1'b0,tog[25]};
  wire [1:0] h1n = {1'b0,tog[26]}+{1'b0,tog[27]};
  wire [1:0] h1o = {1'b0,tog[28]}+{1'b0,tog[29]};
  wire [1:0] h1p = {1'b0,tog[30]}+{1'b0,tog[31]};
  wire [2:0] h2e = {1'b0,h1i}+{1'b0,h1j};
  wire [2:0] h2f = {1'b0,h1k}+{1'b0,h1l};
  wire [2:0] h2g = {1'b0,h1m}+{1'b0,h1n};
  wire [2:0] h2h = {1'b0,h1o}+{1'b0,h1p};
  wire [3:0] h3c = {1'b0,h2e}+{1'b0,h2f};
  wire [3:0] h3d = {1'b0,h2g}+{1'b0,h2h};
  wire [4:0] ham2 = {1'b0,h3c}+{1'b0,h3d};

  // Pipeline registers
  (* keep = "true" *) reg [7:0] pipe1,pipe2,pipe3,pipe4;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin pipe1<=0; pipe2<=0; pipe3<=0; pipe4<=0; end
    else begin
      pipe1 <= crc32[7:0]  ^ tog[7:0];
      pipe2 <= crc32[15:8] ^ lfsr[7:0];
      pipe3 <= crc16[7:0]  ^ tog[15:8];
      pipe4 <= {ham1[4:0],ham2[2:0]} ^ lfsr16[7:0];
    end
  end

  // FSM — auto-starts on reset release
  localparam S_IDLE = 2'd0;
  localparam S_EVAL = 2'd1;
  localparam S_DONE = 2'd2;

  reg [1:0]  state;
  reg [9:0]  eval_cnt;
  reg        response;
  reg        done;

  assign ro_en = (state == S_EVAL);

  wire [2:0] sel = ui_in[2:0];
  wire [15:0] selA = (sel==3'd0)?cntA0:(sel==3'd1)?cntA1:(sel==3'd2)?cntA2:(sel==3'd3)?cntA3:
                     (sel==3'd4)?cntA4:(sel==3'd5)?cntA5:(sel==3'd6)?cntA6:cntA7;
  wire [15:0] selB = (sel==3'd0)?cntB0:(sel==3'd1)?cntB1:(sel==3'd2)?cntB2:(sel==3'd3)?cntB3:
                     (sel==3'd4)?cntB4:(sel==3'd5)?cntB5:(sel==3'd6)?cntB6:cntB7;
  wire [7:0] debug_out = selA[7:0] ^ selB[7:0] ^ pipe1 ^ crc32[7:0];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S_IDLE; eval_cnt <= 10'd0;
      response <= 1'b0; done <= 1'b0;
    end else begin
      case (state)
        S_IDLE: begin
          done <= 1'b0;
          state <= S_EVAL;
          eval_cnt <= 10'd0;
        end
        S_EVAL: begin
          eval_cnt <= eval_cnt + 10'd1;
          if (eval_cnt == 10'd1022) state <= S_DONE;
        end
        S_DONE: begin
          response <= crc32[0]^crc16[0]^ham1[0]^ham2[0]^
                      pipe1[0]^pipe2[0]^pipe3[0]^pipe4[0];
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
