Milestone-2 — RTL

This folder contains the Design Under Test (DUT).

File:
- mp_dut.sv

The DUT implements a simple memory-mapped interface supporting:
- Read operations
- Write operations
- Burst tracking
- Handshake (req/gnt)
- Output valid signaling

The DUT is verified using the class-based environment in CLASS_TB.
