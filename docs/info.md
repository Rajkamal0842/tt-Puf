## How it works

This project implements a Hardware Security Primitive known as a **Ring Oscillator Physical Unclonable Function (RO-PUF)**.

It contains a bank of **16 free-running Ring Oscillators (ROs)**. Because of microscopic variations during the silicon manufacturing process, each oscillator will run at a slightly different, unique frequency that cannot be predicted or reproduced — this is the physical "unclonable" entropy.

**Challenge → Response flow:**

1. The user supplies an **8-bit challenge** via `ui_in[7:0]`:
   - `ui_in[3:0]` selects **RO_A** (one of 16 oscillators)
   - `ui_in[7:4]` selects **RO_B** (one of 16 oscillators)
2. A synchronous **FSM** detects the new challenge and opens a **200-clock-cycle evaluation window**, enabling both selected oscillators.
3. Two **8-bit edge-counting counters** count rising edges of RO_A and RO_B during the window.
4. When the window closes, the FSM **compares** the two counters. Whichever oscillator ran faster (counted more edges) determines the 1-bit response:
   - Counter_A > Counter_B → response = **1**
   - Counter_A ≤ Counter_B → response = **0**
5. The `done` flag (`uo_out[1]`) goes high for one cycle to signal a valid result.
6. Changing `ui_in` triggers a fresh evaluation automatically.

The upper 6 bits of Counter A are exposed on `uo_out[7:2]` for debugging purposes.

## How to test

1. Provide a **50 MHz** clock to the `clk` pin.
2. Pull `rst_n` **low** to reset, then **high** to begin operation.
3. Apply an **8-bit challenge** to `ui_in[7:0]`:
   - `ui_in[3:0]` = RO_A selector (0–15)
   - `ui_in[7:4]` = RO_B selector (0–15)
4. Wait for `uo_out[1]` **(Done Flag)** to pulse HIGH — this takes ~200 clock cycles (~4 µs at 50 MHz).
5. Read the **1-bit PUF response** on `uo_out[0]`.
6. To test a new challenge, change `ui_in`. The FSM automatically detects the change, resets the counters, and triggers a fresh evaluation.
7. Optionally monitor `uo_out[7:2]` to see the upper 6 bits of Counter A for debugging.

**Note:** Selecting the same oscillator for both A and B (e.g. `ui_in = 8'h00`) will always produce a response of 0 since both counters will be equal.

## External hardware

No external hardware is required. A standard **Tiny Tapeout demo board** with DIP switches for inputs and LEDs for outputs is sufficient to evaluate PUF challenge–response pairs.
