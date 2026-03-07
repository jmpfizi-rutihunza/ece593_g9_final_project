# Multiprocessor System Verification – Milestone 5 (UVM)

**Course:** ECE 593 – Fundamentals of Pre-Silicon Validation
**University:** Portland State University
**Author:** Saleh Esmaeil

---

# Milestone 5 Overview

Milestone 5 focuses on developing a **Universal Verification Methodology (UVM) based testbench** for the multiprocessor system designed in previous milestones.

The objective is to build a **scalable verification environment** capable of validating the behavior of a **4-core multiprocessor system** sharing a common memory interface.

The testbench verifies:

* correct handling of memory requests
* bus arbitration between processors
* correct read and write responses
* system behavior under concurrent processor activity

The verification environment uses **UVM components** such as agents, drivers, monitors, sequencers, scoreboards, and coverage collectors.

---

# UVM Testbench Architecture

The verification environment follows the standard **UVM hierarchical structure**.

```
Test
 └── Environment
      ├── Core Agent 0
      │     ├── Sequencer
      │     ├── Driver
      │     └── Monitor
      │
      ├── Core Agent 1
      ├── Core Agent 2
      ├── Core Agent 3
      │
      ├── Scoreboard
      └── Coverage Collector
```

Each processor core is modeled by a **UVM agent** that generates and monitors memory transactions.

---

# UVM Components

### Sequence Item

Defines the transaction object used to represent processor memory requests.

### Sequence

Generates randomized memory transactions sent to the DUT.

### Sequencer

Controls the flow of sequence items to the driver.

### Driver

Applies transactions from the sequencer to the DUT interface.

### Monitor

Observes DUT signals and converts them into transactions for checking.

### Agent

Encapsulates driver, sequencer, and monitor for each processor core.

### Environment

Instantiates all agents, scoreboard, and coverage collector.

### Scoreboard

Checks the correctness of DUT responses against expected behavior.

### Coverage Collector

Tracks functional coverage of processor transactions.

---

# Project Structure (Milestone 5)

```
Multiprocessor_System_MS5_UVM
│
├── rtl
│   └── mp_dut.sv
│
├── UVM_TB
│   ├── mp_pkg.sv
│   ├── mp_sequence_item.sv
│   ├── mp_sequence.sv
│   ├── mp_driver.sv
│   ├── mp_monitor.sv
│   ├── mp_agent.sv
│   ├── mp_env.sv
│   ├── mp_scoreboard.sv
│   ├── mp_coverage.sv
│   ├── test.sv
│   └── tb_top.sv
│
└── run_ms5.do
```

---

# Running the Simulation

Compile the design and verification files:

```
vlog -sv -cover bcesft rtl/*.sv
vlog -sv -cover bcesft UVM_TB/*.sv
```

Run the simulation:

```
vsim -coverage tb_top +UVM_TESTNAME=mp_coverage_test
run -all
```

Save coverage results:

```
coverage save mp_coverage_test.ucdb
```

---

# Coverage Results

The verification environment collects functional and code coverage during simulation.

Coverage results:

| Component | Coverage |
| --------- | -------- |
| Testbench | 99.75%   |
| Interface | 99.75%   |
| DUT       | 87.3%    |
| Overall   | 91.54%   |

The results demonstrate that the UVM environment effectively exercises most of the design functionality.

---

# Milestone 5 Achievements

* Implemented full **UVM verification architecture**
* Created **four processor agents**
* Implemented **driver, monitor, sequencer, and scoreboard**
* Added **functional coverage collection**
* Executed randomized verification tests
* Generated coverage reports


