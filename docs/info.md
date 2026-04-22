## How it works

This project implements a Hardware Security Primitive known as a **Ring Oscillator Physical Unclonable Function (RO-PUF)**.

It contains a bank of **16 free-running Ring Oscillators (ROs)**. Because of microscopic variations during the silicon manufacturing process, each oscillator will run at a slightly different, unique frequency that cannot be predicted or reproduced.

**Challenge → Response flow:**

1. The user supplies an **8-bit challenge** via `ui_in[7:0]`: lower 4 bits select RO_A, upper 4 bits select RO_B.
2. A synchronous **FSM** opens a **200-clock-cycle evaluation window**, enabling both selected oscillators.
3. Two **8-bit edge-counting counters** count rising edges of RO_A and RO_B during the window.
4. The FSM **compares** the two counters. Whichever oscillator ran faster determines the 1-bit response: Counter_A > Counter_B → **1**, else → **0**.
5. The `done` flag (`uo_out[1]`) pulses high for one cycle to signal a valid result.
6. Changing `ui_in` triggers a fresh evaluation automatically.

## How to test

1. Provide a **50 MHz** clock to the `clk` pin.
2. Pull `rst_n` **low** to reset, then **high** to begin operation.
3. Apply an **8-bit challenge** to `ui_in[7:0]`.
4. Wait for `uo_out[1]` **(Done Flag)** to pulse HIGH (~200 clock cycles).
5. Read the **1-bit PUF response** on `uo_out[0]`.
6. To test a new challenge, change `ui_in`. The FSM automatically triggers a fresh evaluation.

## External hardware

No external hardware is required. A standard **Tiny Tapeout demo board** with DIP switches for inputs and LEDs for outputs is sufficient.
