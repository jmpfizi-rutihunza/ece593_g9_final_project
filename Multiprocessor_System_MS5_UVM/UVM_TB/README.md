# UVM Testbench — Milestone 5

This directory contains all UVM verification components for the 4-core Multiprocessor System.

## How to Run

From `Multiprocessor_System_MS5_UVM/`:
do UVM_TB/run.do

## File Descriptions

| File               | Role                                                                              |
|--------------------|-----------------------------------------------------------------------------------|
| `run.do`           | Compiles and runs all 5 tests, saves coverage to doc/                             |
| `interface.sv`     | mp_intf — 4-core bus interface connecting TB to DUT                               |
| `mp_pkg.sv`        | Package that includes all UVM component files                                     |
| `sequence_item.sv` | mp_transaction — transaction object (opcode, addr, A, B, data)                   |
| `sequence.sv`      | All sequence classes: base, write-only, read-only, write-read, coverage-closure, virtual |
| `sequencer.sv`     | mp_sequencer — routes items from sequence to driver                               |
| `driver.sv`        | mp_driver — implements req/gnt handshake, cycle-accurate stimulus                 |
| `monitor.sv`       | mp_monitor — captures DUT response, forwards to scoreboard                        |
| `agent.sv`         | mp_agent — bundles sequencer, driver, and monitor per core                        |
| `scoreboard.sv`    | mp_scoreboard — shadow RAM reference model, MATCH/MISMATCH check                  |
| `coverage.sv`      | mp_coverage — 89-bin covergroup (CP_CORE, CP_OPCODE, CP_ADDR, CROSS_CORE_OP, CROSS_MEM_REGION) |
| `env.sv`           | mp_env — instantiates 4 agents, scoreboard, and coverage                          |
| `test.sv`          | mp_test, mp_alu_test, mp_coverage_test                                            |
| `bug_tests.sv`     | mp_bug1/2/3_test + directed sequences for bug detection                           |
| `tb_top.sv`        | Top-level module for clean DUT tests                                              |
| `tb_top_bug.sv`    | Top-level module for bug-injection tests (uses BUG_SELECT defines)                |
| `tb_top_uvm.sv`    | Legacy MS4 wrapper — kept for reference only, not used in MS5 flow                |

## Test Summary

| Test Name          | Transactions | Errors | Purpose                       |
|--------------------|--------------|--------|-------------------------------|
| mp_coverage_test   | 1602         | 0      | Hit all 89 coverage bins      |
| mp_alu_test        | 1000         | 0      | ALU stress across all 4 cores |
| mp_bug1_test       | 32           | 32     | Detect ADD → A−B bug          |
| mp_bug2_test       | 48           | 48     | Detect SHR/SHL swap bug       |
| mp_bug3_test       | 160          | 80     | Detect STORE disabled bug     |
