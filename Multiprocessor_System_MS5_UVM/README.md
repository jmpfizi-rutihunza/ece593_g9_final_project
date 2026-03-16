# ECE-593 Group 9 — Milestone 5 UVM Testbench

**Course:** ECE-593 Fundamentals of Pre-Silicon Validation  
**University:** Portland State University — Maseeh College  
**Instructor:** Prof. Venkatesh Patil

---

## How to Run

**Run from the `Multiprocessor_System_MS5_UVM/` directory:**
```
cd Multiprocessor_System_MS5_UVM
vsim -do UVM_TB/run.do
```

This single command runs all 5 tests in sequence and generates all reports in `doc/`.

### What `run.do` executes:

| Test | DUT | Purpose |
|------|-----|---------|
| `mp_coverage_test` | Clean | 100% functional coverage closure |
| `mp_alu_test` | Clean | ALU stress — 1000 transactions |
| `mp_bug1_test` | Bug 1 | ADD computes A−B (32/32 errors expected) |
| `mp_bug2_test` | Bug 2 | SHR/SHL swapped (48/48 errors expected) |
| `mp_bug3_test` | Bug 3 | STORE never writes (80/160 errors expected) |

### Expected Output Files in `doc/`
```
mp_coverage_test.log   → RESULT: ALL TESTS PASSED (0 errors)
mp_alu_test.log        → RESULT: ALL TESTS PASSED (1000/1000 matches)
bug1_test.log          → RESULT: 32 TESTS FAILED  (bug correctly caught)
bug2_test.log          → RESULT: 48 TESTS FAILED  (bug correctly caught)
bug3_test.log          → RESULT: 80 TESTS FAILED  (bug correctly caught)
func_cov_report_TOTAL.txt  → 100% clean DUT coverage
code_cov_report_TOTAL.txt  → 99.75% toggle, 100% branch
```

---

## UVM Component Files

| File | Role |
|------|------|
| `sequence_item.sv` | Transaction object (opcode, addr, A, B, data) |
| `sequence.sv` | Base + scenario sequences (1000 random txns) |
| `driver.sv` | req/gnt handshake, cycle-accurate stimulus |
| `monitor.sv` | Captures DUT response → sends to scoreboard |
| `agent.sv` | Bundles sequencer + driver + monitor per core |
| `scoreboard.sv` | Shadow RAM reference model, MATCH/MISMATCH |
| `coverage.sv` | 89-bin covergroup (CROSS_CORE_OP, CROSS_MEM_REGION) |
| `env.sv` | 4 agents + scoreboard + coverage |
| `test.sv` | mp_test, mp_alu_test, mp_coverage_test |
| `bug_tests.sv` | mp_bug1/2/3_test + directed sequences |
| `assertions.sv` | 3 SVA properties (A1 grant latency, A2 rvalid, A3 mutex) |
| `interface.sv` | mp_intf — connects TB to DUT |
| `tb_top.sv` | Clean DUT top |
| `tb_top_bug.sv` | Bug-switchable DUT top |
| `mp_pkg.sv` | Package includes |
| `run.do` | QuestaSim simulation script |

---

## RTL Bug Files

| File | Bug |
|------|-----|
| `rtl/mp_dut_demo.sv` | Switchable via `BUG_SELECT_0/1/2/3` defines |
| `rtl/mp_dut_bug1.sv` | Standalone: ADD → A−B |
| `rtl/mp_dut_bug2.sv` | Standalone: SHR/SHL swapped |
| `rtl/mp_dut_bug3.sv` | Standalone: STORE disabled |
