# ==============================================================
#  ECE-593 Group 9 — Milestone 5
#  run.do — based on the original working run_ms5.do structure
#
#  Run from: Multiprocessor_System_MS5_UVM/
#  Usage:    do UVM_TB/run.do
# ==============================================================

quit -sim
if {[file exists work]} { vdel -all }
if {![file exists doc]} { file mkdir doc }
vlib work

# ============================================================
# PROC: compile with given BUG_SELECT (0=clean, 1/2/3=bug)
# ============================================================
proc compile_tb {bug_num} {
    vlog -sv -suppress 2583 \
        +incdir+UVM_TB \
        UVM_TB/interface.sv

    vlog -sv -suppress 2583 \
        +cover=bces \
        +define+BUG_SELECT_$bug_num \
        +incdir+UVM_TB \
        rtl/mp_dut_demo.sv

    vlog -sv -suppress 2583 \
        +cover=bces \
        +incdir+UVM_TB \
        UVM_TB/tb_top_bug.sv
}

# ============================================================
# TEST 1: Coverage Closure Test (clean DUT)
# ============================================================
compile_tb 0

vsim -c -voptargs=+acc -coverage -sv_seed random -onfinish stop \
     tb_top \
     +UVM_TESTNAME=mp_coverage_test \
     +UVM_VERBOSITY=UVM_LOW \
     -l doc/mp_coverage_test.log \
     -do "run -all; coverage save doc/mp_coverage_test.ucdb; quit -sim"

# ============================================================
# TEST 2: ALU Stress Test (clean DUT)
# ============================================================
if {[file exists work]} { vdel -all }
vlib work
compile_tb 0

vsim -c -voptargs=+acc -coverage -sv_seed random -onfinish stop \
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
compile_tb 1

vsim -c -voptargs=+acc -coverage -sv_seed random -onfinish stop \
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
compile_tb 2

vsim -c -voptargs=+acc -coverage -sv_seed random -onfinish stop \
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
compile_tb 3

vsim -c -voptargs=+acc -coverage -sv_seed random -onfinish stop \
     tb_top \
     +UVM_TESTNAME=mp_bug3_test \
     +UVM_VERBOSITY=UVM_LOW \
     -l doc/bug3_test.log \
     -do "run -all; coverage save doc/bug3_test.ucdb; quit -sim"

# ============================================================
# MERGE ALL 5 UCDBs + GENERATE REPORTS
# ============================================================
vcover merge doc/ms5_total.ucdb \
    doc/mp_coverage_test.ucdb \
    doc/mp_alu_test.ucdb \
    doc/bug1_test.ucdb \
    doc/bug2_test.ucdb \
    doc/bug3_test.ucdb

vcover report -html \
    -output doc/html_coverage \
    doc/ms5_total.ucdb

vcover report -details -cvg \
    -output doc/func_cov_report_TOTAL.txt \
    doc/ms5_total.ucdb

vcover report -details -codeall \
    -output doc/code_cov_report_TOTAL.txt \
    doc/ms5_total.ucdb

vcover report \
    -output doc/coverage_summary_TOTAL.txt \
    doc/ms5_total.ucdb

echo ""
echo "============================================================"
echo " ECE-593 G9 Milestone 5 — All 5 Tests Complete"
echo ""
echo "  Logs:"
echo "    doc/mp_coverage_test.log   (clean DUT)"
echo "    doc/mp_alu_test.log        (clean DUT — stress)"
echo "    doc/bug1_test.log          (Bug 1: ADD)"
echo "    doc/bug2_test.log          (Bug 2: SHIFT)"
echo "    doc/bug3_test.log          (Bug 3: STORE)"
echo ""
echo "  Coverage:"
echo "    doc/ms5_total.ucdb"
echo "    doc/html_coverage/index.html"
echo "    doc/func_cov_report_TOTAL.txt"
echo "============================================================"
