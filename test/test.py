# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def reset_dut(dut):
    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value  = 1
    await ClockCycles(dut.clk, 2)


@cocotb.test()
async def test_reset_clears_outputs(dut):
    """Immediately after reset, done flag must be 0"""
    dut._log.info("Test: reset clears outputs")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset_dut(dut)
    # done is uo_out[1]
    done = (int(dut.uo_out.value) >> 1) & 1
    assert done == 0, f"done should be 0 right after reset, got {done}"
    dut._log.info("PASS: reset clears outputs")


@cocotb.test()
async def test_evaluation_completes(dut):
    """After reset+release, FSM auto-starts; done goes high after ~1001 cycles"""
    dut._log.info("Test: evaluation completes within 1010 cycles")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())

    dut.ui_in.value = 0x25   # choose a specific challenge
    await reset_dut(dut)

    # Wait 1010 cycles for 1000-cycle window + margin
    await ClockCycles(dut.clk, 1010)

    done = (int(dut.uo_out.value) >> 1) & 1
    assert done == 1, "Done flag never went high after 1010 cycles"
    resp = int(dut.uo_out.value) & 1
    dut._log.info(f"Challenge 0x25 -> puf_resp={resp}, uo_out={int(dut.uo_out.value):#010b}")
    dut._log.info("PASS: evaluation completes")


@cocotb.test()
async def test_done_clears_and_restarts(dut):
    """After done, FSM restarts automatically; done goes low then high again"""
    dut._log.info("Test: done clears and FSM restarts")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())

    dut.ui_in.value = 0x12
    await reset_dut(dut)

    # First evaluation
    await ClockCycles(dut.clk, 1010)
    done = (int(dut.uo_out.value) >> 1) & 1
    assert done == 1, "First done never went high"

    # After done, FSM goes back to idle then immediately restarts
    # done should clear within a few cycles
    await ClockCycles(dut.clk, 5)
    done_after = (int(dut.uo_out.value) >> 1) & 1
    assert done_after == 0, "done should clear after FSM restarts"

    dut._log.info("PASS: done clears and FSM restarts")


@cocotb.test()
async def test_different_challenges_give_outputs(dut):
    """Different ui_in values produce outputs without hanging"""
    dut._log.info("Test: different challenges")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())

    for ch in [0x00, 0xFF, 0xA5, 0x3C]:
        dut.ui_in.value = ch
        await reset_dut(dut)
        await ClockCycles(dut.clk, 1010)
        done = (int(dut.uo_out.value) >> 1) & 1
        assert done == 1, f"Done never went high for challenge {hex(ch)}"
        out = int(dut.uo_out.value)
        dut._log.info(f"challenge={hex(ch)} uo_out={out:#010b}")

    dut._log.info("PASS: different challenges")
