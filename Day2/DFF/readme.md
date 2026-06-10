Day 2 – Task 3: D Flip-Flop Design and Verification

Objective

To design and verify a D (Data) Flip-Flop using Verilog HDL and simulate its functionality using Xilinx Vivado.

---

Introduction

A D Flip-Flop (Data Flip-Flop) is a sequential logic circuit used to store a single bit of data. It is one of the most commonly used memory elements in digital systems because it eliminates the invalid state present in the SR Flip-Flop.

The D Flip-Flop captures the value present at the input D on the active edge of the clock and stores it until the next clock event.

Applications

- Registers
- Shift Registers
- Counters
- Memory Units
- Finite State Machines (FSMs)
- Digital Control Systems

---

Theory

A D Flip-Flop stores one bit of information and updates its output only at the active clock edge.

Inputs

Signal| Description
D| Data Input
CLK| Clock Input
RST| Reset Input

Outputs

Signal| Description
Q| Stored Output
Q̅| Complement Output

Truth Table

Clock Edge| D| Q(next)| Q̅(next)
↑| 0| 0| 1
↑| 1| 1| 0
No Clock Edge| X| Q(previous)| Q̅(previous)

---

Working Principle

The D Flip-Flop is derived from the SR Flip-Flop by connecting:

- S = D
- R = D̅

This arrangement removes the forbidden state that exists in an SR Flip-Flop.

Operation

- When D = 1, the flip-flop enters the Set state and stores logic HIGH.
- When D = 0, the flip-flop enters the Reset state and stores logic LOW.
- During the active clock edge, the value at D is transferred to Q.
- Between clock edges, the stored value remains unchanged.

---

Design Methodology

The D Flip-Flop was implemented using an SR Flip-Flop and an inverter.

Inputs

Signal| Description
clk| Clock Signal
rst| Reset Signal
d| Data Input

Outputs

Signal| Description
q| Output
qbar| Complement Output

Internal Logic

The D input is connected directly to the Set input of the SR Flip-Flop.

The complement of D is generated using a NOT gate and connected to the Reset input.

S = D
R = D̅

This guarantees that Set and Reset are never active simultaneously.

---

RTL Analysis

The RTL schematic generated in Vivado shows:

- One inverter (NOT Gate)
- One SR Flip-Flop block
- Clock input
- Reset input
- Output ports Q and Q̅

The inverter generates the complement of D and feeds it to the Reset input of the SR Flip-Flop, thereby implementing a D Flip-Flop.

RTL Diagram

(Insert RTL Schematic Image Here)

---

Verilog Implementation

The design was implemented using Verilog HDL.

Features

- Positive-edge triggered operation
- Data storage capability
- Reset functionality
- Complementary outputs
- No invalid state

The design captures and stores the input data on every active clock edge.

---

Simulation and Verification

A Verilog testbench was developed to verify the operation of the D Flip-Flop.

Test Cases

D| Clock Edge| Expected Q
0| ↑| 0
1| ↑| 1
0| ↑| 0
1| ↑| 1

Sample Observation

From the simulation waveform:

Signal| Value
D| 1
CLK| 1
RST| 0
Q| 1
Q̅| 0

The output correctly follows the input data at the active clock edge.

Result: PASS ✅

Simulation Waveform

(Insert Simulation Waveform Here)

---

Observations

- The output Q follows the value of D on the active clock edge.
- Q̅ always remains the complement of Q.
- The invalid state present in the SR Flip-Flop is eliminated.
- The circuit successfully stores one bit of information.
- Reset functionality initializes the outputs correctly.
- Simulation results matched the theoretical behavior.

---

Conclusion

A D Flip-Flop was successfully designed, implemented, and verified using Verilog HDL. The simulation results confirmed that the output accurately follows the input data during the active clock edge while retaining the stored value between clock cycles. RTL analysis verified the correctness of the hardware implementation. This task provided practical experience in sequential circuit design, data storage elements, and clocked digital systems.

---

Tools Used

- Xilinx Vivado
- Verilog HDL

Concepts Learned

- Sequential Logic Design
- D Flip-Flop Operation
- Data Storage Elements
- SR-to-D Flip-Flop Conversion
- RTL Analysis
- Testbench Development
- Functional SimulationDay 2 – Task 3: D Flip-Flop Design and Verification

Objective

