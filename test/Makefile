# Makefile for tt_um_puf cocotb simulation
# Mirrors the structure of the Tiny Tapeout Rule-30 reference project.

SIM           ?= icarus
TOPLEVEL_LANG ?= verilog
TOPLEVEL       = tb
MODULE         = test

COCOTB_RESULTS_FILE      = results.xml
COCOTB_HDL_TIMEUNIT      = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

SRC_DIR = $(PWD)/../src

ifneq ($(GATES),yes)
# ── RTL simulation ────────────────────────────────────────────────────────────
VERILOG_SOURCES  = $(SRC_DIR)/tt_um_puf.v
VERILOG_SOURCES += $(PWD)/tb.v
COMPILE_ARGS    += -g2012

else
# ── Gate-Level simulation ─────────────────────────────────────────────────────
COMPILE_ARGS += -g2012
COMPILE_ARGS += -DGL_TEST
COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DSIM
COMPILE_ARGS += -DUNIT_DELAY=\#1
COMPILE_ARGS += -DUSE_POWER_PINS
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
VERILOG_SOURCES += gate_level_netlist.v
VERILOG_SOURCES += $(PWD)/tb.v
export GL_TEST = 1
endif

include $(shell cocotb-config --makefiles)/Makefile.sim
