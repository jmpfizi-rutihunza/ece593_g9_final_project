# ECE-593 Milestone 2 & 3 — Class-Based Verification

**Course:** ECE-593 — Fundamentals of Pre-Silicon Validation
**University:** Portland State University — Maseeh College of Engineering and Computer Science
**Instructor:** Prof. Venkatesh Patil | Winter 2026
**Team:** Janvier Mpfizi Rutihunza • Frezewd Debebe • Sal Esmaeil

---

## Overview

Milestones 2 and 3 were submitted as a combined deliverable. This directory contains the complete class-based verification environment for the Multiprocessor System.

Milestone 2 built the core verification infrastructure. Milestone 3 expanded coverage-driven verification, targeted coverage gaps, and added additional test scenarios.

---

## Features Implemented

- Transaction-based stimulus (mp_transaction)
- Generator with constrained randomization
- Driver — translates transactions to DUT pin activity
- Input Monitor — observes stimulus applied to DUT
- Output Monitor — captures DUT responses
- Scoreboard — reference model with PASS/FAIL checking
- Functional coverage collection
- Code coverage (branch, statement, toggle)

---

## Directory Structure
Multiprocessor_System_MS2_Class/
├── README.md
├── rtl/
│   └── mp_dut.sv          ← Design Under Test
├── Class_TB/
│   ├── transaction.sv     ← Transaction object
│   ├── generator.sv       ← Constrained random stimulus
│   ├── driver.sv          ← DUT pin-level driver
│   ├── monitor_in.sv      ← Input monitor
│   ├── monitor_out.sv     ← Output monitor
│   ├── scoreboard.sv      ← Reference model + checker
│   ├── coverage_collector.sv ← Functional coverage
│   ├── environment.sv     ← Connects all components
│   ├── intf.sv            ← SystemVerilog interface
│   ├── tb_top.sv          ← Testbench top module
│   └── run.do             ← Simulation script
└── doc/
├── Verification_Plan.pdf
├── Class-Based_TB_Implementation_Report.pdf
├── functional_coverage_report.txt
└── transcript

---

## How to Run

From `Multiprocessor_System_MS2_Class/`:
vdel -lib work -all
vlib work
vlog -sv -mfcu -cover bcesf rtl/mp_dut.sv Class_TB/*.sv
vsim -coverage work.tb_top
run -all
