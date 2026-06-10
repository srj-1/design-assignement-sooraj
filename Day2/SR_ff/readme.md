Day 2 – Task 2: SR Flip-Flop Design and Verification

Objective

To design and verify a Synchronous SR (Set-Reset) Flip-Flop using Verilog HDL and simulate its functionality using Xilinx Vivado.

---

Introduction

An SR Flip-Flop is one of the fundamental sequential logic circuits used for storing a single bit of data. Unlike combinational circuits, a flip-flop can retain its previous state until a new input or clock event occurs.

The SR Flip-Flop has two control inputs:

- S (Set)
- R (Reset)

and two outputs:

- Q
- Q̅ (Q bar)

It is widely used in:

- Registers
- Counters
- Memory units
- State machines
- Digital control systems

---

Theory

The SR Flip-Flop changes its state according to the values of the Set and Reset inputs when the active clock edge occurs.

Truth Table

S| R| Q(next)| Q̅(next)| Operation
0| 0| Q(previous)| Q̅(previous)| Hold
0| 1| 0| 1| Reset
1| 0| 1| 0| Set
1| 1| Invalid| Invalid| Forbidden State

---

Working Principle

Hold State (S = 0, R = 0)

The flip-flop retains its previous output.

Q(next) = Q(previous)

Reset State (S = 0, R = 1)

The output is reset.

Q = 0
Q̅ = 1

Set State (S = 1, R = 0)

The output is set.

Q = 1
Q̅ = 0

Invalid State (S = 1, R = 1)

Both Set and Reset are active simultaneously, resulting in an undefined condition.

Q = X
Q̅ = X

---

Design Methodology

The SR Flip-Flop was implemented using Verilog HDL with synchronous clock operation.

Inputs

Signal| Description
clk| Clock Input
rst| Reset Signal
s| Set Input
r| Reset Input

Outputs

Signal| Description
q| Main Output
qbar| Complement Output

Functional Description

- On the active edge of the clock, the flip-flop evaluates the values of S and R.
- Based on the input combination, it performs Set, Reset, Hold, or enters an Invalid state.
- The reset signal initializes the outputs to a known state.

---

RTL Analysis

The RTL schematic generated in Vivado shows:

- Two synchronous registers for Q and Q̅.
- Multiplexer-based control logic.
- Clock-controlled storage elements.
- Synchronous reset implementation.

The RTL structure confirms the implementation of a sequential memory element capable of storing one bit of information.

RTL Diagram

<img width="680" height="523" alt="image" src="https://github.com/user-attachments/assets/b8052ed0-882c-425a-9456-1677940747fc" />

---

Verilog Implementation

The design was implemented using Verilog HDL and modeled as a clocked sequential circuit.

Features

- Positive-edge triggered operation.
- Set and Reset functionality.
- Output retention during Hold condition.
- Complementary outputs Q and Q̅.

---

Simulation and Verification

A Verilog testbench was developed to verify all operating conditions of the SR Flip-Flop.

Test Cases

S| R| Expected Q| Expected Q̅| Operation
0| 0| Hold| Hold| No Change
0| 1| 0| 1| Reset
1| 0| 1| 0| Set
1| 1| X| X| Invalid

Sample Observation

From the simulation waveform:

Signal| Value
S| 1
R| 1
CLK| 1
Q| X
Q̅| X

The outputs become undefined because both Set and Reset inputs are active simultaneously.

Result: PASS ✅

Simulation Waveform

<img width="1525" height="781" alt="image" src="https://github.com/user-attachments/assets/240d8a20-4ca8-4662-93bf-70f13529a3a6" />



---

Observations

- The flip-flop successfully stored one bit of information.
- Output changes occurred only at the active clock edge.
- Set and Reset operations functioned correctly.
- Hold state preserved the previous output.
- The forbidden condition (S = R = 1) produced undefined outputs as expected.
- Simulation results matched the theoretical behavior of an SR Flip-Flop.

---

Conclusion

A Synchronous SR Flip-Flop was successfully designed, implemented, and verified using Verilog HDL. The simulation results confirmed correct operation under Set, Reset, Hold, and Invalid conditions. RTL analysis verified the hardware implementation, and the assignment provided practical experience in sequential circuit design, memory elements, and clocked digital systems.

---

Tools Used

- Xilinx Vivado
- Verilog HDL

Concepts Learned

- Sequential Logic Circuits
- SR Flip-Flop Operation
- State Retention
- Clocked Circuit Design
- RTL Analysis
- Testbench Development
- Functional Simulation
