# run.do - Milestone 1 (Traditional Testbench)

transcript on
set NoQuitOnFinish 1

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Compile RTL
vlog -sv ../rtl/generator.sv
vlog -sv ../rtl/mp_top.sv

# Compile Testbench
vlog -sv mp_top_tb.sv

# Simulate
vsim -c work.mp_top_tb
run -all
quit -f
