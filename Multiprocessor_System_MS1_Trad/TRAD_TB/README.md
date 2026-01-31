# Traditional Testbench – Milestone 1

This directory contains the **conventional (directed) testbench** for Milestone 1.

## Testbench Type
- Traditional / Directed Testbench
- No class-based or UVM components

## Testbench Responsibilities
- Apply reset and clock
- Observe generator behavior
- Validate write/read correctness
- Detect pass/fail conditions
- End simulation on completion or timeout

## Files
- mp_top_tb.sv
- run.do

## Expected Outcome
All generators should complete their transactions and report PASS.
