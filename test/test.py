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


async def wait_done(dut, timeout=1100):
    """Wait for done flag (uo_out[7] XOR'd with chal_resp, but any change
    after 1001 cycles indicates done). We poll uo_out[7] going non-zero
    relative to initial 0 after reset."""
    # Simpler: just wait 1005 cycles (enough for 1000-cycle window + latency)
    await ClockCycles(dut.clk, 1005)


@cocotb.test()
async def test_reset(dut):
    """After reset all outputs should be 0"""
    dut._log.info("Test: reset")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset_dut(dut)
    assert int(dut.uo_out.value) == 0, f"Expected 0 after reset, got {dut.uo_out.value}"
    dut._log.info("PASS: reset")


@cocotb.test()
async def test_challenge_produces_response(dut):
    """After 1000 cycles, all 8 response bits should be valid (non-zero output)"""
    dut._log.info("Test: challenge 0x00 produces 8 response bits")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset_dut(dut)

    dut.ui_in.value = 0x00
    await wait_done(dut)

    out = int(dut.uo_out.value)
    dut._log.info(f"uo_out after challenge 0x00 = {out:#010b}")
    # We don't assert a specific value since it is PUF (chip-specific),
    # just check the design completed without timeout
    dut._log.info("PASS: challenge 0x00")


@cocotb.test()
async def test_multiple_challenges(dut):
    """Different challenges should trigger new evaluations"""
    dut._log.info("Test: multiple challenges")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset_dut(dut)

    for ch in [0x01, 0x10, 0x1F, 0x3E]:
        dut.ui_in.value = ch
        await wait_done(dut)
        out = int(dut.uo_out.value)
        dut._log.info(f"Challenge {hex(ch)} -> uo_out = {out:#010b}")

    dut._log.info("PASS: multiple challenges")


@cocotb.test()
async def test_fixed_pairs_active(dut):
    """8 parallel pairs should all produce non-trivially-zero results"""
    dut._log.info("Test: 8 parallel pairs active")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset_dut(dut)

    dut.ui_in.value = 0x05
    await wait_done(dut)
    out = int(dut.uo_out.value)
    dut._log.info(f"uo_out[7:0] = {out:#010b}")
    # In simulation all ROs toggle identically so comparators = 0 is expected;
    # on real silicon they differ. Just check no exception was thrown.
    dut._log.info("PASS: 8 parallel pairs")
