# ECE 593 Multiprocessor system project
quit -sim

vlib work
vmap work work

# =============================
# Compile package first
# =============================
vlog -sv -cover bcst tb_pkg.sv

# =============================
# Compile environment (it includes the TB class files)
# environment.sv must include:
#   generator.sv, driver.sv, monitor_in.sv, monitor_out.sv, scoreboard.sv
# =============================
vlog -sv -cover bcst environment.sv

# =============================
# Compile interface + DUT + top
# =============================
vlog -sv -cover bcst intf.sv
vlog -sv -cover bcst mp_dut.sv
vlog -sv -cover bcst tb_top.sv

# =============================
# Optimize with Coverage
# =============================
vopt tb_top -o top_opt +acc -cover sbc

# =============================
# Simulate
# =============================
vsim top_opt -coverage

# Waves
add wave -position insertpoint sim:/tb_top/vif/*

# Run
run -all

# Coverage report
coverage report -detail -cvg -output functional_coverage_report.txt
coverage report -summary
