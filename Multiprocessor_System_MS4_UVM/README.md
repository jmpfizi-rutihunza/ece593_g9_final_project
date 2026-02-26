# Multiprocessor System — Milestone 4 (UVM Verification)

## Course

ECE-593: Fundamentals of Pre-Silicon Validation
Maseeh College of Engineering and Computer Science
Portland State University

## Project

Multiprocessor System — UVM Verification

## Team Members

* Sal Esmaeil
* Janvier Mpfizi Rutihunza
* Frezewd Debebe

---

## Overview

Milestone-4 transitions the verification environment from traditional class-based verification (Milestone-2) to a Universal Verification Methodology (UVM) environment.

The UVM testbench verifies functional correctness of the Multiprocessor System including:

* Arithmetic operations (ADD, SUB, MUL, AND)
* Memory operations (LOAD, STORE)
* Shift operations
* Special function opcodes
* Multi-core arbitration behavior
* Per-core result ordering

The verification environment follows standard UVM hierarchy:

Test → Environment → Agent → Driver / Monitors → Scoreboard

---

## UVM Architecture

### Test

Creates the environment and starts sequences.

### Environment

Instantiates:

* Agent
* Scoreboard

Handles connectivity between monitors and scoreboard.

### Agent

Contains:

* Sequencer
* Driver
* Request Monitor
* Response Monitor

### Driver

Converts sequence items into DUT pin-level stimulus.

### Monitors

* Request monitor captures DUT inputs.
* Response monitor captures DUT outputs.

### Scoreboard

Implements reference model and checking:

* Predicts expected results from request stream
* Maintans per-core expected queues
* Compares responses against expected values

---

## Logging and Messaging

The testbench uses UVM reporting mechanisms:

* `uvm_info`
* `uvm_warning`
* `uvm_error`
* `uvm_fatal`

Verbosity levels are used to control transcript detail.

---

## Directory Structure

project_name_MS4_UVM/

* rtl/ → DUT and interface
* UVM_TB/ → UVM testbench
* doc/ → verification plan & report
* run.do → simulation script

---

## Running Simulation (QuestaSim)

Open QuestaSim and run:

```
do run.do
```

The script performs:

* Compilation of RTL and UVM TB
* Simulation execution
* Coverage collection
* Transcript generation
* HTML coverage report generation

---

## Deliverables Generated

* transcript.txt
* coverage database (.ucdb)
* HTML coverage report
* UVM logs
* Verification documentation

---

## Verification Strategy

The verification strategy uses:

* Constrained-random stimulus via UVM sequences
* Functional checking using scoreboard reference model
* Coverage-driven verification
* Multi-core ordering validation

---

## Notes

The UVM environment reuses Milestone-2 verification concepts while improving scalability, reuse, and observability.
