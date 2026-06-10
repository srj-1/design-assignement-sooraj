# Day 3 – Assignment: Sequence Detector (1110) Design and Verification

## 1. Objective

To design and verify a Sequence Detector for detecting the binary sequence **1110** using Verilog HDL and simulate its functionality using Xilinx Vivado.

---

## 2. Introduction

A Sequence Detector is a sequential logic circuit used to identify a specific pattern of bits in a serial input stream. When the desired sequence is detected, the circuit generates an output signal indicating successful detection.

In this assignment, a sequence detector was designed to detect the binary sequence:

**1110**

Sequence detectors are widely used in:

* Digital communication systems
* Pattern recognition circuits
* Error detection systems
* Data transmission protocols
* Control systems

---

## 3. Theory

A Sequence Detector is generally implemented using a Finite State Machine (FSM). The FSM transitions between different states depending on the incoming serial input.

For the target sequence **1110**, the detector keeps track of previously received bits and generates a HIGH output when the complete sequence is detected.

### State Description

| State | Description    |
| ----- | -------------- |
| S0    | Initial State  |
| S1    | Detected '1'   |
| S2    | Detected '11'  |
| S3    | Detected '111' |

When the next input is **0** after reaching S3, the sequence **1110** is detected and the output becomes HIGH.

---

## 4. Working Principle

The detector continuously monitors the serial input bit stream.

### State Transitions

* S0 → S1 when input = 1
* S1 → S2 when input = 1
* S2 → S3 when input = 1
* S3 → Detection State when input = 0

At this point, the sequence **1110** has been received and the output signal is asserted.

After detection, the FSM returns to an appropriate state depending on the design requirements.

---

## 5. Design Methodology

The Sequence Detector was implemented using a Finite State Machine (FSM).

### Inputs

* `clk` : Clock signal
* `rst` : Reset signal
* `din` : Serial input data

### Outputs

* `detected` : Sequence detection output

### Internal Components

* Present State Register
* Next State Logic
* Detection Logic

The FSM updates its state on every positive edge of the clock and compares incoming bits with the target sequence.

---

## 6. RTL Analysis

The RTL schematic generated in Vivado shows:

* State register (`ps_reg`)
* Next-state logic implemented using multiplexers
* Detection logic for output generation
* Clock and reset circuitry

The synthesized design confirms the implementation of a Finite State Machine for sequence detection.

<img width="1562" height="699" alt="image" src="https://github.com/user-attachments/assets/e27311bd-ef98-4af8-98d8-55e7e250af85" />


---

## 7. Verilog Implementation

The design was coded in Verilog HDL using:

* State encoding
* Sequential state register
* Combinational next-state logic
* Output detection logic

The FSM tracks the incoming serial data and asserts the output whenever the sequence **1110** is detected.

---

## 8. Simulation and Verification

A testbench was developed to verify the operation of the Sequence Detector.

### Test Input Stream

```text
1110
```

### Expected Result

| Sequence Received | Detected Output |
| ----------------- | --------------- |
| 1110              | 1               |

### Observed Result

From the simulation waveform:

* Input stream successfully transitions through all FSM states.
* Upon receiving the sequence **1110**, the output `detected` becomes HIGH.
* The output pulse confirms successful sequence detection.

**Result:** PASS ✅

<img width="1544" height="761" alt="image" src="https://github.com/user-attachments/assets/e6c0e2c2-91ea-4caa-807f-5ba2660e6811" />


---

## 9. Observations

* The FSM correctly tracked the incoming serial bits.
* State transitions occurred as expected on each clock edge.
* The output was asserted only when the sequence **1110** was received.
* Reset operation initialized the FSM to the starting state.
* Simulation results matched the expected sequence detection behavior.

---

## 10. Conclusion

A Sequence Detector for detecting the binary sequence **1110** was successfully designed, implemented, and verified using Verilog HDL. The FSM correctly identified the target sequence and generated the detection output. Functional simulation and RTL analysis confirmed the correctness of the design. This assignment provided practical experience in Finite State Machine design, sequential logic implementation, and hardware verification using Vivado.

