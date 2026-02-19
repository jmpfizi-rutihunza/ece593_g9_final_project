# ECE 593 Multiprocessor system project
quit -sim

vlib work
vmap work work

# Compile
vlog -cover bcst ./intf.sv ./mp_dut.sv ./tb_top.sv

# Optimize with Coverage and Access
vopt tb_top -o top_opt +acc -cover sbc

# Simulate
vsim top_opt -coverage

# adds the interface signals to the wave window
#add wave -position insertpoint sim:/top/vif/*
add wave -position insertpoint sim:/tb_top/vif/*

# Run
run -all

#Coverage Reporting
coverage report -detail -cvg -output functional_coverage_report.txt
coverage report -summary