\# \*\*ECE-593 Milestone 1 – Traditional Verification\*\*



\## \*\*Project\*\*



\*\*Multiprocessor System\*\*



\## \*\*Course\*\*



ECE-593: Fundamentals of Pre-Silicon Validation

Maseeh College of Engineering and Computer Science

Winter 2025



\## \*\*Instructor\*\*



Prof. Venkatesh Patil



\## \*\*Team Members\*\*



\* Janvier Mpfizi Rutihunza

\* Frezewd Debebe

\* Sal Esmaeil



---



\## \*\*Milestone Objective\*\*



Milestone 1 focuses on early \*\*pre-silicon validation\*\* using a \*\*traditional (conventional) testbench\*\*.

The objective of this milestone is to validate the following aspects of the design:



\* Basic RTL functionality

\* Arbitration correctness

\* Shared bus behavior

\* Memory read/write dataflow



To simplify early system-level validation, \*\*generator-based processors\*\* are used instead of full instruction-level CPU cores.



---



\## \*\*Directory Structure\*\*



```

Multiprocessor\_System\_MS1\_Trad/

├── README.md

├── doc/

│   ├── README.md

│   └── ECE\_593\_\_Pre\_Silicon\_Validation.pdf

├── rtl/

│   ├── README.md

│   ├── generator.sv

│   └── mp\_top.sv

└── TRAD\_TB/

&nbsp;   ├── README.md

&nbsp;   ├── mp\_top\_tb.sv

&nbsp;   └── run.do

```



---



\## \*\*How to Run Simulation\*\*



1\. Launch QuestaSim

2\. Navigate to the testbench directory:



&nbsp;  ```

&nbsp;  cd Multiprocessor\_System\_MS1\_Trad/TRAD\_TB

&nbsp;  ```

3\. Run the simulation:



&nbsp;  ```

&nbsp;  do run.do

&nbsp;  ```



---



