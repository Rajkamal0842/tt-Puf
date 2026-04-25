# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

# FSM: IDLE(1 cycle) → RUN(1000 cycles) → DONE(1 cycle) → IDLE ...
# done_r is HIGH for exactly 1 clock cycle in the DONE state.
# Total period = 1002 clock cycles.
DONE_TIMEOUT = 1100   # cycles to wait for done to pulse

@cocotb.test()
async def test_reset_clears_outputs(dut):
    """Immediately after reset, done flag must be 0."""
    dut._log.info("Test: reset clears outputs")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    # sample done while still in reset
    done = (int(dut.uo_out.value) >> 1) & 1
    assert done == 0, f"done must be 0 in reset, got {done}"
    dut._log.info("PASS: reset clears outputs")

@cocotb.test()
async def test_evaluation_completes(dut):
    """After reset+release, FSM auto-starts; done goes high after ~1001 cycles."""
    dut._log.info("Test: evaluation completes within 1100 cycles")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value  = 1

    done = 0
    for _ in range(DONE_TIMEOUT):
        await RisingEdge(dut.clk)
        done = (int(dut.uo_out.value) >> 1) & 1
        if done == 1:
            break

    assert done == 1, "Done flag never went high after 1100 cycles"
    dut._log.info(f"PASS: done pulsed. PUF response={int(dut.uo_out.value) & 1}")

@cocotb.test()
async def test_done_clears_and_restarts(dut):
    """After done, FSM restarts automatically; done goes low then high again."""
    dut._log.info("Test: done clears and FSM restarts")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value  = 1

    # Wait for first done
    done = 0
    for _ in range(DONE_TIMEOUT):
        await RisingEdge(dut.clk)
        done = (int(dut.uo_out.value) >> 1) & 1
        if done:
            break
    assert done == 1, "First done never went high"

    # done is a 1-cycle pulse — next cycle it should be 0
    await RisingEdge(dut.clk)
    done_after = (int(dut.uo_out.value) >> 1) & 1
    assert done_after == 0, "done did not clear after 1 cycle"

    # Wait for second done (full measurement cycle)
    done2 = 0
    for _ in range(DONE_TIMEOUT):
        await RisingEdge(dut.clk)
        done2 = (int(dut.uo_out.value) >> 1) & 1
        if done2:
            break
    assert done2 == 1, "Second done never went high"
    dut._log.info("PASS: done clears and FSM restarts")

@cocotb.test()
async def test_different_challenges_give_outputs(dut):
    """Different ui_in values all complete a measurement without hanging."""
    dut._log.info("Test: different challenges")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    dut.ena.value    = 1
    dut.uio_in.value = 0

    for ch in range(4):
        dut.rst_n.value = 0
        dut.ui_in.value = ch
        await ClockCycles(dut.clk, 5)
        dut.rst_n.value = 1

        done = 0
        for _ in range(DONE_TIMEOUT):
            await RisingEdge(dut.clk)
            done = (int(dut.uo_out.value) >> 1) & 1
            if done:
                break
        assert done == 1, f"Done never went high for challenge {hex(ch)}"
        dut._log.info(f"  ch={ch}: uo_out={hex(int(dut.uo_out.value))}")

    dut._log.info("PASS: different challenges")
