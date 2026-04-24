# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


async def reset_dut(dut):
    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value  = 1
    await ClockCycles(dut.clk, 2)


@cocotb.test()
async def test_reset(dut):
    """After reset, done flag must be 0"""
    dut._log.info("Test: reset")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset_dut(dut)
    assert ((int(dut.uo_out.value) >> 1) & 1) == 0, "done should be 0 after reset"
    dut._log.info("PASS: reset")


@cocotb.test()
async def test_evaluation_completes(dut):
    """After ~1001 cycles, done should pulse high"""
    dut._log.info("Test: evaluation completes")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset_dut(dut)

    dut.ui_in.value = 0x12
    # Wait 1010 cycles for evaluation window + latency
    await ClockCycles(dut.clk, 1010)

    done = (int(dut.uo_out.value) >> 1) & 1
    assert done == 1, "Done flag never went high"
    resp = int(dut.uo_out.value) & 1
    dut._log.info(f"Challenge 0x12 response: {resp}")
    dut._log.info("PASS: evaluation completes")


@cocotb.test()
async def test_multiple_evaluations(dut):
    """Multiple sequential evaluations should each complete"""
    dut._log.info("Test: multiple evaluations")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset_dut(dut)

    for ch in [0x00, 0x12, 0x34, 0x56, 0xFF]:
        dut.ui_in.value = ch
        await ClockCycles(dut.clk, 1010)
        done = (int(dut.uo_out.value) >> 1) & 1
        assert done == 1, f"Done never went high for challenge {hex(ch)}"
        out = int(dut.uo_out.value)
        dut._log.info(f"Challenge {hex(ch)}: uo_out={out:#010b}")
        # Re-trigger: change challenge and wait again
        dut.rst_n.value = 0
        await ClockCycles(dut.clk, 3)
        dut.rst_n.value = 1
        await ClockCycles(dut.clk, 2)

    dut._log.info("PASS: multiple evaluations")
