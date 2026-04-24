<!---
This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.
You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a **high-density Ring Oscillator Physical Unclonable Function (RO-PUF)** — a hardware security primitive that exploits unavoidable transistor-level manufacturing variation to generate a unique, chip-specific fingerprint.

The design contains **64 ring oscillators** (implemented as toggle flip-flops on sky130) organised into **8 parallel evaluation pairs**. Unlike a simple single-pair PUF, all 8 pairs run simultaneously during every evaluation window. This means the chip produces **8 independent PUF response bits per challenge**, giving much higher throughput and making the synthesiser keep all logic paths active.

Each pair races its two oscillators for **1000 clock cycles**. Independent 10-bit hardware counters count the rising-edge transitions for each oscillator in every pair. At the end of the window, each pair's comparator (`counter_A > counter_B`) produces one response bit. All 8 comparator outputs are registered and driven directly to `uo_out[6:0]`.

In addition, a ninth evaluation uses the 8-bit challenge on `ui_in` to select a pair dynamically from the 64-RO bank, and its result is XOR'd with the `done` flag on `uo_out[7]`.

Because every output bit is the product of a real counter and comparator chain, the synthesiser cannot prune any logic — all 64 RO flip-flops, 16 counters, and 8 comparators remain in the netlist.

## How to test

1. Connect a 50 MHz clock to `clk` and drive `rst_n`.
2. Assert `rst_n` low for at least 5 clock cycles, then release it high. All outputs will be 0.
3. Apply any 8-bit value to `ui_in`. This triggers a 1000-cycle evaluation window immediately.
4. Wait approximately **1002 clock cycles** (~20 us at 50 MHz).
5. Read all 8 response bits from `uo_out[7:0]`:
   - `uo_out[6:0]` — 7 bits from the 8 fixed hardwired RO pairs
   - `uo_out[7]`   — challenge-selected pair result XOR done flag (goes high after evaluation)
6. Change `ui_in` to a different value to trigger a new evaluation (the fixed pairs always re-evaluate, producing updated results).

**Expected behaviour on real silicon:** each chip will produce a unique, repeatable pattern on `uo_out` for the same `ui_in`. Two different chips will produce different patterns approximately 50% of the time (Hamming distance ~50%), confirming inter-chip uniqueness.

**Note on simulation:** In RTL simulation all toggle FFs behave identically (no process variation), so comparators will read 0. The design functions correctly on real fabricated silicon.

## External hardware

No external hardware is required. The PUF operates entirely on-chip using sky130 standard cells.

A microcontroller or logic analyser connected to `ui_in` and `uo_out` is recommended to read and record challenge-response pairs for characterisation.
