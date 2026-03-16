ECE-593 — Pre-Silicon Validation Project

This repository contains milestone-based development of a multiprocessor system verification project for:

ECE-593: Fundamentals of Pre-Silicon Validation
Maseeh College of Engineering and Computer Science
Portland State University
Winter 2026

Authors: Janvier Mpfizi Rutihunza, Frezewd Debebe, Sal Esmaeil
Instructor: Prof. Venkatesh Patil

----------------------------------------------------

Project Structure

Each milestone is organized into its own directory.

Milestones:

- MS1 — Traditional Verification      → Multiprocessor_System_MS1_Trad/
- MS2 — Class-Based Verification      → Multiprocessor_System_MS2_Class/
- MS3 — Coverage-Driven Verification  → Multiprocessor_System_MS2_Class/ (combined with MS2)
- MS4 — UVM Environment               → Multiprocessor_System_MS4_UVM/
- MS5 — Bug Injection & Final UVM     → Multiprocessor_System_MS5_UVM/

Note: MS2 and MS3 were submitted as a combined deliverable in Multiprocessor_System_MS2_Class/.

----------------------------------------------------

How to Run Each Milestone

Milestone 1 (Traditional TB):

  cd Multiprocessor_System_MS1_Trad/TRAD_TB
  do run.do

Milestone 2/3 (Class-Based):

  cd Multiprocessor_System_MS2_Class
  vdel -lib work -all
  vlib work
  vlog -sv -mfcu -cover bcesf rtl/mp_dut.sv Class_TB/*.sv
  vsim -coverage work.tb_top
  run -all

Milestone 4 (UVM):

  cd Multiprocessor_System_MS4_UVM
  do UVM_TB/run.do

Milestone 5 (UVM + Bug Injection):

  cd Multiprocessor_System_MS5_UVM
  do UVM_TB/run.do

  This runs all 5 tests automatically:
    - mp_coverage_test  (100% coverage closure, clean DUT)
    - mp_alu_test       (1000 transaction stress, clean DUT)
    - mp_bug1_test      (Bug 1: ADD computes A-B)
    - mp_bug2_test      (Bug 2: SHR/SHL swapped)
    - mp_bug3_test      (Bug 3: STORE disabled)

  Reports are saved to Multiprocessor_System_MS5_UVM/doc/

----------------------------------------------------

Notes

This repository follows the required ECE-593 project directory structure and contains
all verification artifacts, documentation, and coverage reports for each milestone.
