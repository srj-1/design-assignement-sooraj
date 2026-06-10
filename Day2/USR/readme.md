 />Day 2 – Task 4: Universal Shift Register (USR) Design and Verification

Objective

To design and verify a 4-bit Universal Shift Register (USR) using Verilog HDL and simulate its functionality using Xilinx Vivado.

---

Introduction

A Universal Shift Register (USR) is a versatile sequential circuit capable of performing multiple data manipulation operations. Unlike conventional shift registers, a Universal Shift Register can perform:

- Hold Operation
- Shift Left Operation
- Shift Right Operation
- Parallel Load Operation

Because it supports multiple modes of operation within a single circuit, it is referred to as a Universal Shift Register.

Applications

- Serial-to-Parallel Conversion
- Parallel-to-Serial Conversion
- Data Storage
- Data Transfer Systems
- Communication Systems
- Digital Signal Processing
- Microprocessor and Embedded Systems

---

Theory

A Universal Shift Register combines the functionality of several shift registers into a single hardware structure. Data can be shifted in either direction, loaded in parallel, or retained based on the selected mode.

Inputs

Signal| Description
clk| Clock Input
rst| Reset Signal
sin| Serial Input
p_in[3:0]| Parallel Data Input
shift| Shift Enable
load| Parallel Load Enable
enb| Enable Signal
mod[1:0]| Mode Selection

Outputs

Signal| Description
p_out[3:0]| Parallel Output
sout| Serial Output

---

Modes of Operation

Mode (mod[1:0])| Operation
00| Hold
01| Shift Right
10| Shift Left
11| Parallel Load

---

Working Principle

Hold Mode (00)

The register retains its current contents.

Q(next) = Q(previous)

Shift Right Mode (01)

Data shifts toward the least significant bit (LSB).

Q3 ← Serial Input
Q2 ← Q3
Q1 ← Q2
Q0 ← Q1

Shift Left Mode (10)

Data shifts toward the most significant bit (MSB).

Q3 ← Q2
Q2 ← Q1
Q1 ← Q0
Q0 ← Serial Input

Parallel Load Mode (11)

All bits are loaded simultaneously from the parallel input.

Q ← p_in

---

Design Methodology

The Universal Shift Register was implemented using:

- D Flip-Flops for storage
- Multiplexers for mode selection
- Control Logic for shifting and loading operations

Functional Blocks

1. Storage Register Section
2. Shift Left Logic
3. Shift Right Logic
4. Parallel Load Logic
5. Mode Selection Logic
6. Serial Input and Output Paths

The selected operation depends on the value of the mode selection signal.

---

RTL Analysis

The RTL schematic generated in Vivado shows:

- Multiple multiplexers used for selecting different operating modes.
- Register blocks for storing data.
- Parallel input and output paths.
- Serial input and output connections.
- Control circuitry for shift and load operations.

The synthesized RTL structure confirms the implementation of a multifunctional sequential circuit capable of performing all Universal Shift Register operations.

RTL Diagram

<img width="1030" height="532" alt="image" src="https://github.com/user-attachments/assets/28e1cbce-68ba-42cb-8db6-ebd9a0e4d3b4" />



---

Verilog Implementation

The design was implemented using Verilog HDL and consists of:

- Clock-driven sequential logic
- Multiplexer-based mode selection
- Parallel load circuitry
- Bidirectional shift operations

Features

- Hold current data
- Shift left
- Shift right
- Parallel data loading
- Serial data input and output
- Reset functionality

---

Simulation and Verification

A Verilog testbench was developed to verify all operating modes of the Universal Shift Register.

Test Cases

Reset Operation

Signal| Value
rst| 1

Expected Output:

p_out = 0000

Result: PASS ✅

---

Parallel Load Operation

Signal| Value
load| 1
p_in| Input Data

Expected Output:

p_out = p_in

Result: PASS ✅

---

Shift Right Operation

Signal| Value
shift| 1
mod| 01

Expected Behavior:

Data shifts toward the least significant bit.

Result: PASS ✅

---

Shift Left Operation

Signal| Value
shift| 1
mod| 10

Expected Behavior:

Data shifts toward the most significant bit.

Result: PASS ✅

---

Simulation Observation

The simulation waveform verifies:

- Proper clock operation.
- Successful reset initialization.
- Correct mode selection.
- Parallel data loading.
- Shift-left operation.
- Shift-right operation.
- Serial data transfer.

The observed outputs matched the expected functionality for each operating mode.

Simulation Waveform

<img width="1529" height="764" alt="image" src="https://github.com/user-attachments/assets/e50f87bb-c51b-4085-b366-56c6e64310d0" />

---

Observations

- The register successfully performed multiple operations using a single hardware design.
- Parallel data was loaded correctly in one clock cycle.
- Shift operations transferred data accurately between register stages.
- Reset initialized the register to a known state.
- Mode selection logic correctly controlled the operation performed.
- Simulation results matched theoretical expectations.

---

Conclusion

A 4-bit Universal Shift Register (USR) was successfully designed, implemented, and verified using Verilog HDL. The design supports Hold, Shift Left, Shift Right, and Parallel Load operations. Functional simulation and RTL analysis confirmed the correctness of the implementation. This task provided practical experience in sequential circuit design, register operations, multiplexing techniques, and hardware verification using Xilinx Vivado.

---

Tools Used

- Xilinx Vivado
- Verilog HDL

Concepts Learned

- Shift Register Architecture
- Universal Shift Register Operation
- Sequential Logic Design
- Multiplexer-Based Control Logic
- Serial and Parallel Data Transfer
- RTL Analysis
- Testbench Development
- Functional Simulation
