import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge
from cocotb.result import TestFailure


@cocotb.test()
async def AdcReaderTest(dut):
    """Try accessing the design."""

    # set up the clock
    clock = Clock(dut.clk_i, 20, units="ns")  # Create a 20ns period clock on port clk_i
    cocotb.fork(clock.start())  # Start the clock
    # Synchronize with the clock
    await FallingEdge(dut.clk_i)
    
    # set up the input signals and do a reset
    dut.spi_miso_i = 1
    dut.start_i = 0
    dut.reset_i = 1
    await FallingEdge(dut.clk_i)
    
    # switch off the reset
    dut.reset_i = 0
    await FallingEdge(dut.clk_i)
    
    # the data from the ADC should be:
    adcValue = 0xabcd
    
    # start transmission:
    dut.start_i = 1
    await FallingEdge(dut.cnv_o)
    for i in range(16):
        # put the MSB first
        dut.spi_miso_i = (adcValue >> (15-i)) & 1
        # wait 7.5ns after the falling edge of the spi clk (accorgind
        # to the data sheet of the ADC)
        await FallingEdge(dut.spi_clk_o)
        await Timer(7.5, "ns")
    
    # wait a bit, set the start to 0 and wait again...
    await Timer(100, "ns")
    dut.start_i = 0
    await Timer(100, "ns")
    
    # check if we got the correct result:
    if (dut.data_o != adcValue):
        raise TestFailure("Wrong result from reading out the ADC")
        
    