To design and verify a D (Data) Flip-Flop using Verilog HDL and simulate its functionality using Xilinx Vivado.

---

Introduction

A D Flip-Flop (Data Flip-Flop) is a sequential logic circuit used to store a single bit of data. It is one of the most commonly used memory elements in digital systems because it eliminates the invalid state present in the SR Flip-Flop.

The D Flip-Flop captures the value present at the input D on the active edge of the clock and stores it until the next clock event.

Applications

- Registers
- Shift Registers
- Counters
- Memory Units
- Finite State Machines (FSMs)
- Digital Control Systems

---

Theory

A D Flip-Flop stores one bit of information and updates its output only at the active clock edge.

Inputs

Signal| Description
D| Data Input
CLK| Clock Input
RST| Reset Input

Outputs

Signal| Description
Q| Stored Output
Q̅| Complement Output

Truth Table

Clock Edge| D| Q(next)| Q̅(next)
↑| 0| 0| 1
↑| 1| 1| 0
No Clock Edge| X| Q(previous)| Q̅(previous)

---

Working Principle

The D Flip-Flop is derived from the SR Flip-Flop by connecting:

- S = D
- R = D̅

This arrangement removes the forbidden state that exists in an SR Flip-Flop.

Operation

- When D = 1, the flip-flop enters the Set state and stores logic HIGH.
- When D = 0, the flip-flop enters the Reset state and stores logic LOW.
- During the active clock edge, the value at D is transferred to Q.
- Between clock edges, the stored value remains unchanged.

---

Design Methodology

The D Flip-Flop was implemented using an SR Flip-Flop and an inverter.

Inputs

Signal| Description
clk| Clock Signal
rst| Reset Signal
d| Data Input

Outputs

Signal| Description
q| Output
qbar| Complement Output

Internal Logic

The D input is connected directly to the Set input of the SR Flip-Flop.

The complement of D is generated using a NOT gate and connected to the Reset input.

S = D
R = D̅

This guarantees that Set and Reset are never active simultaneously.

---

RTL Analysis

The RTL schematic generated in Vivado shows:

- One inverter (NOT Gate)
- One SR Flip-Flop block
- Clock input
- Reset input
- Output ports Q and Q̅

The inverter generates the complement of D and feeds it to the Reset input of the SR Flip-Flop, thereby implementing a D Flip-Flop.

RTL Diagram

<img width="1028" height="526" alt="image" src="https://github.com/user-attachments/assets/abfb1d36-5124-4345-bab2-2083c46a71b1" />



---

Verilog Implementation

The design was implemented using Verilog HDL.

Features

- Positive-edge triggered operation
- Data storage capability
- Reset functionality
- Complementary outputs
- No invalid state

The design captures and stores the input data on every active clock edge.

---

Simulation and Verification

A Verilog testbench was developed to verify the operation of the D Flip-Flop.

Test Cases

D| Clock Edge| Expected Q
0| ↑| 0
1| ↑| 1
0| ↑| 0
1| ↑| 1

Sample Observation

From the simulation waveform:

Signal| Value
D| 1
CLK| 1
RST| 0
Q| 1
Q̅| 0

The output correctly follows the input data at the active clock edge.

Result: PASS ✅

Simulation Waveform

<img width="1526" height="766" alt="image" src="https://github.com/user-attachments/assets/0482a3b8-fd3b-4311-aa74-54946a8247c2" />

---

Observations

- The output Q follows the value of D on the active clock edge.
- Q̅ always remains the complement of Q.
- The invalid state present in the SR Flip-Flop is eliminated.
- The circuit successfully stores one bit of information.
- Reset functionality initializes the outputs correctly.
- Simulation results matched the theoretical behavior.

---

Conclusion

A D Flip-Flop was successfully designed, implemented, and verified using Verilog HDL. The simulation results confirmed that the output accurately follows the input data during the active clock edge while retaining the stored value between clock cycles. RTL analysis verified the correctness of the hardware implementation. This task provided practical experience in sequential circuit design, data storage elements, and clocked digital systems.

---

Tools Used

- Xilinx Vivado
- Verilog HDL

Concepts Learned

- Sequential Logic Design
- D Flip-Flop Operation
- Data Storage Elements
- SR-to-D Flip-Flop Conversion
- RTL Analysis
- Testbench Development
- Functional Simulation
