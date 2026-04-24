## How it works

This project implements a **Ring Oscillator Physical Unclonable Function (RO-PUF)** on the sky130 process, designed to occupy more than 70% of the 1×1 tile.

### Architecture

**32 unique shift-register ring oscillators** are instantiated. Each has a different chain depth (3 to 17 stages) and a different LFSR-style feedback polynomial. Because both depth and taps differ for every RO, the synthesiser cannot structurally merge any pair of them. Each RO drives a dedicated toggle flip-flop.

**8 × 16-bit counter pairs** run in parallel during a 1023-cycle measurement window. Each pair counts toggle events of two ROs and compares totals. The faster oscillator wins. Silicon process variation (gate oxide, doping, parasitic capacitance) makes the comparison result chip-unique.

**32-bit Galois LFSR** (taps 32, 22, 2, 1) and a separate **16-bit LFSR** (taps 16, 15, 13, 4) run continuously and are XORed into the scrambler.

**32-bit CRC-32/IEEE-802.3** is computed every clock cycle over `tog[7:0] XOR lfsr[7:0]`. The unrolled one-byte combinational step produces approximately 128 gate cells.

**16-bit CRC-16/CCITT** is computed every clock cycle over `tog[15:8] XOR lfsr16[7:0]`, adding another ~32 gate cells and 16 registered bits.

**Two independent Hamming-weight adder trees** compute the popcount of `tog[15:0]` and `tog[31:16]` separately using explicit 4-level adder cascades.

**Four 8-bit pipeline registers** (pipe1–pipe4) add registered stages, each uniquely wired to different subsets of the internal signals.

All paths fan into the final output XOR tree, so the synthesiser has no dead sinks to prune.

## How to test

1. Set clock to 50 MHz (20 ns period).
2. Assert `rst_n` low for at least 5 cycles, then release high.
3. The FSM automatically starts a 1023-cycle measurement.
4. Set `ui_in[2:0]` to your challenge (0–7) to select which counter pair appears on the debug outputs.
5. Wait for `uo_out[1]` to pulse high (approximately 1023 cycles, ~20 µs at 50 MHz).
6. Read the PUF response from `uo_out[0]`.
7. Pulse `rst_n` low then high to start a new measurement.
8. Change `ui_in[2:0]` to read a different counter pair result.

The debug outputs `uo_out[7:2]` show scrambled counter MSBs XORed with CRC and pipeline data for the selected pair.

## External hardware

No external hardware is required. The PUF is entirely self-contained on-chip. A standard Tiny Tapeout demo board with DIP switches for `ui_in` and LEDs for `uo_out` is sufficient.
