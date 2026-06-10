# Day 1 – BCD Adder Design and Verification

## 1. Objective

To design and verify a 4-bit Binary Coded Decimal (BCD) Adder using Verilog HDL and simulate its functionality using Xilinx Vivado.

## 2. Introduction

A Binary Coded Decimal (BCD) Adder is a digital circuit used to add two decimal digits represented in BCD format. Since BCD represents decimal digits (0–9) using 4-bit binary codes, the sum of two BCD digits may exceed the valid BCD range. In such cases, a correction value of decimal 6 (0110) is added to obtain a valid BCD result.

### Applications

* Digital clocks
* Calculators
* Electronic meters
* Financial and accounting systems

---

## 3. Theory

### 3.1 BCD Number System

In BCD representation, each decimal digit is encoded separately using 4 bits.

| Decimal | BCD  |
| ------- | ---- |
| 0       | 0000 |
| 1       | 0001 |
| 2       | 0010 |
| 3       | 0011 |
| 4       | 0100 |
| 5       | 0101 |
| 6       | 0110 |
| 7       | 0111 |
| 8       | 1000 |
| 9       | 1001 |

The binary values from 1010 to 1111 are invalid BCD representations.

### 3.2 Working Principle

1. Add the two BCD digits using a 4-bit Ripple Carry Adder (RCA).
2. Check whether:

   * A carry is generated, or
   * The sum exceeds 1001 (decimal 9).
3. If either condition is true, add 0110 (decimal 6) to the intermediate sum.
4. The corrected output becomes the valid BCD result.

---

## 4. Design Methodology

The BCD Adder was implemented using three major blocks.

### 4.1 Ripple Carry Adder (RCA)

Inputs:

* A[3:0]
* B[3:0]
* Cin

Outputs:

* Intermediate Sum
* Carry Output

### 4.2 Correction Logic

The correction condition is given by:

Correction = Cout + (S3 · S2) + (S3 · S1)

where:

* Cout = Carry output of the first RCA
* S3, S2, S1 = Intermediate sum bits

If the correction signal becomes HIGH, the value 0110 is added to the intermediate sum.

### 4.3 Second Ripple Carry Adder

The second RCA adds:

* Intermediate Sum
* Correction Value (0110)

Outputs:

* Final BCD Sum
* Final Carry

---

## 5. Block Diagram

The BCD Adder consists of:

1. First Ripple Carry Adder
2. Correction Logic using AND and OR gates
3. Second Ripple Carry Adder

The RTL schematic generated in Vivado verifies the architecture of the design.

<img width="1053" height="528" alt="image" src="https://github.com/user-attachments/assets/993cfbf2-dcc8-4033-b6c8-62b8e6aa710f" />


---

## 6. Verilog Implementation

The design was implemented using Verilog HDL with a hierarchical structure.

Modules Used:

* Full Adder
* Ripple Carry Adder
* BCD Adder

The correction logic automatically detects invalid BCD outputs and performs decimal correction.

---

## 7. Simulation and Verification

A Verilog testbench was developed to verify the functionality of the BCD Adder.

### Test Case 1

| Input | Value |
| ----- | ----- |
| A     | 3     |
| B     | 4     |
| Cin   | 0     |

Expected Output:

3 + 4 = 7

Observed Output:

| Sum | Carry |
| --- | ----- |
| 7   | 0     |

**Result:** PASS

### Test Case 2

| Input | Value |
| ----- | ----- |
| A     | 5     |
| B     | 6     |
| Cin   | 0     |

Expected Output:

5 + 6 = 11

BCD Representation:

0001 0001

Observed Output:

| Sum | Carry |
| --- | ----- |
| 1   | 1     |

**Result:** PASS

<img width="1594" height="845" alt="image" src="https://github.com/user-attachments/assets/8f7b6ac5-238f-4359-b7ba-a00010e21c32" />


---

## 8. Observations

* The first Ripple Carry Adder correctly generated the binary sum.
* The correction logic successfully detected invalid BCD outputs.
* Addition of decimal 6 converted invalid binary results into valid BCD format.
* Simulation results matched the expected theoretical outputs.
* The RTL schematic confirmed the correct hardware implementation.

---

## 9. Conclusion

A 4-bit BCD Adder was successfully designed and verified using Verilog HDL. The design correctly performs BCD addition by detecting invalid outputs and applying the required correction factor. Functional simulation and RTL analysis confirmed the correctness of the implementation.

