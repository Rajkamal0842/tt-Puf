<!---
This file is used to generate your project datasheet. Please fill in the information below and delete any unused sections.
You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a **Ring Oscillator Physical Unclonable Function (RO-PUF)** — a hardware security primitive that exploits unavoidable manufacturing variation in silicon to generate a unique, device-specific identity.

The design contains **32 ring oscillators** (modelled as toggle flip-flops clocked at 50 MHz). Each oscillator toggles at a slightly different effective rate due to process variation on the chip. When an 8-bit challenge is applied via `ui_in`, the lower nibble selects one oscillator (RO_A) and the upper nibble selects another (RO_B). Both oscillators race for **1000 clock cycles** while hardware counters track how many rising-edge transitions each one produces. At the end of the evaluation window, whichever counter is higher determines the 1-bit PUF response:

- `counter_A > counter_B` → response = 1
- `counter_A ≤ counter_B` → response = 0

Because the frequency difference between any two oscillators is fixed by physics at manufacturing time, the same challenge always produces the same response on one chip, but a different response on another chip. This makes the PUF suitable for device authentication, key generation, and anti-counterfeiting applications.

A new evaluation is automatically triggered whenever `ui_in` changes. The `done` flag pulses high when the result is ready (~1001 cycles after the challenge changes).

## How to test

1. Set clock to **50 MHz** and connect `clk` and `rst_n`.
2. Assert `rst_n` low for at least 5 cycles, then release high.
3. Apply an 8-bit challenge to `ui_in` (e.g., `0x12` selects RO 2 vs RO 17).
4. Wait for `uo_out[1]` (done flag) to go **high** — this takes approximately 1001 clock cycles (~20 µs at 50 MHz).
5. Read the **1-bit PUF response** from `uo_out[0]`.
6. To get a new response, change `ui_in` to a different challenge value — this automatically restarts the evaluation.
7. Repeat with up to 256 different challenges (8-bit challenge space).

For debug, `uo_out[7:2]` outputs the upper 6 bits of Counter A so you can observe the raw count on a logic analyser.

## External hardware

No external hardware required. The PUF operates entirely on-chip using the sky130 standard cell library. A logic analyser or microcontroller connected to `ui_in` and `uo_out` is useful for reading challenge-response pairs.
