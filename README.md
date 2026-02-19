ECE-593 — Pre-Silicon Validation Project

This repository contains milestone-based development of a multiprocessor system verification project for:

ECE-593: Fundamentals of Pre-Silicon Validation  
Maseeh College of Engineering and Computer Science  
Portland State University

----------------------------------------------------

Project Structure

Each milestone is organized into its own directory following the required course structure.

Milestones:

- MS1 — Traditional Verification
- MS2 — Class-Based Verification
- MS3 — Advanced Class Verification
- MS4 — UVM Environment
- MS5 — Advanced UVM
- FINAL — Integrated Project

----------------------------------------------------

Milestone-2 (Class Based Verification)

Milestone-2 implements a complete class-based verification environment including:

- Transaction modeling
- Generator / Driver architecture
- Input and Output monitors
- Scoreboard checking
- Functional coverage
- Code coverage
- Environment-based execution

Folder structure:

project_name_MS2_Class/
    rtl/
    CLASS_TB/
    doc/

----------------------------------------------------

Simulation (Milestone-2)

Run from MS2 root:

vdel -lib work -all  
vlib work  
vlog -sv -mfcu -cover bcesf rtl/mp_dut.sv CLASS_TB/*.sv  
vsim -coverage work.tb_top  
run -all

----------------------------------------------------

Authors

- Janvier Mpfizi Rutihunza
- Frezewd Debebe
- Sal Esmaeil

----------------------------------------------------

Notes

This repository follows the required ECE-593 project directory structure and contains all verification artifacts, documentation, and coverage reports for each milestone.


