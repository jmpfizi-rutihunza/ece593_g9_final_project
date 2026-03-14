# ==============================================================
#  ECE-593 Group 9 — Milestone 5
#  run.do  —  Unified Demo Script (BUG_SELECT version)
#
#  Works with:  mp_dut_demo.sv  (single file, `define BUG_SELECT)
#
#  QUICK USAGE (from Multiprocessor_System_MS5_UVM/ directory):
#
#    do UVM_TB/run.do                     — run all 4 modes automatically
#    do UVM_TB/run.do clean               — clean DUT only
#    do UVM_TB/run.do bug1                — Bug 1 only (ADD)
#    do UVM_TB/run.do bug2                — Bug 2 only (SHIFT)
#    do UVM_TB/run.do bug3                — Bug 3 only (STORE)
#
#  LIVE DEMO TIP:
#    Open mp_dut_demo.sv, change `define BUG_SELECT N, then:
#    do UVM_TB/run.do clean   (or bug1/bug2/bug3)
# ==============================================================

# ── Parse optional argument ────────────────────────────────────
set mode "all"
if { $argc >= 1 } { set mode [lindex $argv 0] }

# ── Helper: fresh compile workspace ───────────────────────────
proc fresh_lib {} {
    quit -sim
    if {[file exists work]} { vdel -all }
    if {![file exists doc]}  { file mkdir doc }
    vlib work
}

# ── Helper: compile interface + DUT (with BUG_SELECT N) + TB ──
proc compile_tb { bug_num } {
    # Interface (no coverage needed)
    vlog -sv -suppress 2583 \
        +incdir+UVM_TB \
        UVM_TB/interface.sv

    # RTL — override the define from the command line so the
    # automated run never needs to edit mp_dut_demo.sv.
    # BUG_SELECT_0 / _1 / _2 / _3 map to the ifdef blocks.
    vlog -sv -suppress 2583 \
        +cover=bcst \
        +define+BUG_SELECT_$bug_num \
        +incdir+UVM_TB \
        rtl/mp_dut_demo.sv

    # Testbench top (includes all UVM classes + bug_tests.sv)
    vlog -sv -suppress 2583 \
        +cover=bcst \
        +incdir+UVM_TB \
        UVM_TB/tb_top_bug.sv
}

# ── Helper: run one sim and save coverage ─────────────────────
proc run_sim { test_name log_name ucdb_name } {
    vsim -c \
        -voptargs=+acc \
        -coverage \
        -sv_seed random \
        tb_top \
        +UVM_TESTNAME=$test_name \
        +UVM_VERBOSITY=UVM_LOW \
        -l doc/$log_name \
        -do "run -all; coverage save doc/$ucdb_name; quit -sim"
}

# ==============================================================
#  RUN SELECTION
# ==============================================================

# ── CLEAN (BUG_SELECT 0) ──────────────────────────────────────
if { $mode eq "clean" || $mode eq "all" } {
    echo ""
    echo "============================================================"
    echo " CLEAN DUT  (BUG_SELECT 0 — no bug)"
    echo "============================================================"
    fresh_lib
    compile_tb 0
    run_sim mp_coverage_test mp_coverage_test.log mp_coverage_test.ucdb
    echo " >> Log:  doc/mp_coverage_test.log"
}

# ── BUG 1: ADD computes A-B instead of A+B ───────────────────
if { $mode eq "bug1" || $mode eq "all" } {
    echo ""
    echo "============================================================"
    echo " BUG 1  (BUG_SELECT 1 — ADD: A-B instead of A+B)"
    echo "============================================================"
    fresh_lib
    compile_tb 1
    run_sim mp_bug1_test bug1_test.log bug1_test.ucdb
    echo " >> Log:  doc/bug1_test.log"
}

# ── BUG 2: SHR/SHL directions swapped ───────────────────────
if { $mode eq "bug2" || $mode eq "all" } {
    echo ""
    echo "============================================================"
    echo " BUG 2  (BUG_SELECT 2 — SHR/SHL opcodes swapped)"
    echo "============================================================"
    fresh_lib
    compile_tb 2
    run_sim mp_bug2_test bug2_test.log bug2_test.ucdb
    echo " >> Log:  doc/bug2_test.log"
}

# ── BUG 3: STORE never writes to memory ──────────────────────
if { $mode eq "bug3" || $mode eq "all" } {
    echo ""
    echo "============================================================"
    echo " BUG 3  (BUG_SELECT 3 — STORE silent memory corruption)"
    echo "============================================================"
    fresh_lib
    compile_tb 3
    run_sim mp_bug3_test bug3_test.log bug3_test.ucdb
    echo " >> Log:  doc/bug3_test.log"
}

# ── MERGE + REPORT (only when all 4 ran) ─────────────────────
if { $mode eq "all" } {
    echo ""
    echo "============================================================"
    echo " Merging coverage databases..."
    echo "============================================================"

    vcover merge doc/ms5_total.ucdb \
        doc/mp_coverage_test.ucdb \
        doc/bug1_test.ucdb \
        doc/bug2_test.ucdb \
        doc/bug3_test.ucdb

    # HTML report (open doc/html_coverage/index.html in browser)
    vcover report -html \
        -output doc/html_coverage \
        doc/ms5_total.ucdb

    # Functional coverage text report
    vcover report -details -cvg \
        -output doc/func_cov_report_TOTAL.txt \
        doc/ms5_total.ucdb

    # Code coverage text report
    vcover report -details -codeall \
        -output doc/code_cov_report_TOTAL.txt \
        doc/ms5_total.ucdb

    echo ""
    echo "============================================================"
    echo " ECE-593 G9 Milestone 5 — All Tests Complete"
    echo ""
    echo "  Logs:"
    echo "    doc/mp_coverage_test.log   (clean DUT)"
    echo "    doc/bug1_test.log          (ADD bug)"
    echo "    doc/bug2_test.log          (SHIFT bug)"
    echo "    doc/bug3_test.log          (STORE bug)"
    echo ""
    echo "  Coverage:"
    echo "    doc/ms5_total.ucdb"
    echo "    doc/html_coverage/index.html"
    echo "    doc/func_cov_report_TOTAL.txt"
    echo "    doc/code_cov_report_TOTAL.txt"
    echo "============================================================"
}
