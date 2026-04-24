# Enhanced Differential Ring Oscillator PUF

## How it works
This design implements a **32-Ring Oscillator Physical Unclonable Function (PUF)**. 
It uses the microscopic manufacturing variations of the Silicon (sky130) to generate unique device signatures.

- **Entropy Source:** 32 independent Ring Oscillators.
- **Comparison:** Two oscillators are selected via the 8-bit input challenge and compared over a **1000-cycle** window.
- **Accuracy:** Dual 10-bit counters track the oscillations to determine the faster oscillator.

## How to test
1. Apply an 8-bit challenge to `ui_in`.
2. Monitor `uo_out[1]` (Done signal).
3. Once `uo_out[1]` goes High, read the 1-bit signature on `uo_out[0]`.
