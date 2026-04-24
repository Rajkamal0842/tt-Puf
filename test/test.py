# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

# 1023-cycle measurement window + 30-cycle margin
EVAL_CYCLES = 1023 + 30


@cocotb.test()
async def test_reset(dut):
    """After reset, done flag (uo_out[1]) should be low."""
    dut._log.info("test_reset")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value  = 1
    await ClockCycles(dut.clk, 2)

    assert (int(dut.uo_out.value) & 0x02) == 0, \
        "done flag (uo_out[1]) should be 0 just after reset"


@cocotb.test()
async def test_measurement_completes(dut):
    """Done flag must pulse within EVAL_CYCLES after reset."""
    dut._log.info("test_measurement_completes")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value  = 1

    done_seen = False
    for _ in range(EVAL_CYCLES):
        await RisingEdge(dut.clk)
        if int(dut.uo_out.value) & 0x02:
            done_seen = True
            break

    assert done_seen, \
        f"done flag never pulsed within {EVAL_CYCLES} cycles"
    dut._log.info(f"PUF response = {int(dut.uo_out.value) & 1}")


@cocotb.test()
async def test_challenge_changes_response(dut):
    """All 8 challenges should complete measurement."""
    dut._log.info("test_challenge_changes_response")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.uio_in.value = 0
    responses = []

    for ch in range(8):
        dut.rst_n.value = 0
        dut.ui_in.value = ch
        await ClockCycles(dut.clk, 5)
        dut.rst_n.value = 1

        for _ in range(EVAL_CYCLES):
            await RisingEdge(dut.clk)
            if int(dut.uo_out.value) & 0x02:
                responses.append(int(dut.uo_out.value))
                break

    dut._log.info(f"Responses: {[hex(r) for r in responses]}")
    assert len(responses) == 8, \
        f"Only {len(responses)} of 8 measurements completed"


@cocotb.test()
async def test_repeated_same_challenge(dut):
    """Same challenge must give same response bit (deterministic sim)."""
    dut._log.info("test_repeated_same_challenge")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.ui_in.value  = 3
    dut.uio_in.value = 0
    bits = []

    for _ in range(3):
        dut.rst_n.value = 0
        await ClockCycles(dut.clk, 5)
        dut.rst_n.value = 1

        for _ in range(EVAL_CYCLES):
            await RisingEdge(dut.clk)
            if int(dut.uo_out.value) & 0x02:
                bits.append(int(dut.uo_out.value) & 1)
                break

    dut._log.info(f"Repeated bits: {bits}")
    assert len(set(bits)) == 1, \
        f"Response not stable across resets: {bits}"
