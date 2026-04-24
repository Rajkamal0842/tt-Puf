<!---
This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.
You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a **64-RO Ring Oscillator Physical Unclonable Function (RO-PUF)** — a hardware security primitive that exploits unavoidable transistor-level manufacturing variation to generate a unique, chip-specific identity that cannot be cloned or predicted.

The design contains **64 ring oscillators** (implemented as toggle flip-flops on sky130). Each oscillator toggles at a slightly different effective rate due to process variation introduced during fabrication. When an 8-bit challenge is applied via `ui_in`, 6 bits select two oscillators (RO_A and RO_B) from the 64-element bank. Both oscillators run simultaneously for **1000 clock cycles** while two 10-bit hardware counters track the number of rising-edge transitions each produces.

At the end of the evaluation window the design compares the counters:
- `counter_A > counter_B` → response bit = **1**
- `counter_A <= counter_B` → response bit = **0**

In parallel, an **XOR accumulator** folds all 8 bytes of the 64-bit RO bus every clock cycle, producing an 8-bit entropy hash output on `uo_out[7:2]` for debug and additional entropy extraction.

Because the frequency difference between any two oscillators is determined by physics at manufacturing time, the same challenge always produces the same response on one die, but a statistically independent response on every other die. This makes the PUF suitable for device authentication, hardware fingerprinting, and lightweight key generation without non-volatile memory.

A new evaluation is triggered automatically whenever `ui_in` changes. The `done` flag pulses high when the result is ready (~1001 cycles after the challenge changes, approximately 20 us at 50 MHz).

## How to test

1. Connect a 50 MHz clock to `clk` and drive `rst_n`.
2. Assert `rst_n` low for at least 5 clock cycles, then release it high.
3. Apply an 8-bit challenge to `ui_in`. The lower 6 bits select which pair of ring oscillators to compare. For example:
   - `0x00` selects RO 0 vs RO 32
   - `0x12` selects RO 18 vs RO 50
   - `0x3F` selects RO 63 vs RO 31
4. Wait for `uo_out[1]` (done flag) to pulse high — this takes approximately 1001 clock cycles (~20 us at 50 MHz).
5. Read the 1-bit PUF response from `uo_out[0]`.
6. Read the XOR entropy hash from `uo_out[7:2]` (6 bits of accumulated RO XOR output).
7. Change `ui_in` to a different value to trigger a new evaluation.

Up to 64 challenge pairs are available from the 6-bit challenge space (`ui_in[5:0]`).

## External hardware

No external hardware is required. The PUF operates entirely on-chip using sky130 standard cells. A microcontroller or logic analyser connected to `ui_in` and `uo_out` is useful for reading challenge-response pairs and verifying the done flag timing.
