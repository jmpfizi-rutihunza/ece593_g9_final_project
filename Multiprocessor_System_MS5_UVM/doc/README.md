# Documentation — Milestone 5

This directory contains all simulation logs, coverage reports, and final documents for Milestone 5.

## Documents

| File                                  | Description                           |
|---------------------------------------|---------------------------------------|
| `ECE_593__Pre_Silicon_Validation.pdf` | Final Verification Plan (all milestones) |
| `ECE593_G9_MS5.pptx`                 | Final presentation slides             |

## Simulation Logs

| File                   | Test             | DUT    | Result                       |
|------------------------|------------------|--------|------------------------------|
| `mp_coverage_test.log` | mp_coverage_test | Clean  | 0 errors — 100% coverage     |
| `mp_alu_test.log`      | mp_alu_test      | Clean  | 0 errors — 1000/1000 matches |
| `bug1_test.log`        | mp_bug1_test     | Bug 1  | 32 errors — bug caught       |
| `bug2_test.log`        | mp_bug2_test     | Bug 2  | 48 errors — bug caught       |
| `bug3_test.log`        | mp_bug3_test     | Bug 3  | 80 errors — bug caught       |

## Coverage Reports

| File                        | Description                                          |
|-----------------------------|------------------------------------------------------|
| `func_cov_report_TOTAL.txt` | Functional coverage — merged across all 5 tests      |
| `code_cov_report_TOTAL.txt` | Code coverage (branch, statement, toggle, condition) |
| `coverage_summary_TOTAL.txt`| High-level summary of all coverage metrics           |

## Key Results (Clean DUT)

- Functional coverage: **100%** (89/89 bins)
- Branch coverage: **100%**
- Statement coverage: **100%**
- Toggle coverage: **99.21%** (rst_n high-to-low never occurs after reset — by design)
- All 3 bug scenarios detected with **0 false negatives**
