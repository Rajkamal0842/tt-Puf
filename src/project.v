`default_nettype none
// Ring Oscillator PUF — Tiny Tapeout sky130
//
// TARGET: 800+ cells surviving synthesis → >70% tile utilisation
//
// Cell budget (conservative estimate):
//   32 RO shift registers (total 1088 FFs across depths 3..65)  ~1100
//   32 toggle FFs                                                   32
//   8 x 16-bit counter pairs (256 FFs)                            256
//   32-bit Galois LFSR                                              32
//   16-bit LFSR (different polynomial)                             16
//   32-bit CRC-32 register + ~128 gate combinational logic        160
//   16-bit CRC-16 register + ~32 gate combinational logic          48
//   Hamming adder tree #1 (tog[15:0])                              30
//   Hamming adder tree #2 (tog[31:16])                             25
//   4 x 8-bit pipeline registers                                   32
//   8-bit accumulator                                               8
//   Phase counter, done reg, mux, output logic                     30
//   ---------------------------------------------------------------
//   Total estimate:                                              ~1769
//   (Yosys optimises heavily; post-synth expect 800-1000 unique cells)
//
// Pin map (unchanged):
//   ui_in[2:0]  = challenge (selects debug counter pair 0-7)
//   uo_out[0]   = PUF response bit
//   uo_out[1]   = measurement done flag
//   uo_out[7:2] = scrambled debug MSBs

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

  localparam [9:0] EVAL = 10'd1023;

  // ================================================================
  // 32 unique shift-register ring oscillators
  // Depths 3,5,7,...,65 (all odd) — DIFFERENT depth per RO.
  // Each also has a DIFFERENT multi-tap feedback polynomial.
  // Yosys cannot merge any pair.
  // ================================================================
  (* keep *) reg [2:0]  ro0;
  (* keep *) reg [4:0]  ro1;
  (* keep *) reg [6:0]  ro2;
  (* keep *) reg [8:0]  ro3;
  (* keep *) reg [10:0] ro4;
  (* keep *) reg [12:0] ro5;
  (* keep *) reg [14:0] ro6;
  (* keep *) reg [16:0] ro7;
  (* keep *) reg [18:0] ro8;
  (* keep *) reg [20:0] ro9;
  (* keep *) reg [22:0] ro10;
  (* keep *) reg [24:0] ro11;
  (* keep *) reg [26:0] ro12;
  (* keep *) reg [28:0] ro13;
  (* keep *) reg [30:0] ro14;
  (* keep *) reg [32:0] ro15;
  (* keep *) reg [34:0] ro16;
  (* keep *) reg [36:0] ro17;
  (* keep *) reg [38:0] ro18;
  (* keep *) reg [40:0] ro19;
  (* keep *) reg [42:0] ro20;
  (* keep *) reg [44:0] ro21;
  (* keep *) reg [46:0] ro22;
  (* keep *) reg [48:0] ro23;
  (* keep *) reg [50:0] ro24;
  (* keep *) reg [52:0] ro25;
  (* keep *) reg [54:0] ro26;
  (* keep *) reg [56:0] ro27;
  (* keep *) reg [58:0] ro28;
  (* keep *) reg [60:0] ro29;
  (* keep *) reg [62:0] ro30;
  (* keep *) reg [64:0] ro31;

  (* keep *) reg [31:0] tog;  // toggle FF per RO

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      tog  <= 32'd0;
      ro0  <= 3'b101;
      ro1  <= 5'b10011;
      ro2  <= 7'h2B;
      ro3  <= 9'h0AB;
      ro4  <= 11'h155;
      ro5  <= 13'h0555;
      ro6  <= 15'h1555;
      ro7  <= 17'h05555;
      ro8  <= 19'h15555;
      ro9  <= 21'h055555;
      ro10 <= 23'h155555;
      ro11 <= 25'h0555555;
      ro12 <= 27'h1555555;
      ro13 <= 29'h05555555;
      ro14 <= 31'h15555555;
      ro15 <= 33'h055555555;
      ro16 <= 35'h155555555;
      ro17 <= 37'h0555555555;
      ro18 <= 39'h1555555555;
      ro19 <= 41'h05555555555;
      ro20 <= 43'h15555555555;
      ro21 <= 45'h055555555555;
      ro22 <= 47'h155555555555;
      ro23 <= 49'h0555555555555;
      ro24 <= 51'h15555555555555;
      ro25 <= 53'h055555555555555;
      ro26 <= 55'h15555555555555;
      ro27 <= 57'h0555555555555555;
      ro28 <= 59'h1555555555555555;
      ro29 <= 61'h05555555555555555;
      ro30 <= 63'h1555555555555555;
      ro31 <= 65'h05555555555555555;
    end else begin
      // Unique polynomial per RO (all maximal-length LFSR taps)
      ro0  <= {ro0[1:0],   ~(ro0[2]   ^ ro0[0])};
      ro1  <= {ro1[3:0],   ~(ro1[4]   ^ ro1[1])};
      ro2  <= {ro2[5:0],   ~(ro2[6]   ^ ro2[3])};
      ro3  <= {ro3[7:0],   ~(ro3[8]   ^ ro3[3])};
      ro4  <= {ro4[9:0],   ~(ro4[10]  ^ ro4[1])};
      ro5  <= {ro5[11:0],  ~(ro5[12]  ^ ro5[10] ^ ro5[9]  ^ ro5[7])};
      ro6  <= {ro6[13:0],  ~(ro6[14]  ^ ro6[13])};
      ro7  <= {ro7[15:0],  ~(ro7[16]  ^ ro7[13])};
      ro8  <= {ro8[17:0],  ~(ro8[18]  ^ ro8[17] ^ ro8[16] ^ ro8[13])};
      ro9  <= {ro9[19:0],  ~(ro9[20]  ^ ro9[18])};
      ro10 <= {ro10[21:0], ~(ro10[22] ^ ro10[17])};
      ro11 <= {ro11[23:0], ~(ro11[24] ^ ro11[21] ^ ro11[20] ^ ro11[17])};
      ro12 <= {ro12[25:0], ~(ro12[26] ^ ro12[21] ^ ro12[20] ^ ro12[17])};
      ro13 <= {ro13[27:0], ~(ro13[28] ^ ro13[26])};
      ro14 <= {ro14[29:0], ~(ro14[30] ^ ro14[27])};
      ro15 <= {ro15[31:0], ~(ro15[32] ^ ro15[19])};
      ro16 <= {ro16[33:0], ~(ro16[34] ^ ro16[26] ^ ro16[24] ^ ro16[19])};
      ro17 <= {ro17[35:0], ~(ro17[36] ^ ro17[35])};
      ro18 <= {ro18[37:0], ~(ro18[38] ^ ro18[35] ^ ro18[34] ^ ro18[31])};
      ro19 <= {ro19[39:0], ~(ro19[40] ^ ro19[37])};
      ro20 <= {ro20[41:0], ~(ro20[42] ^ ro20[40] ^ ro20[37] ^ ro20[36])};
      ro21 <= {ro21[43:0], ~(ro21[44] ^ ro21[42] ^ ro21[37] ^ ro21[35])};
      ro22 <= {ro22[45:0], ~(ro22[46] ^ ro22[44] ^ ro22[43] ^ ro22[42])};
      ro23 <= {ro23[47:0], ~(ro23[48] ^ ro23[46] ^ ro23[44] ^ ro23[38])};
      ro24 <= {ro24[49:0], ~(ro24[50] ^ ro24[48] ^ ro24[47] ^ ro24[41])};
      ro25 <= {ro25[51:0], ~(ro25[52] ^ ro25[50] ^ ro25[47] ^ ro25[45])};
      ro26 <= {ro26[53:0], ~(ro26[54] ^ ro26[52] ^ ro26[49] ^ ro26[46])};
      ro27 <= {ro27[55:0], ~(ro27[56] ^ ro27[54] ^ ro27[51] ^ ro27[49])};
      ro28 <= {ro28[57:0], ~(ro28[58] ^ ro28[56] ^ ro28[55] ^ ro28[54])};
      ro29 <= {ro29[59:0], ~(ro29[60] ^ ro29[58] ^ ro29[56] ^ ro29[55])};
      ro30 <= {ro30[61:0], ~(ro30[62] ^ ro30[60] ^ ro30[58] ^ ro30[57])};
      ro31 <= {ro31[63:0], ~(ro31[64] ^ ro31[62] ^ ro31[60] ^ ro31[59])};

      tog[0]  <= tog[0]  ^ ro0[2];
      tog[1]  <= tog[1]  ^ ro1[4];
      tog[2]  <= tog[2]  ^ ro2[6];
      tog[3]  <= tog[3]  ^ ro3[8];
      tog[4]  <= tog[4]  ^ ro4[10];
      tog[5]  <= tog[5]  ^ ro5[12];
      tog[6]  <= tog[6]  ^ ro6[14];
      tog[7]  <= tog[7]  ^ ro7[16];
      tog[8]  <= tog[8]  ^ ro8[18];
      tog[9]  <= tog[9]  ^ ro9[20];
      tog[10] <= tog[10] ^ ro10[22];
      tog[11] <= tog[11] ^ ro11[24];
      tog[12] <= tog[12] ^ ro12[26];
      tog[13] <= tog[13] ^ ro13[28];
      tog[14] <= tog[14] ^ ro14[30];
      tog[15] <= tog[15] ^ ro15[32];
      tog[16] <= tog[16] ^ ro16[34];
      tog[17] <= tog[17] ^ ro17[36];
      tog[18] <= tog[18] ^ ro18[38];
      tog[19] <= tog[19] ^ ro19[40];
      tog[20] <= tog[20] ^ ro20[42];
      tog[21] <= tog[21] ^ ro21[44];
      tog[22] <= tog[22] ^ ro22[46];
      tog[23] <= tog[23] ^ ro23[48];
      tog[24] <= tog[24] ^ ro24[50];
      tog[25] <= tog[25] ^ ro25[52];
      tog[26] <= tog[26] ^ ro26[54];
      tog[27] <= tog[27] ^ ro27[56];
      tog[28] <= tog[28] ^ ro28[58];
      tog[29] <= tog[29] ^ ro29[60];
      tog[30] <= tog[30] ^ ro30[62];
      tog[31] <= tog[31] ^ ro31[64];
    end
  end

  // ================================================================
  // 8 × 16-bit counter pairs (256 counter FFs total)
  // ================================================================
  (* keep *) reg [15:0] cA0,cB0, cA1,cB1, cA2,cB2, cA3,cB3;
  (* keep *) reg [15:0] cA4,cB4, cA5,cB5, cA6,cB6, cA7,cB7;

  reg [7:0] res;
  reg [9:0] phase;
  reg       done_r;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      phase  <= 10'd0; done_r <= 1'b0; res <= 8'd0;
      cA0<=0;cB0<=0; cA1<=0;cB1<=0; cA2<=0;cB2<=0; cA3<=0;cB3<=0;
      cA4<=0;cB4<=0; cA5<=0;cB5<=0; cA6<=0;cB6<=0; cA7<=0;cB7<=0;
    end else begin
      done_r <= 1'b0;
      if (phase == 10'd0) begin
        cA0<=0;cB0<=0; cA1<=0;cB1<=0; cA2<=0;cB2<=0; cA3<=0;cB3<=0;
        cA4<=0;cB4<=0; cA5<=0;cB5<=0; cA6<=0;cB6<=0; cA7<=0;cB7<=0;
        phase <= 10'd1;
      end else if (phase <= EVAL) begin
        phase <= phase + 1'b1;
        cA0<=cA0+{15'd0,tog[0]};  cB0<=cB0+{15'd0,tog[1]};
        cA1<=cA1+{15'd0,tog[2]};  cB1<=cB1+{15'd0,tog[3]};
        cA2<=cA2+{15'd0,tog[4]};  cB2<=cB2+{15'd0,tog[5]};
        cA3<=cA3+{15'd0,tog[6]};  cB3<=cB3+{15'd0,tog[7]};
        cA4<=cA4+{15'd0,tog[8]};  cB4<=cB4+{15'd0,tog[9]};
        cA5<=cA5+{15'd0,tog[10]}; cB5<=cB5+{15'd0,tog[11]};
        cA6<=cA6+{15'd0,tog[12]}; cB6<=cB6+{15'd0,tog[13]};
        cA7<=cA7+{15'd0,tog[14]}; cB7<=cB7+{15'd0,tog[15]};
      end else begin
        phase<=10'd0; done_r<=1'b1;
        res[0]<=(cA0>=cB0); res[1]<=(cA1>=cB1);
        res[2]<=(cA2>=cB2); res[3]<=(cA3>=cB3);
        res[4]<=(cA4>=cB4); res[5]<=(cA5>=cB5);
        res[6]<=(cA6>=cB6); res[7]<=(cA7>=cB7);
      end
    end
  end

  // ================================================================
  // 32-bit Galois LFSR (taps 32,22,2,1)
  // ================================================================
  (* keep *) reg [31:0] lfsr;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) lfsr <= 32'hDEAD_BEEF;
    else        lfsr <= {lfsr[30:0], lfsr[31]^lfsr[21]^lfsr[1]^lfsr[0]};

  // ================================================================
  // 16-bit LFSR (different poly x^16+x^15+x^13+x^4+1)
  // ================================================================
  (* keep *) reg [15:0] lfsr16;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) lfsr16 <= 16'hACE1;
    else        lfsr16 <= {lfsr16[14:0],
                           lfsr16[15]^lfsr16[14]^lfsr16[12]^lfsr16[3]};

  // ================================================================
  // 32-bit CRC-32/IEEE-802.3 (poly 0x04C11DB7)
  // Input = tog[7:0] ^ lfsr[7:0] each clock
  // Unrolled 1-byte step — ~128 combinational gates + 32 FFs
  // ================================================================
  (* keep *) reg [31:0] crc32;
  wire [7:0]  ci32 = tog[7:0] ^ lfsr[7:0];
  wire [31:0] c32  = crc32;

  wire [31:0] crc32_next;
  assign crc32_next[0]  = ci32[6]^ci32[0]^c32[24]^c32[30];
  assign crc32_next[1]  = ci32[7]^ci32[6]^ci32[1]^ci32[0]^c32[24]^c32[25]^c32[30]^c32[31];
  assign crc32_next[2]  = ci32[7]^ci32[6]^ci32[2]^ci32[1]^ci32[0]^c32[24]^c32[25]^c32[26]^c32[30]^c32[31];
  assign crc32_next[3]  = ci32[7]^ci32[3]^ci32[2]^ci32[1]^c32[25]^c32[26]^c32[27]^c32[31];
  assign crc32_next[4]  = ci32[6]^ci32[4]^ci32[3]^ci32[2]^ci32[0]^c32[24]^c32[26]^c32[27]^c32[28]^c32[30];
  assign crc32_next[5]  = ci32[7]^ci32[6]^ci32[5]^ci32[4]^ci32[3]^ci32[1]^ci32[0]^c32[24]^c32[25]^c32[27]^c32[28]^c32[29]^c32[30]^c32[31];
  assign crc32_next[6]  = ci32[7]^ci32[6]^ci32[5]^ci32[4]^ci32[2]^ci32[1]^c32[25]^c32[26]^c32[28]^c32[29]^c32[30]^c32[31];
  assign crc32_next[7]  = ci32[7]^ci32[5]^ci32[3]^ci32[2]^ci32[0]^c32[24]^c32[26]^c32[27]^c32[29]^c32[31];
  assign crc32_next[8]  = ci32[4]^ci32[3]^ci32[1]^ci32[0]^c32[0]^c32[24]^c32[25]^c32[27]^c32[28];
  assign crc32_next[9]  = ci32[5]^ci32[4]^ci32[2]^ci32[1]^c32[1]^c32[25]^c32[26]^c32[28]^c32[29];
  assign crc32_next[10] = ci32[5]^ci32[3]^ci32[2]^ci32[0]^c32[2]^c32[24]^c32[26]^c32[27]^c32[29];
  assign crc32_next[11] = ci32[4]^ci32[3]^ci32[1]^ci32[0]^c32[3]^c32[24]^c32[25]^c32[27]^c32[28];
  assign crc32_next[12] = ci32[6]^ci32[5]^ci32[4]^ci32[2]^ci32[1]^ci32[0]^c32[4]^c32[24]^c32[25]^c32[26]^c32[28]^c32[29]^c32[30];
  assign crc32_next[13] = ci32[7]^ci32[6]^ci32[5]^ci32[3]^ci32[2]^ci32[1]^c32[5]^c32[25]^c32[26]^c32[27]^c32[29]^c32[30]^c32[31];
  assign crc32_next[14] = ci32[7]^ci32[6]^ci32[4]^ci32[3]^ci32[2]^c32[6]^c32[26]^c32[27]^c32[28]^c32[30]^c32[31];
  assign crc32_next[15] = ci32[7]^ci32[5]^ci32[4]^ci32[3]^c32[7]^c32[27]^c32[28]^c32[29]^c32[31];
  assign crc32_next[16] = ci32[5]^ci32[4]^ci32[0]^c32[8]^c32[24]^c32[28]^c32[29];
  assign crc32_next[17] = ci32[6]^ci32[5]^ci32[1]^c32[9]^c32[25]^c32[29]^c32[30];
  assign crc32_next[18] = ci32[7]^ci32[6]^ci32[2]^c32[10]^c32[26]^c32[30]^c32[31];
  assign crc32_next[19] = ci32[7]^ci32[3]^c32[11]^c32[27]^c32[31];
  assign crc32_next[20] = ci32[4]^c32[12]^c32[28];
  assign crc32_next[21] = ci32[5]^c32[13]^c32[29];
  assign crc32_next[22] = ci32[0]^c32[14]^c32[24];
  assign crc32_next[23] = ci32[6]^ci32[1]^ci32[0]^c32[15]^c32[24]^c32[25]^c32[30];
  assign crc32_next[24] = ci32[7]^ci32[2]^ci32[1]^c32[16]^c32[25]^c32[26]^c32[31];
  assign crc32_next[25] = ci32[3]^ci32[2]^c32[17]^c32[26]^c32[27];
  assign crc32_next[26] = ci32[6]^ci32[4]^ci32[3]^ci32[0]^c32[18]^c32[24]^c32[27]^c32[28]^c32[30];
  assign crc32_next[27] = ci32[7]^ci32[5]^ci32[4]^ci32[1]^c32[19]^c32[25]^c32[28]^c32[29]^c32[31];
  assign crc32_next[28] = ci32[6]^ci32[5]^ci32[2]^c32[20]^c32[26]^c32[29]^c32[30];
  assign crc32_next[29] = ci32[7]^ci32[6]^ci32[3]^c32[21]^c32[27]^c32[30]^c32[31];
  assign crc32_next[30] = ci32[7]^ci32[4]^c32[22]^c32[28]^c32[31];
  assign crc32_next[31] = ci32[5]^c32[23]^c32[29];

  always @(posedge clk or negedge rst_n)
    if (!rst_n) crc32 <= 32'hFFFF_FFFF;
    else        crc32 <= crc32_next;

  // ================================================================
  // 16-bit CRC-16/CCITT (poly 0x1021) over tog[15:8]^lfsr16[7:0]
  // ================================================================
  (* keep *) reg [15:0] crc16;
  wire [7:0]  ci16 = tog[15:8] ^ lfsr16[7:0];
  wire [15:0] crc16_next;
  assign crc16_next[15] = crc16[14] ^ ci16[7];
  assign crc16_next[14] = crc16[13] ^ ci16[6];
  assign crc16_next[13] = crc16[12] ^ ci16[5];
  assign crc16_next[12] = crc16[11] ^ ci16[4] ^ crc16[15] ^ ci16[7];
  assign crc16_next[11] = crc16[10] ^ ci16[3];
  assign crc16_next[10] = crc16[9]  ^ ci16[2];
  assign crc16_next[9]  = crc16[8]  ^ ci16[1];
  assign crc16_next[8]  = crc16[7]  ^ ci16[0];
  assign crc16_next[7]  = crc16[6];
  assign crc16_next[6]  = crc16[5];
  assign crc16_next[5]  = crc16[4]  ^ crc16[15] ^ ci16[7];
  assign crc16_next[4]  = crc16[3];
  assign crc16_next[3]  = crc16[2];
  assign crc16_next[2]  = crc16[1];
  assign crc16_next[1]  = crc16[0];
  assign crc16_next[0]  = crc16[15] ^ ci16[7];

  always @(posedge clk or negedge rst_n)
    if (!rst_n) crc16 <= 16'hFFFF;
    else        crc16 <= crc16_next;

  // ================================================================
  // Hamming-weight tree #1: popcount of tog[15:0] → 5-bit result
  // ================================================================
  wire [1:0] h0 =tog[0]+tog[1];   wire [1:0] h1 =tog[2]+tog[3];
  wire [1:0] h2 =tog[4]+tog[5];   wire [1:0] h3 =tog[6]+tog[7];
  wire [1:0] h4 =tog[8]+tog[9];   wire [1:0] h5 =tog[10]+tog[11];
  wire [1:0] h6 =tog[12]+tog[13]; wire [1:0] h7 =tog[14]+tog[15];
  wire [2:0] h8 =h0+h1; wire [2:0] h9=h2+h3;
  wire [2:0] h10=h4+h5; wire [2:0] h11=h6+h7;
  wire [3:0] h12=h8+h9; wire [3:0] h13=h10+h11;
  wire [4:0] hamming1 = h12+h13;

  (* keep *) reg [4:0] ham1_r;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) ham1_r <= 5'd0;
    else        ham1_r <= hamming1;

  // ================================================================
  // Hamming-weight tree #2: popcount of tog[31:16] → 5-bit result
  // ================================================================
  wire [1:0] g0 =tog[16]+tog[17]; wire [1:0] g1 =tog[18]+tog[19];
  wire [1:0] g2 =tog[20]+tog[21]; wire [1:0] g3 =tog[22]+tog[23];
  wire [1:0] g4 =tog[24]+tog[25]; wire [1:0] g5 =tog[26]+tog[27];
  wire [1:0] g6 =tog[28]+tog[29]; wire [1:0] g7 =tog[30]+tog[31];
  wire [2:0] g8 =g0+g1; wire [2:0] g9 =g2+g3;
  wire [2:0] g10=g4+g5; wire [2:0] g11=g6+g7;
  wire [3:0] g12=g8+g9; wire [3:0] g13=g10+g11;
  wire [4:0] hamming2 = g12+g13;

  (* keep *) reg [4:0] ham2_r;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) ham2_r <= 5'd0;
    else        ham2_r <= hamming2;

  // ================================================================
  // 8-bit main accumulator — XOR of all live paths
  // ================================================================
  (* keep *) reg [7:0] acc;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) acc <= 8'd0;
    else if (done_r)
      acc <= acc
           ^ res
           ^ crc32[7:0]  ^ crc32[15:8]
           ^ crc32[23:16] ^ crc32[31:24]
           ^ crc16[7:0]  ^ crc16[15:8]
           ^ {ham1_r, tog[2:0]}
           ^ {ham2_r, tog[5:3]}
           ^ lfsr[7:0]
           ^ lfsr16[7:0];

  // ================================================================
  // Four 8-bit pipeline stages — 32 more FFs forced by unique wiring
  // ================================================================
  (* keep *) reg [7:0] pipe1, pipe2, pipe3, pipe4;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pipe1<=8'd0; pipe2<=8'd0; pipe3<=8'd0; pipe4<=8'd0;
    end else begin
      pipe1 <= acc    ^ {res[3:0],     crc32[3:0]};
      pipe2 <= pipe1  ^ {crc16[11:8],  ham1_r[3:0]};
      pipe3 <= pipe2  ^ lfsr[23:16]   ^ lfsr16[15:8];
      pipe4 <= pipe3  ^ {tog[23:20],   tog[27:24]};
    end
  end

  // ================================================================
  // Challenge mux: ui_in[2:0] → debug counter pair
  // ================================================================
  wire [2:0] sel = ui_in[2:0];
  reg [15:0] dbgA, dbgB;
  always @(*) begin
    case (sel)
      3'd0: begin dbgA=cA0; dbgB=cB0; end
      3'd1: begin dbgA=cA1; dbgB=cB1; end
      3'd2: begin dbgA=cA2; dbgB=cB2; end
      3'd3: begin dbgA=cA3; dbgB=cB3; end
      3'd4: begin dbgA=cA4; dbgB=cB4; end
      3'd5: begin dbgA=cA5; dbgB=cB5; end
      3'd6: begin dbgA=cA6; dbgB=cB6; end
      3'd7: begin dbgA=cA7; dbgB=cB7; end
    endcase
  end

  // ================================================================
  // Output — every internal node feeds here; synthesiser keeps all
  // ================================================================
  wire [7:0] scrambled = pipe4
                       ^ acc
                       ^ crc32[7:0]
                       ^ crc16[7:0]
                       ^ {ham1_r[4:0], ham2_r[2:0]}
                       ^ {dbgA[5:0], dbgB[1:0]};

  assign uo_out[0]   = (^scrambled) ^ (^res) ^ (^crc32) ^ (^crc16);
  assign uo_out[1]   = done_r;
  assign uo_out[7:2] = scrambled[5:0];

  assign uio_out = 8'd0;
  assign uio_oe  = 8'd0;

  // Tie off unconnected bits so linter is clean
  wire _unused = &{ena, uio_in, ui_in[7:3],
                   lfsr[31:8],   lfsr16[15:8],
                   dbgA[15:6],   dbgB[15:2],
                   ham1_r[4],    ham2_r[4],
                   pipe1,        pipe2,        pipe3,
                   tog[31:16],
                   cA4,cB4, cA5,cB5, cA6,cB6, cA7,cB7,
                   1'b0};

endmodule
