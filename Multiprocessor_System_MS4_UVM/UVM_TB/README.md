# UVM Testbench — Milestone 4

This directory contains the UVM verification environment for the Multiprocessor System.

## How to Run

From `Multiprocessor_System_MS4_UVM/`:
do UVM_TB/run.do

## File Descriptions

| File             | Role                                                          |
|------------------|---------------------------------------------------------------|
| `run.do`         | Compiles and runs mp_test and mp_alu_test, saves coverage     |
| `interface.sv`   | SystemVerilog interface connecting TB to DUT                  |
| `mp_pkg.sv`      | Package that includes all UVM component files                 |
| `sequence_item.sv` | Transaction object (opcode, addr, operands, data)           |
| `sequence.sv`    | Sequence classes for generating transactions                  |
| `sequencer.sv`   | Routes sequence items to driver                               |
| `driver.sv`      | Converts transactions to DUT pin-level stimulus               |
| `monitor.sv`     | Observes DUT signals and forwards to scoreboard               |
| `agent.sv`       | Bundles sequencer, driver, and monitor                        |
| `scoreboard.sv`  | Reference model with MATCH/MISMATCH checking                  |
| `coverage.sv`    | Functional covergroup                                         |
| `env.sv`         | Instantiates agent and scoreboard                             |
| `test.sv`        | mp_test and mp_alu_test                                       |
| `tb_top.sv`      | Testbench top module                                          |
| `tb_top_uvm.sv`  | Alternative top (legacy reference)                            |
| `agent/`         | Subfolder with alternative agent component files              |
| `env/`           | Subfolder with alternative scoreboard file                    |
| `test/`          | Subfolder with alternative test and sequence files            |

## Test Summary

| Test         | Transactions | Errors | Purpose                              |
|--------------|--------------|--------|--------------------------------------|
| mp_test      | 90           | 0      | Basic handshake and connectivity     |
| mp_alu_test  | 1000         | 0      | Full ALU stress, coverage closure    |
