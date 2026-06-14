
# Day 5 – Task 1: BCD Adder Verification Using SystemVerilog Interface

## Objective

To verify the previously designed **BCD Adder** using a **SystemVerilog Interface** and demonstrate how interfaces simplify communication between the DUT (Design Under Test) and the testbench.

---

# Introduction

In traditional Verilog testbenches, all DUT signals must be connected individually. As designs become larger, managing numerous signals becomes difficult and error-prone.

SystemVerilog introduces the concept of an **Interface**, which groups related signals into a single construct. This improves readability, scalability, and maintainability of verification environments.

In this task, the same **BCD Adder design developed on Day 1** was verified using a SystemVerilog Interface-based testbench.

---

# Theory

## What is an Interface?

An Interface is a collection of signals bundled together into a single entity.

Instead of connecting signals individually:

```text
a
b
cin
sum
carry
```

all signals are grouped inside one interface.

### Advantages

* Reduces wiring complexity
* Improves code readability
* Simplifies DUT-Testbench connections
* Supports reusable verification environments
* Widely used in UVM-based verification

---

# BCD Adder Overview

A BCD Adder adds two BCD digits and generates a valid BCD result.

If the binary sum exceeds decimal 9, a correction value of **0110 (decimal 6)** is added.

### Inputs

| Signal | Description       |
| ------ | ----------------- |
| a[3:0] | First BCD Number  |
| b[3:0] | Second BCD Number |
| cin    | Carry Input       |

### Outputs

| Signal   | Description  |
| -------- | ------------ |
| sum[3:0] | BCD Sum      |
| carry    | Carry Output |

---

# Interface Declaration

The interface groups all DUT signals into a single structure.

### Signals Included

| Signal   | Description  |
| -------- | ------------ |
| a[3:0]   | Operand A    |
| b[3:0]   | Operand B    |
| cin      | Carry Input  |
| sum[3:0] | Sum Output   |
| carry    | Carry Output |

### Example Interface Structure

```systemverilog
interface bcd_if;

logic [3:0] a;
logic [3:0] b;
logic cin;

logic [3:0] sum;
logic carry;

endinterface
```

---

# Design Methodology

The verification environment consists of:

### 1. Interface

Stores all BCD Adder signals.

### 2. DUT

BCD Adder implemented on Day 1.

### 3. Testbench

Applies stimulus through the interface and observes outputs.

### Verification Flow

```text
Testbench
    ↓
Interface
    ↓
BCD Adder DUT
    ↓
Output Observation
```

---

# RTL Analysis

The RTL schematic remains identical to the Day 1 BCD Adder because only the verification methodology changed.

The design still contains:

* Ripple Carry Adder
* BCD Correction Logic
* Final BCD Addition Stage

### RTL Diagram

*(Insert RTL Schematic Image Here)*

---

# Simulation and Verification

A SystemVerilog testbench was developed using the interface.

### Test Case 1

| Input | Value |
| ----- | ----- |
| A     | 4     |
| B     | 3     |
| Cin   | 0     |

Expected Result:

```text
4 + 3 = 7
```

Observed Output:

| Signal | Value |
| ------ | ----- |
| Sum    | 7     |
| Carry  | 0     |

Result: PASS ✅

---

### Test Case 2

| Input | Value |
| ----- | ----- |
| A     | 5     |
| B     | 6     |
| Cin   | 0     |

Expected Result:

```text
5 + 6 = 11
BCD Output = 0001 0001
```

Observed Output:

| Signal | Value |
| ------ | ----- |
| Sum    | 1     |
| Carry  | 1     |

Result: PASS ✅

---

# Simulation Observation

From the waveform:

### First Input Set

| A | B | Sum | Carry |
| - | - | --- | ----- |
| 4 | 3 | 7   | 0     |

### Second Input Set

| A | B | Sum | Carry |
| - | - | --- | ----- |
| 5 | 6 | 1   | 1     |

The outputs match the expected BCD arithmetic results.

### Simulation Waveform

<img width="1600" height="835" alt="image" src="https://github.com/user-attachments/assets/b4d159eb-25f7-4cf9-b1f3-4b8721145ab4" />


---

# Comparison with Traditional Testbench

| Traditional Verilog           | Interface-Based Verification |
| ----------------------------- | ---------------------------- |
| Individual signal connections | Single interface connection  |
| More wiring                   | Less wiring                  |
| Difficult to scale            | Easily scalable              |
| Less reusable                 | Highly reusable              |
| Basic verification style      | Modern verification style    |

---

# Observations

* Interface successfully grouped all DUT signals.
* DUT and testbench communication became simpler.
* The BCD Adder functionality remained unchanged.
* Simulation results matched Day 1 results.
* Interface reduced signal connection complexity.
* Verification code became cleaner and easier to maintain.

---

# Conclusion

The BCD Adder designed on Day 1 was successfully verified using a **SystemVerilog Interface-based testbench**. The interface simplified signal management and improved testbench organization without affecting the functionality of the DUT. Simulation results confirmed correct BCD addition behavior, demonstrating the advantages of using interfaces in modern verification environments.

---

# Tools Used

* Xilinx Vivado
* Verilog HDL
* SystemVerilog Interface

---

# Concepts Learned

* SystemVerilog Interface
* DUT-Testbench Communication
* Interface-Based Verification
* BCD Adder Verification
* RTL Analysis
* Functional Simulation
* Modern Verification Methodology
