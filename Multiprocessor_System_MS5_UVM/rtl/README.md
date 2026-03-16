# RTL — Milestone 5

This directory contains the bug-switchable RTL for the Milestone 5 verification campaign.

## Files

| File             | Description                                                                                     |
|------------------|-------------------------------------------------------------------------------------------------|
| `mp_dut_demo.sv` | Primary DUT used by run.do. Bug behavior selected at compile time via +define+BUG_SELECT_N. BUG_SELECT_0 = clean, 1/2/3 = injected bugs. |
| `mp_dut_bug1.sv` | Standalone: ADD computes A−B instead of A+B                                                     |
| `mp_dut_bug2.sv` | Standalone: SHR and SHL opcodes swapped                                                         |
| `mp_dut_bug3.sv` | Standalone: STORE write disabled — memory never updated                                         |

## DUT Interface

| Signal        | Direction | Width | Description                           |
|---------------|-----------|-------|---------------------------------------|
| `clk`         | input     | 1     | System clock                          |
| `rst_n`       | input     | 1     | Active-low asynchronous reset         |
| `core_id`     | input     | 2     | Requesting core (0–3)                 |
| `opcode`      | input     | 4     | Operation                             |
| `req`         | input     | 1     | Bus request                           |
| `addr`        | input     | 11    | Memory address (2KB space)            |
| `A`           | input     | 8     | Operand A                             |
| `B`           | input     | 8     | Operand B                             |
| `we`          | input     | 1     | Write enable (STORE)                  |
| `gnt`         | output    | 1     | Bus grant (tied to req in this design)|
| `rvalid`      | output    | 1     | Response valid                        |
| `data_out`    | output    | 8     | Result or read data                   |
| `core_id_out` | output    | 2     | Core ID echo on response              |

## Bug Summary

| Bug | Opcode     | Injected Defect                    | Detection Method                       |
|-----|------------|------------------------------------|----------------------------------------|
| 1   | ADD 0001   | A - B instead of A + B             | Directed: 8 vectors where A ≠ B        |
| 2   | SHR 0111   | A << 1 instead of A >> 1           | Directed: 6 SHR + 6 SHL vectors        |
| 3   | STORE 0110 | mem[addr] <= A line removed        | Scenario: STORE then LOAD same address |
