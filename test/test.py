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
    for _ in range(timeout):
        await RisingEdge(dut.clk)
        if (int(dut.uo_out.value) >> 1) & 1:
            return True
    return False


@cocotb.test()
async def test_reset(dut):
    """After reset, done flag must be 0"""
    dut._log.info("Test: reset")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset_dut(dut)
    assert ((int(dut.uo_out.value) >> 1) & 1) == 0, "done should be 0 after reset"
    dut._log.info("PASS: reset")


@cocotb.test()
async def test_single_challenge(dut):
    """Apply one challenge, wait for done, read response"""
    dut._log.info("Test: single challenge 0x12")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset_dut(dut)

    dut.ui_in.value = 0x12
    ok = await wait_done(dut)
    assert ok, "Timeout: done never went high for challenge 0x12"

    resp = int(dut.uo_out.value) & 1
    dut._log.info(f"Response for 0x12: {resp}")
    dut._log.info("PASS: single challenge")


@cocotb.test()
async def test_multiple_challenges(dut):
    """Cycle through 4 challenges and check done fires each time"""
    dut._log.info("Test: multiple challenges")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset_dut(dut)

    challenges = [0x12, 0x34, 0x56, 0x78]
    for ch in challenges:
        dut.ui_in.value = ch
        ok = await wait_done(dut)
        assert ok, f"Timeout for challenge {hex(ch)}"
        resp = int(dut.uo_out.value) & 1
        dut._log.info(f"Challenge {hex(ch)} -> response {resp}")

    dut._log.info("PASS: multiple challenges")


@cocotb.test()
async def test_same_challenge_no_retrigger(dut):
    """Same challenge value should NOT retrigger (done stays 0 after first)"""
    dut._log.info("Test: same challenge no retrigger")
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset_dut(dut)

    dut.ui_in.value = 0xAB
    ok = await wait_done(dut)
    assert ok, "First evaluation never completed"

    # Keep same challenge — done should NOT fire again within 20 cycles
    await ClockCycles(dut.clk, 20)
    assert ((int(dut.uo_out.value) >> 1) & 1) == 0, \
        "done re-fired on same challenge — should not happen"
    dut._log.info("PASS: same challenge no retrigger")
