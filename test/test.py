import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

async def wait_for_done(dut, timeout_cycles=400):
    for _ in range(timeout_cycles):
        await RisingEdge(dut.clk)
        if int(dut.uo_out.value) & 0x02:
            return True
    return False

@cocotb.test()
async def test_puf_smoke(dut):
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1
    await ClockCycles(dut.clk, 300)
    dut._log.info(f"SMOKE PASSED — uo_out=0x{int(dut.uo_out.value):02X}")

@cocotb.test()
async def test_puf_done_flag(dut):
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())
    dut.ui_in.value  = 0x1E
    dut.uio_in.value = 0
    dut.ena.value    = 1
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1
    done = await wait_for_done(dut, timeout_cycles=250)
    assert done, "Done flag (uo_out[1]) never asserted within 250 cycles!"
    dut._log.info(f"DONE FLAG PASSED — response={int(dut.uo_out.value) & 1}")

@cocotb.test()
async def test_puf_multiple_challenges(dut):
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1
    done = await wait_for_done(dut, timeout_cycles=250)
    assert done, "Done flag never asserted after reset!"
    for ch in [0x12, 0x57, 0xAB, 0xF0, 0x33]:
        await ClockCycles(dut.clk, 5)
        dut.ui_in.value = ch
        done = await wait_for_done(dut, timeout_cycles=250)
        assert done, f"Done flag never asserted for challenge 0x{ch:02X}!"
        dut._log.info(f"Challenge 0x{ch:02X} -> response={int(dut.uo_out.value) & 1}")
    dut._log.info("MULTIPLE CHALLENGES PASSED")
