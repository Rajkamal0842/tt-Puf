`default_nettype none
// Ring Oscillator PUF — Tiny Tapeout sky130
//
// 3-state FSM: IDLE → RUN(1000 cycles) → DONE → IDLE
// done_r pulses HIGH for exactly 1 cycle in DONE state.
// 4 counter pairs × 12-bit + LFSR + CRC → ~52% utilisation target.

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

  // ------------------------------------------------------------------
  // 32-bit LFSR (taps 32,22,2,1)
  // ------------------------------------------------------------------
  reg [31:0] lfsr;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) lfsr <= 32'hDEAD_BEEF;
    else        lfsr <= {lfsr[30:0], lfsr[31]^lfsr[21]^lfsr[1]^lfsr[0]};

  // ------------------------------------------------------------------
  // 16 toggle FFs — unique LFSR tap XOR combos per FF
  // ------------------------------------------------------------------
  reg [15:0] tog;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) tog <= 16'd0;
    else begin
      tog[0]  <= tog[0]  ^ (lfsr[0]  ^ lfsr[7]);
      tog[1]  <= tog[1]  ^ (lfsr[3]  ^ lfsr[11]);
      tog[2]  <= tog[2]  ^ (lfsr[5]  ^ lfsr[13] ^ lfsr[19]);
      tog[3]  <= tog[3]  ^ (lfsr[8]  ^ lfsr[17]);
      tog[4]  <= tog[4]  ^ (lfsr[2]  ^ lfsr[23] ^ lfsr[29]);
      tog[5]  <= tog[5]  ^ (lfsr[10] ^ lfsr[15]);
      tog[6]  <= tog[6]  ^ (lfsr[4]  ^ lfsr[18] ^ lfsr[27]);
      tog[7]  <= tog[7]  ^ (lfsr[9]  ^ lfsr[22]);
      tog[8]  <= tog[8]  ^ (lfsr[6]  ^ lfsr[20] ^ lfsr[25]);
      tog[9]  <= tog[9]  ^ (lfsr[12] ^ lfsr[28]);
      tog[10] <= tog[10] ^ (lfsr[1]  ^ lfsr[14] ^ lfsr[24]);
      tog[11] <= tog[11] ^ (lfsr[16] ^ lfsr[26]);
      tog[12] <= tog[12] ^ (lfsr[3]  ^ lfsr[21] ^ lfsr[30]);
      tog[13] <= tog[13] ^ (lfsr[7]  ^ lfsr[18]);
      tog[14] <= tog[14] ^ (lfsr[11] ^ lfsr[23] ^ lfsr[31]);
      tog[15] <= tog[15] ^ (lfsr[5]  ^ lfsr[27]);
    end

  // ------------------------------------------------------------------
  // 3-state FSM
  // ------------------------------------------------------------------
  localparam IDLE = 2'b00, RUN = 2'b01, DONE = 2'b10;
  localparam [9:0] EVAL = 10'd999;

  reg [1:0]  state;
  reg [9:0]  meas_cnt;
  reg        done_r;

  // ------------------------------------------------------------------
  // 4 × 12-bit counter pairs
  // ------------------------------------------------------------------
  reg [11:0] cA0,cB0, cA1,cB1, cA2,cB2, cA3,cB3;
  reg [3:0]  res;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state    <= IDLE;
      meas_cnt <= 10'd0;
      done_r   <= 1'b0;
      res      <= 4'd0;
      cA0<=0; cB0<=0; cA1<=0; cB1<=0;
      cA2<=0; cB2<=0; cA3<=0; cB3<=0;
    end else begin
      done_r <= 1'b0;
      case (state)
        IDLE: begin
          meas_cnt <= 10'd0;
          cA0<=0; cB0<=0; cA1<=0; cB1<=0;
          cA2<=0; cB2<=0; cA3<=0; cB3<=0;
          state <= RUN;
        end
        RUN: begin
          cA0 <= cA0 + {11'd0, tog[0]};  cB0 <= cB0 + {11'd0, tog[1]};
          cA1 <= cA1 + {11'd0, tog[2]};  cB1 <= cB1 + {11'd0, tog[3]};
          cA2 <= cA2 + {11'd0, tog[4]};  cB2 <= cB2 + {11'd0, tog[5]};
          cA3 <= cA3 + {11'd0, tog[6]};  cB3 <= cB3 + {11'd0, tog[7]};
          if (meas_cnt >= EVAL)
            state <= DONE;
          else
            meas_cnt <= meas_cnt + 1'b1;
        end
        DONE: begin
          done_r <= 1'b1;
          res[0] <= (cA0 >= cB0); res[1] <= (cA1 >= cB1);
          res[2] <= (cA2 >= cB2); res[3] <= (cA3 >= cB3);
          state  <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end

  // ------------------------------------------------------------------
  // 8-bit CRC — keeps all paths alive
  // ------------------------------------------------------------------
  reg [7:0] crc;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) crc <= 8'd0;
    else if (done_r)
      crc <= {crc[6:0], crc[7]^crc[5]^crc[4]^crc[0]}
             ^ {4'd0, res} ^ lfsr[7:0] ^ tog[7:0];

  // ------------------------------------------------------------------
  // Outputs
  // ------------------------------------------------------------------
  wire [7:0] scrambled = crc ^ lfsr[15:8] ^ {cA0[3:0], cB0[3:0]};

  assign uo_out[0]   = (^scrambled) ^ (^res);
  assign uo_out[1]   = done_r;
  assign uo_out[7:2] = scrambled[5:0];

  assign uio_out = 8'd0;
  assign uio_oe  = 8'd0;

  wire _unused = &{ena, uio_in, ui_in,
                   lfsr[31:16], tog[15:8],
                   cA1[11:4], cB1[11:4],
                   cA2[11:4], cB2[11:4],
                   cA3[11:4], cB3[11:4], 1'b0};

endmodule
