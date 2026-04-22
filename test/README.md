# Ring Oscillator PUF — Tiny Tapeout

A hardware security primitive: **Ring Oscillator Physical Unclonable Function (RO-PUF)** on sky130.

## What it does

Applies an 8-bit challenge (`ui_in`) to select two of 16 on-chip ring oscillators, races them for 200 clock cycles, and returns a 1-bit response based on which runs faster. Because oscillator frequencies are set by silicon manufacturing variation, the response is unique to each die.

| Pin | Direction | Function |
|-----|-----------|----------|
| `ui_in[3:0]` | Input | Select RO_A (0–15) |
| `ui_in[7:4]` | Input | Select RO_B (0–15) |
| `uo_out[0]`  | Output | PUF response bit |
| `uo_out[1]`  | Output | Done / result-valid flag |
| `uo_out[7:2]`| Output | Counter A bits 7:2 (debug) |
| `uio_*`      | —     | Unused (tied to 0) |

## How to use

1. Clock: 50 MHz
2. Assert `rst_n` low then high
3. Set `ui_in` to your challenge
4. Wait for `uo_out[1]` to pulse high (~200 cycles / ~4 µs)
5. Read response from `uo_out[0]`
6. Change challenge to trigger a new evaluation

## Simulation

```bash
cd test
make        # RTL sim
make GATES=yes  # Gate-level sim (requires PDK_ROOT)
```

## Project structure

```
├── src/
│   └── tt_um_puf.v       ← entire design, single file
├── test/
│   ├── Makefile
│   ├── tb.v
│   ├── test.py
│   ├── tb.gtkw
│   ├── requirements.txt
│   └── results.xml
├── docs/
│   └── info.md
└── info.yaml
```
