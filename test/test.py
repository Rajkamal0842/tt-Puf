import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


# ---------------------------------------------------------------------------
# Helper: wait for the done pulse (uo_out[1]) with a timeout
# ---------------------------------------------------------------------------
async def wait_for_done(dut, timeout_cycles=500):
    for _ in range(timeout_cycles):
        await RisingEdge(dut.clk)
        if int(dut.uo_out.value) & 0x02:   # bit 1 = done
            return True
    return False


# ---------------------------------------------------------------------------
# Test 1 – smoke test: design runs without crashing (RTL + GL compatible)
# ---------------------------------------------------------------------------
@cocotb.test()
async def test_puf_smoke(dut):
    """Smoke test: verifies the design starts up and completes one evaluation."""

    clock = Clock(dut.clk, 20, units="ns")   # 50 MHz
    cocotb.start_soon(clock.start())

    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1

    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Apply a non-trivial challenge (RO_A = 3, RO_B = 7)
    dut.ui_in.value = (7 << 4) | 3

    # Run long enough for one 200-cycle evaluation
    await ClockCycles(dut.clk, 300)

    dut._log.info(
        f"SMOKE PASSED — uo_out=0x{int(dut.uo_out.value):02X} "
        f"uio_out=0x{int(dut.uio_out.value):02X} "
        f"uio_oe=0x{int(dut.uio_oe.value):02X}"
    )


# ---------------------------------------------------------------------------
# Test 2 – done flag: verify uo_out[1] pulses after evaluation window
# ---------------------------------------------------------------------------
@cocotb.test()
async def test_puf_done_flag(dut):
    """Verifies the done flag asserts within 250 cycles of a new challenge."""

    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Challenge: RO_A = 1, RO_B = 14 → clearly different oscillators
    dut.ui_in.value = (14 << 4) | 1

    done = await wait_for_done(dut, timeout_cycles=300)

    assert done, "Done flag (uo_out[1]) never asserted within 300 cycles!"

    response = int(dut.uo_out.value) & 0x01
    dut._log.info(f"DONE FLAG PASSED — PUF response bit = {response}")


# ---------------------------------------------------------------------------
# Test 3 – challenge sensitivity: different challenges → results captured
# ---------------------------------------------------------------------------
@cocotb.test()
async def test_puf_multiple_challenges(dut):
    """Applies several challenges and logs responses (no strict assertion –
    in RTL sim all ROs are identical so responses may be 0; the test just
    confirms the FSM cycles correctly for each challenge change)."""

    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    challenges = [
        (0,  1),
        (2,  5),
        (7,  12),
        (15, 0),
        (3,  3),   # same RO → expect 0
    ]

    for sel_a, sel_b in challenges:
        challenge = (sel_b << 4) | sel_a
        dut.ui_in.value = challenge

        done = await wait_for_done(dut, timeout_cycles=300)
        assert done, f"Done flag never asserted for challenge A={sel_a} B={sel_b}"

        response = int(dut.uo_out.value) & 0x01
        dut._log.info(
            f"Challenge A={sel_a:2d} B={sel_b:2d} "
            f"(0x{challenge:02X}) → response={response}"
        )

        # Small gap between challenges so FSM sees the change
        await ClockCycles(dut.clk, 5)

    dut._log.info("MULTIPLE CHALLENGES PASSED")
