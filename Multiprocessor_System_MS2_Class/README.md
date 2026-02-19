ECE-593 — Milestone-2 (Class Based Verification)

This milestone implements a complete class-based verification environment.

Structure:

- rtl → Design Under Test
- CLASS_TB → Class-based verification components
- doc → Verification documentation

Features implemented:

- Transaction based stimulus
- Generator / Driver architecture
- Input & Output monitors
- Scoreboard checking
- Functional coverage
- Code coverage

Simulation:

vdel -lib work -all
vlib work
vlog -sv -mfcu -cover bcesf rtl/mp_dut.sv CLASS_TB/*.sv
vsim -coverage work.tb_top
run -all
