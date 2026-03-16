# Multiprocessor System Verification — Milestone 5 (UVM + Bug Injection)

**Course:** ECE-593 — Fundamentals of Pre-Silicon Validation
**University:** Portland State University — Maseeh College of Engineering and Computer Science
**Instructor:** Prof. Venkatesh Patil | Winter 2026
**Team:** Janvier Mpfizi Rutihunza • Frezewd Debebe • Sal Esmaeil

---

## Milestone 5 Overview

Milestone 5 completes the UVM verification environment with:

- Full UVM architecture with 4 independent core agents
- A rich sequence library including directed, scenario, and coverage-closure sequences
- Three bug injection scenarios with directed detection tests
- 100% functional coverage closure on the clean DUT (89/89 bins)
- Merged coverage reports across all 5 test runs

---

## How to Run

**Run from the `Multiprocessor_System_MS5_UVM/` directory:**

```
do UVM_TB/run.do
```

This single command runs all 5 tests in sequence and saves all logs and coverage reports to `doc/`.

### Tests Executed by run.do

| Test             | DUT    | Purpose                         | Expected Result         |
|------------------|--------|---------------------------------|-------------------------|
| mp_coverage_test | Clean  | Coverage closure — all 89 bins  | 0 errors, 100% coverage |
| mp_alu_test      | Clean  | ALU stress — 1000 transactions  | 0 errors, 1000 matches  |
| mp_bug1_test     | Bug 1  | ADD computes A−B instead of A+B | 32 errors (caught)      |
| mp_bug2_test     | Bug 2  | SHR/SHL directions swapped      | 48 errors (caught)      |
| mp_bug3_test     | Bug 3  | STORE never writes to memory    | 80 errors (caught)      |

---

## UVM Architecture

```
Test
 └── Environment
      ├── Core Agent 0  (Sequencer + Driver + Monitor)
      ├── Core Agent 1
      ├── Core Agent 2
      ├── Core Agent 3
      ├── Scoreboard    (Shadow RAM reference model)
      └── Coverage      (89-bin covergroup)
```

---

## Directory Structure

```
Multiprocessor_System_MS5_UVM/
├── README.md
├── rtl/
│   ├── mp_dut_demo.sv      ← Bug-switchable DUT (BUG_SELECT_0/1/2/3)
│   ├── mp_dut_bug1.sv      ← Standalone: ADD computes A-B
│   ├── mp_dut_bug2.sv      ← Standalone: SHR/SHL swapped
│   └── mp_dut_bug3.sv      ← Standalone: STORE disabled
├── UVM_TB/
│   ├── run.do              ← Single script to run all 5 tests
│   ├── tb_top.sv           ← Clean DUT testbench top
│   ├── tb_top_bug.sv       ← Bug-switchable testbench top
│   ├── mp_pkg.sv           ← Package includes
│   ├── sequence_item.sv    ← Transaction object
│   ├── sequence.sv         ← All sequence classes
│   ├── sequencer.sv        ← Sequencer
│   ├── driver.sv           ← Cycle-accurate driver with grant-wait
│   ├── monitor.sv          ← Passive observer
│   ├── agent.sv            ← Bundles sequencer + driver + monitor
│   ├── scoreboard.sv       ← Shadow RAM reference model + checker
│   ├── coverage.sv         ← 89-bin functional covergroup
│   ├── env.sv              ← 4 agents + scoreboard + coverage
│   ├── test.sv             ← mp_test, mp_alu_test, mp_coverage_test
│   ├── bug_tests.sv        ← mp_bug1/2/3_test + directed sequences
│   ├── interface.sv        ← mp_intf — 4-core bus interface
│   └── tb_top_uvm.sv       ← Legacy reference (not used in MS5 flow)
└── doc/
    ├── ECE_593__Pre_Silicon_Validation.pdf
    ├── ECE593_G9_MS5.pptx
    ├── mp_coverage_test.log
    ├── mp_alu_test.log
    ├── bug1_test.log
    ├── bug2_test.log
    ├── bug3_test.log
    ├── func_cov_report_TOTAL.txt
    ├── code_cov_report_TOTAL.txt
    └── coverage_summary_TOTAL.txt
```

---

## Coverage Results (Clean DUT)

| Metric              | Result  |
|---------------------|---------|
| Functional Coverage | 100%    |
| Branch Coverage     | 100%    |
| Statement Coverage  | 100%    |
| Toggle Coverage     | 99.21%  |
| Covergroup Bins Hit | 89 / 89 |

The one untoggled signal is `rst_n` high-to-low — it only deasserts during reset and never reasserts, which is correct behavior by design.
