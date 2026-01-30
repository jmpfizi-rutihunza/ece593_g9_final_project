# run.do

transcript on
set NoQuitOnFinish 1

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

vlog -sv generator.sv
vlog -sv mp_top.sv
vlog -sv mp_top_tb.sv

vsim -c work.mp_top_tb
run -all