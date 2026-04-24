# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

@cocotb.test()
async def test_puf_reset(dut):
    """Test reset behaviour"""
    dut._log.info("Start: PUF reset test")
    clock = Clock(dut.clk, 20, unit="ns")   # 50 MHz
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value  = 1
    await ClockCycles(dut.clk, 2)

    # After reset, done should be 0
    assert dut.uo_out.value[6] == 0, "done should be 0 after reset"
    dut._log.info("Reset test passed")


@cocotb.test()
async def test_puf_response(dut):
    """Apply a challenge, wait for done, read response"""
    dut._log.info("Start: PUF response test")
    clock = Clock(dut.clk, 20, unit="ns")   # 50 MHz
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value  = 1
    await ClockCycles(dut.clk, 2)

    # Apply challenge 0x12 (RO_A = 2, RO_B group from upper nibble)
    dut.ui_in.value = 0x12
    dut._log.info("Challenge applied: 0x12")

    # Wait up to 1100 cycles for done pulse
    for _ in range(1100):
        await RisingEdge(dut.clk)
        # uo_out[1] is done flag (bit index 6 in cocotb 8-bit value)
        if (int(dut.uo_out.value) >> 1) & 1:
            break

    done = (int(dut.uo_out.value) >> 1) & 1
    assert done == 1, "Done flag never went high!"

    response = int(dut.uo_out.value) & 1
    dut._log.info(f"PUF response for challenge 0x12: {response}")
    dut._log.info("Response test passed")


@cocotb.test()
async def test_puf_two_challenges(dut):
    """Test that changing challenge triggers a new evaluation"""
    dut._log.info("Start: Two-challenge test")
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value  = 1
    await ClockCycles(dut.clk, 2)

    for challenge in [0x12, 0x34]:
        dut.ui_in.value = challenge
        dut._log.info(f"Challenge: {hex(challenge)}")
        for _ in range(1100):
            await RisingEdge(dut.clk)
            if (int(dut.uo_out.value) >> 1) & 1:
                break
        done = (int(dut.uo_out.value) >> 1) & 1
        assert done == 1, f"Done never went high for challenge {hex(challenge)}"
        resp = int(dut.uo_out.value) & 1
        dut._log.info(f"Response: {resp}")

    dut._log.info("Two-challenge test passed")
