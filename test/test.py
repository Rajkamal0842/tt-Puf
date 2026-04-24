import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

# Helper function to wait for the DONE flag (uo_out[1])
async def wait_for_done(dut, timeout_cycles=1200):
    for _ in range(timeout_cycles):
        await RisingEdge(dut.clk)
        # Check if uo_out[1] is high (0x02)
        if int(dut.uo_out.value) & 0x02:
            return True
    return False

@cocotb.test()
async def test_puf_smoke(dut):
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())
    
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1
    dut.rst_n.value  = 0
    
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1
    
    # Wait for the full evaluation window (1000 cycles) + margin
    await ClockCycles(dut.clk, 1100)
    dut._log.info(f"SMOKE PASSED — uo_out=0x{int(dut.uo_out.value):02X}")

@cocotb.test()
async def test_puf_done_flag(dut):
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())
    
    dut.ui_in.value  = 0x1E
    dut.uio_in.value = 0
    dut.ena.value    = 1
    dut.rst_n.value  = 0
    
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1
    
    # Updated timeout to 1200 for your 1000-cycle logic
    done = await wait_for_done(dut, timeout_cycles=1200)
    assert done, "Done flag (uo_out[1]) never asserted within 1200 cycles!"
    dut._log.info(f"DONE FLAG PASSED — response={int(dut.uo_out.value) & 1}")

@cocotb.test()
async def test_puf_multiple_challenges(dut):
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())
    
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1
    dut.rst_n.value  = 0
    
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1
    
    # Initial wait after reset
    done = await wait_for_done(dut, timeout_cycles=1200)
    assert done, "Done flag never asserted after reset!"
    
    # Loop through multiple challenges
    for ch in [0x12, 0x57, 0xAB, 0xF0, 0x33]:
        await ClockCycles(dut.clk, 5)
        dut.ui_in.value = ch
        
        # Each challenge needs its own 1000-cycle window
        done = await wait_for_done(dut, timeout_cycles=1200)
        assert done, f"Done flag never asserted for challenge 0x{ch:02X}!"
        
        response = int(dut.uo_out.value) & 1
        dut._log.info(f"Challenge 0x{ch:02X} -> response={response}")
        
    dut._log.info("MULTIPLE CHALLENGES PASSED")
