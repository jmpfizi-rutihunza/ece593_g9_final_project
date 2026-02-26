# UVM Testbench — Multiprocessor System

## Description

This directory contains the Universal Verification Methodology (UVM) testbench used in Milestone-4.

The testbench verifies functional correctness of the Multiprocessor System using constrained-random stimulus and a scoreboard reference model.

---

## File Overview

### Top Level

* **tb_top_uvm.sv**
  Instantiates DUT and interface and starts UVM.

* **mp_pkg.sv**
  Package including all UVM components.

---

### Sequence Layer

* **mp_seq_item.sv**
  Transaction object representing processor requests and responses.

---

### Agent Layer

* **mp_driver.sv**
  Drives DUT inputs using sequence items.

* **mp_req_monitor.sv**
  Captures DUT request activity.

* **mp_rsp_monitor.sv**
  Captures DUT response activity.

---

### Environment Layer

* **mp_agent.sv**
  Groups sequencer, driver, and monitors.

* **mp_env.sv**
  Instantiates agent and scoreboard.

* **mp_scoreboard.sv**
  Implements prediction and checking logic using per-core expected queues.

---

### Test Layer

* **mp_test.sv**
  Builds the environment and starts sequences.

---

## Data Flow

Sequence → Driver → DUT → Monitors → Scoreboard

The scoreboard predicts expected results from request transactions and compares them with DUT responses.

---

## Logging

The testbench uses UVM reporting macros:

* uvm_info
* uvm_warning
* uvm_error

Verbosity levels control transcript detail.

---

## Notes

The UVM testbench reuses the Milestone-2 verification strategy while introducing standardized UVM architecture.
