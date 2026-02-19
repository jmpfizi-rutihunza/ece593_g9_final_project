Milestone-2 — Class Based Verification Environment

This folder contains the complete class-based testbench used to verify the DUT.

Components implemented:

- Interface (intf.sv)
- Transaction class (transaction.sv)
- Generator (generator.sv)
- Driver (driver.sv)
- Input Monitor (monitor_in.sv)
- Output Monitor (monitor_out.sv)
- Scoreboard (scoreboard.sv)
- Functional Coverage (coverage.sv)
- Environment (environment.sv)
- Top Testbench (tb_top.sv)

The testbench verifies:
- Read/Write functionality
- Transaction flow through all components
- Scoreboard matching
- Functional coverage collection

Simulation:
Compile and run from MS2 root:

vdel -lib work -all
vlib work
vlog -sv -mfcu -cover bcesf rtl/mp_dut.sv CLASS_TB/*.sv
vsim -coverage work.tb_top
run -all

Coverage:
Functional and code coverage reports are generated.
