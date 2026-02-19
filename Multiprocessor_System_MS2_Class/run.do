transcript on
set NoQuitOnFinish 1

# Create library
if {[file exists work]} { vdel -lib work -all }
vlib work

# Compile (single compilation unit + coverage)
vlog -sv -mfcu -cover bcesf \
rtl/mp_dut.sv \
CLASS_TB/intf.sv \
CLASS_TB/transaction.sv \
CLASS_TB/coverage.sv \
CLASS_TB/generator.sv \
CLASS_TB/driver.sv \
CLASS_TB/monitor_in.sv \
CLASS_TB/monitor_out.sv \
CLASS_TB/scoreboard.sv \
CLASS_TB/environment.sv \
CLASS_TB/tb_top.sv

# Simulate with coverage
vsim -coverage work.tb_top

# Run
run -all

# Save coverage database
coverage save sim.ucdb

# Reports
vcover report -details sim.ucdb > func_cov.txt
vcover report -details -code bcesf sim.ucdb > code_cov.txt

echo "MS2 simulation completed"
