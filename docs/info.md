<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
This project implements a Hardware Security Primitive known as a Ring Oscillator Physical Unclonable Function (RO-PUF). 

It contains a bank of 16 free-running Ring Oscillators (ROs). Because of microscopic variations during the silicon manufacturing process, each oscillator will run at a slightly different, unique frequency. 

The user inputs an 8-bit challenge to select two different ROs using two 16-to-1 multiplexers. A synchronous Finite State Machine (FSM) enables the selected oscillators for a fixed evaluation window (200 clock cycles). Two asynchronous 8-bit counters track the oscillations. When the evaluation window closes, the FSM compares the final counter values. The oscillator that counted higher wins, generating a 1-bit digital response (1 or 0) representing the physical entropy of the silicon.

## How to test
1. Provide a 50 MHz clock to the `clk` pin.
2. Pull the `rst_n` pin low (0) to reset the system, then pull it high (1) to begin operation.
3. Apply an 8-bit challenge to the input pins `ui_in[7:0]`. 
   - The lower 4 bits (`ui_in[3:0]`) select Ring Oscillator A.
   - The upper 4 bits (`ui_in[7:4]`) select Ring Oscillator B.
4. Wait for the `uo_out[1]` (Done Flag) to go HIGH.
5. Read the 1-bit PUF response on `uo_out[0]`. 
6. To test a new challenge, simply change the input bits on `ui_in`. The FSM will automatically detect the change, reset the counters, and trigger a new evaluation.
7. Optional: Monitor `uo_out[7:2]` to see the upper 6 bits of Counter A for debugging purposes.

## External hardware
No external hardware is required. A standard Tiny Tapeout demo board with DIP switches for inputs and LEDs for outputs is sufficient to evaluate the PUF responses.

