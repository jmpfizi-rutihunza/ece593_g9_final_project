# Multiprocessor System — Milestone 4 (UVM Verification)

**Course:** ECE-593 — Fundamentals of Pre-Silicon Validation
**University:** Portland State University — Maseeh College of Engineering and Computer Science
**Instructor:** Prof. Venkatesh Patil | Winter 2026
**Team:** Sal Esmaeil • Janvier Mpfizi Rutihunza • Frezewd Debebe

---

## Overview

Milestone 4 transitions the verification environment from class-based (Milestone 2/3) to a full Universal Verification Methodology (UVM) environment.

The UVM testbench verifies:

- Arithmetic operations (ADD, SUB, MUL, AND)
- Memory operations (LOAD, STORE)
- Shift operations (SHR, SHL)
- Special function opcodes (SPL_0 through SPL_4)
- Multi-core arbitration behavior across 4 cores
- Data integrity via shadow RAM scoreboard

---

## How to Run

From `Multiprocessor_System_MS4_UVM/`:
do UVM_TB/run.do

Runs two tests:
- mp_test — 90 directed transactions, validates basic handshaking
- mp_alu_test — 1000 constrained random transactions, full coverage stress

Reports are saved to `doc/`.

---

## UVM Architecture
Test
└── Environment
├── Agent
│     ├── Sequencer
│     ├── Driver
│     ├── Request Monitor
│     └── Response Monitor
└── Scoreboard

---

## Directory Structure
Multiprocessor_System_MS4_UVM/
├── README.md
├── intf.sv                ← Top-level interface file
├── rtl/
│   └── mp_dut.sv          ← Design Under Test
├── UVM_TB/
│   ├── run.do             ← Simulation script
│   ├── mp_pkg.sv          ← UVM package includes
│   ├── interface.sv       ← SystemVerilog interface
│   ├── sequence_item.sv   ← Transaction object
│   ├── sequence.sv        ← Sequence classes
│   ├── sequencer.sv       ← Sequencer
│   ├── driver.sv          ← Cycle-accurate driver
│   ├── monitor.sv         ← Response monitor
│   ├── agent.sv           ← Bundles sequencer + driver + monitor
│   ├── scoreboard.sv      ← Reference model + checker
│   ├── coverage.sv        ← Functional covergroup
│   ├── env.sv             ← Environment
│   ├── test.sv            ← mp_test, mp_alu_test
│   ├── tb_top.sv          ← Testbench top
│   ├── tb_top_uvm.sv      ← Alternative top (legacy)
│   ├── agent/             ← MS4 agent subfolder variants
│   ├── env/               ← MS4 env subfolder variants
│   └── test/              ← MS4 test subfolder variants
└── doc/
├── Verification_Plan.pdf
├── MS4_Report.pdf
├── mp_test.log
├── mp_alu_test.log
├── func_cov_report_TOTAL.txt
└── code_cov_report_TOTAL.txt

---

## Verification Strategy

- Constrained-random stimulus via UVM sequences
- Scoreboard with shadow RAM reference model
- Coverage-driven iteration to close functional coverage gaps
- UVM messaging (uvm_info, uvm_warning, uvm_error, uvm_fatal) for controlled logging
