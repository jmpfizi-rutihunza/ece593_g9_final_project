# ============================================================
# SETUP & COMPILATION 
# ============================================================
quit -sim
if [file exists work] { vdel -all }
vlib work
vmap uvm C:/questasim64_2025.2_1/uvm-1.1d

.main clear

vlog +cover=bcst +incdir+. interface.sv
vlog +cover=bcst +incdir+. mp_dut.sv 
vlog +incdir+C:/questasim64_2025.2_1/verilog_src/uvm-1.1d/src +incdir+. tb_top.sv

# ============================================================
# RUN TEST 1: Directed Test (mp_test)
# ============================================================
# -l directs the console output to a log file
vsim -c -voptargs="+acc" -coverage -L uvm tb_top +UVM_TESTNAME=mp_test -l mp_test.log
run -all
coverage save mp_test.ucdb
quit -sim

# ============================================================
# RUN TEST 2: Dynamic Stress Test (mp_alu_test)
# ============================================================
# We leave the '-c' off if you want to see the waveforms for this one
vsim -voptargs="+acc" -coverage -L uvm tb_top +UVM_TESTNAME=mp_alu_test -l mp_alu_test.log

# Setup Waveforms for the Stress Test
add wave -position insertpoint sim:/tb_top/intf/*
add wave -position insertpoint sim:/tb_top/dut/*

run -all
coverage save mp_alu_test.ucdb

# ============================================================
# MERGE & GENERATE REPORTS
# ============================================================
# Merge both test results into one master coverage file
vcover merge mp_total.ucdb mp_test.ucdb mp_alu_test.ucdb

# Generate reports from the MERGED data
vcover report -html mp_total.ucdb
vcover report -detail -output coverage_summary_TOTAL.txt mp_total.ucdb
vcover report -details -cvg -output func_cov_report_TOTAL.txt mp_total.ucdb
vcover report -details -codeall -output code_cov_report_TOTAL.txt mp_total.ucdb


