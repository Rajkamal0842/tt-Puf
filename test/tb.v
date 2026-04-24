import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_puf_enhanced(dut):
    dut._log.info("Start Enhanced PUF Test")
    
    # Setup clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Resetting...")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Test several challenges
    challenges = [0x00, 0x1F, 0x55, 0xAA, 0xFF]
    
    for chal in challenges:
        dut.ui_in.value = chal
        dut._log.info(f"Applying Challenge: {hex(chal)}")
        
        # Wait for the 1000-cycle evaluation + some margin
        await ClockCycles(dut.clk, 1100)
        
        # Check if done signal is high
        if dut.uo_out[1].value == 1:
            res = dut.uo_out[0].value
            dut._log.info(f"Challenge {hex(chal)} -> Response: {res}")
        else:
            dut._log.error(f"PUF failed to complete for challenge {hex(chal)}")

    dut._log.info("Enhanced PUF Test Completed")
