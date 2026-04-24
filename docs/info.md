<!---
This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.
You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a **Ring Oscillator Physical Unclonable Function (RO-PUF)** — a hardware security primitive that generates a unique, chip-specific fingerprint from unavoidable transistor-level manufacturing variation in silicon.

The design contains **16 ring oscillators** modelled as multi-bit LFSRs, each with a unique width, unique tap polynomial, and unique reset value. Their LSB outputs are accumulated into a 16-bit toggle register each clock cycle. The resulting toggle patterns depend on the exact transistor characteristics at the time of manufacture, making each chip produce a different sequence.

When the device comes out of reset, it automatically starts a **1000-cycle measurement window**. During this window, **four hardwired 12-bit counter pairs** each race two fixed ROs simultaneously, and a **challenge-selected pair** races the two ROs chosen by `ui_in`. At the end of 1000 cycles, each counter pair's comparator result provides one PUF response bit.

Two LFSRs — a 32-bit and a 16-bit — run in parallel every cycle and XOR their bits into the final output to add entropy depth and make the response harder to predict without silicon.

After each evaluation completes (`done` goes high), the FSM automatically restarts a new 1000-cycle window. To use a different challenge, assert `rst_n` low briefly then release — this resets the FSM and starts fresh with the current `ui_in`.

## How to test

1. Connect a 50 MHz clock to `clk`.
2. Set `ui_in` to your desired 8-bit challenge value.
3. Assert `rst_n` low for at least 5 clock cycles, then release high.
4. Wait approximately **1002 clock cycles** (~20 µs at 50 MHz) for `uo_out[1]` (done) to go high.
5. Read the full 8-bit response from `uo_out[7:0]`.
6. To test a new challenge: apply `rst_n` low/high again with the new `ui_in` value.

The same challenge on the same chip always produces the same response. Different chips produce statistically independent responses for the same challenge (~50% Hamming distance between chips).

## External hardware

No external hardware required. A microcontroller or logic analyser connected to `ui_in` and `uo_out` is sufficient for reading and recording challenge-response pairs.
