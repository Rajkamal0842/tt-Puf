<!---
This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.
You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a **Ring Oscillator Physical Unclonable Function (RO-PUF)** — a hardware security primitive that exploits unavoidable manufacturing variation in silicon to generate a unique chip fingerprint.

The design contains **16 ring oscillators** modelled as multi-bit LFSRs with unique tap polynomials and reset values, each producing a distinct toggle pattern determined by the exact transistor characteristics at manufacturing time. Their output bits are collected into a 16-bit toggle register.

When an 8-bit challenge is applied on `ui_in`, the lower nibble selects one oscillator (RO_A) and the upper nibble selects another (RO_B). Both are raced for **1000 clock cycles** using 12-bit hardware counters that count rising edge transitions. Four additional hardwired pairs race simultaneously, producing 4 more independent response bits.

A **32-bit LFSR scrambler** runs in parallel every clock cycle, and a **CRC-32 accumulator** folds the running toggle state into a 32-bit hash. All outputs are XOR'd with LFSR and CRC bits to produce a richer, harder-to-predict response.

The final 8-bit output on `uo_out` encodes the challenge-selected response, a done flag, four fixed-pair responses, and two CRC entropy bits.

## How to test

1. Connect a 50 MHz clock to `clk`.
2. Assert `rst_n` low for at least 5 cycles, then release high.
3. Apply an 8-bit challenge to `ui_in` (lower nibble selects RO_A, upper nibble selects RO_B).
4. Wait approximately **1001 clock cycles** (~20 us at 50 MHz) for `uo_out[1]` (done) to go high.
5. Read the full 8-bit response from `uo_out`.
6. Reset (`rst_n` low then high) to trigger a new evaluation with a different challenge.

Different challenges produce different responses. The same challenge on the same chip always produces the same response. Different chips produce different responses for the same challenge.

## External hardware

No external hardware required. A microcontroller or logic analyser connected to `ui_in` and `uo_out` is recommended for reading and recording challenge-response pairs.
