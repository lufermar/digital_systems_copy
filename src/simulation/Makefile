VERILOG_SOURCES = $(PWD)/../AdcReader.sv
# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file:
TOPLEVEL=AdcReader
# MODULE is the name of the Python test file:
MODULE=AdcReaderTest


# use the Verilator for simulation
SIM=verilator
# set the timing precision (for performance reasons)
COCOTB_HDL_TIMEPRECISION = 100ps
# Tell it to trace the result
EXTRA_ARGS += --trace --trace-structs


include $(shell cocotb-config --makefiles)/Makefile.sim

