# ============================================================
# ECE-593 Group 9 — Milestone 5 Simulation Script
# run_ms5.do
# Tested with: QuestaSim 2025.2_1 (built-in UVM 1.1d)
#
# Usage:
#   1. Launch QuestaSim
#   2. cd to Multiprocessor_System_MS5_UVM/
#   3. do UVM_TB/run_ms5.do
# ============================================================

quit -sim
if {[file exists work]} { vdel -all }
if {![file exists doc]} { file mkdir doc }

vlib work

# ============================================================
# PROC: compile golden RTL + full TB
# ============================================================
proc compile_golden {} {
    vlog -sv -suppress 2583 \
        +incdir+UVM_TB \
        UVM_TB/interface.sv

    vlog -sv -suppress 2583 \
        +cover=bcst \
        +incdir+UVM_TB \
        rtl/mp_dut.sv

    vlog -sv -suppress 2583 \
        +cover=bcst \
        +incdir+UVM_TB \
        UVM_TB/tb_top.sv
}

# ============================================================
# PROC: compile a buggy RTL + bug testbench top
# ============================================================
proc compile_bug {rtl_file} {
    vlog -sv -suppress 2583 \
        +incdir+UVM_TB \
        UVM_TB/interface.sv

    vlog -sv -suppress 2583 \
        +cover=bcst \
        +incdir+UVM_TB \
        $rtl_file

    vlog -sv -suppress 2583 \
        +cover=bcst \
        +incdir+UVM_TB \
        UVM_TB/tb_top_bug.sv
}

# ============================================================
# TEST 1: Coverage Closure Test (golden DUT)
# ============================================================
compile_golden

vsim -c -voptargs=+acc -coverage -sv_seed random \
     tb_top \
     +UVM_TESTNAME=mp_coverage_test \
     +UVM_VERBOSITY=UVM_LOW \
     -l doc/mp_coverage_test.log \
     -do "run -all; coverage save doc/mp_coverage_test.ucdb; quit -sim"

# ============================================================
# TEST 2: Dynamic ALU Stress Test (golden DUT)
# ============================================================
if {[file exists work]} { vdel -all }
vlib work
compile_golden

vsim -c -voptargs=+acc -coverage -sv_seed random \
     tb_top \
     +UVM_TESTNAME=mp_alu_test \
     +UVM_VERBOSITY=UVM_LOW \
     -l doc/mp_alu_test.log \
     -do "run -all; coverage save doc/mp_alu_test.ucdb; quit -sim"

# ============================================================
# BUG TEST 1: ADD returns A-B instead of A+B
# ============================================================
if {[file exists work]} { vdel -all }
vlib work
compile_bug rtl/mp_dut_bug1.sv

vsim -c -voptargs=+acc -coverage -sv_seed random \
     tb_top \
     +UVM_TESTNAME=mp_bug1_test \
     +UVM_VERBOSITY=UVM_LOW \
     -l doc/bug1_test.log \
     -do "run -all; coverage save doc/bug1_test.ucdb; quit -sim"

# ============================================================
# BUG TEST 2: SHR and SHL opcodes swapped
# ============================================================
if {[file exists work]} { vdel -all }
vlib work
compile_bug rtl/mp_dut_bug2.sv

vsim -c -voptargs=+acc -coverage -sv_seed random \
     tb_top \
     +UVM_TESTNAME=mp_bug2_test \
     +UVM_VERBOSITY=UVM_LOW \
     -l doc/bug2_test.log \
     -do "run -all; coverage save doc/bug2_test.ucdb; quit -sim"

# ============================================================
# BUG TEST 3: STORE never writes to memory
# ============================================================
if {[file exists work]} { vdel -all }
vlib work
compile_bug rtl/mp_dut_bug3.sv

vsim -c -voptargs=+acc -coverage -sv_seed random \
     tb_top \
     +UVM_TESTNAME=mp_bug3_test \
     +UVM_VERBOSITY=UVM_LOW \
     -l doc/bug3_test.log \
     -do "run -all; coverage save doc/bug3_test.ucdb; quit -sim"

# ============================================================
# MERGE ALL COVERAGE + GENERATE REPORTS
# ============================================================
vcover merge doc/mp_total.ucdb \
    doc/mp_coverage_test.ucdb \
    doc/mp_alu_test.ucdb \
    doc/bug1_test.ucdb \
    doc/bug2_test.ucdb \
    doc/bug3_test.ucdb

vcover report -html \
    -output doc/html_coverage \
    doc/mp_total.ucdb

vcover report -detail \
    -output doc/coverage_summary_TOTAL.txt \
    doc/mp_total.ucdb

vcover report -details -cvg \
    -output doc/func_cov_report_TOTAL.txt \
    doc/mp_total.ucdb

vcover report -details -codeall \
    -output doc/code_cov_report_TOTAL.txt \
    doc/mp_total.ucdb

echo ""
echo "====================================================="
echo " ECE-593 G9 Milestone 5 — All Tests Complete"
echo " Logs:     doc/*.log"
echo " Coverage: doc/mp_total.ucdb  doc/html_coverage/"
echo "====================================================="
