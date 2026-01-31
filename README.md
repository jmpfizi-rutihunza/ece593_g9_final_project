# ECE-593 Milestone 1 – Traditional Verification

## Project

Multiprocessor System

## Course

ECE-593: Fundamentals of Pre-Silicon Validation
Maseeh College of Engineering and Computer Science
Winter 2025

## Instructor

Prof. Venkatesh Patil

## Team Members

* Janvier Mpfizi Rutihunza
* Frezewd Debebe
* Sal Esmael

## Milestone Objective

Milestone 1 focuses on early pre-silicon validation using a traditional (conventional) testbench.
The goal of this milestone is to validate:

* Basic RTL functionality
* Arbitration correctness
* Shared bus behavior
* Memory read/write dataflow

Generator-based processors are used instead of full instruction-level CPU cores to simplify early system-level validation.

## Directory Structure

Multiprocessor_System_MS1_Trad/
├── README.md
├── doc/
│   ├── README.md
│   └── ECE_593__Pre_Silicon_Validation.pdf
├── rtl/
│   ├── README.md
│   ├── generator.sv
│   └── mp_top.sv
└── TRAD_TB/
├── README.md
├── mp_top_tb.sv
└── run.do

## How to Run Simulation

1. Launch QuestaSim / ModelSim
2. Navigate to the testbench directory:
   cd Multiprocessor_System_MS1_Trad/TRAD_TB
3. Run the simulation:
   do run.do
