import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


async def wait_for_done(dut, timeout_cycles=400):
    """Wait for uo_out[1] (done flag) to go high. Returns True if seen."""
    for _ in range(timeout_cycles):
        await RisingEdge(dut.clk)
        if int(dut.uo_out.value) & 0x02:
            return True
    return False


# ---------------------------------------------------------------------------
# Test 1 – smoke: design runs 300 cycles without crashing (RTL + GL)
# ---------------------------------------------------------------------------
@cocotb.test()
async def test_puf_smoke(dut):
    """Smoke test: design initialises and runs without errors."""
    clock = Clock(dut.clk, 20, unit="ns")   # 50 MHz
    cocotb.start_soon(clock.start())

    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 300)

    dut._log.info(
        f"SMOKE PASSED — uo_out=0x{int(dut.uo_out.value):02X}"
    )


# ---------------------------------------------------------------------------
# Test 2 – done flag asserts within 250 cycles after reset
# ---------------------------------------------------------------------------
@cocotb.test()
async def test_puf_done_flag(dut):
    """Done flag (uo_out[1]) must pulse within 250 cycles of reset release."""
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())

    dut.ui_in.value  = 0x1E   # RO_A=14, RO_B=1 — different oscillators
    dut.uio_in.value = 0
    dut.ena.value    = 1

    # Reset — FSM inits challenge_prev=0xFF so any challenge triggers immediately
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    done = await wait_for_done(dut, timeout_cycles=250)
    assert done, "Done flag (uo_out[1]) never asserted within 250 cycles!"

    response = int(dut.uo_out.value) & 0x01
    dut._log.info(f"DONE FLAG PASSED — response={response}")


# ---------------------------------------------------------------------------
# Test 3 – multiple challenges each produce a done pulse
# ---------------------------------------------------------------------------
@cocotb.test()
async def test_puf_multiple_challenges(dut):
    """Each new challenge must trigger the FSM and assert done."""
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())

    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # First evaluation fires automatically after reset (challenge_prev = 0xFF)
    done = await wait_for_done(dut, timeout_cycles=250)
    assert done, "Done flag never asserted after reset!"
    dut._log.info(f"Challenge 0x{int(dut.ui_in.value):02X} -> response={int(dut.uo_out.value)&1}")

    # Now cycle through explicit challenges
    challenges = [0x12, 0x57, 0xAB, 0xF0, 0x33]
    for ch in challenges:
        await ClockCycles(dut.clk, 5)   # short gap between challenges
        dut.ui_in.value = ch
        done = await wait_for_done(dut, timeout_cycles=250)
        assert done, f"Done flag never asserted for challenge 0x{ch:02X}!"
        response = int(dut.uo_out.value) & 0x01
        dut._log.info(f"Challenge 0x{ch:02X} -> response={response}")

    dut._log.info("MULTIPLE CHALLENGES PASSED")
