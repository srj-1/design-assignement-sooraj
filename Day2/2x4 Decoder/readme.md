# Day 1 – Assignment 2: 2-to-4 Decoder Design and Verification

## 1. Objective

To design and verify a 2-to-4 Decoder using Verilog HDL and simulate its functionality using Xilinx Vivado.

---

## 2. Introduction

A Decoder is a combinational logic circuit that converts binary information from *n* input lines into a maximum of *2ⁿ* output lines. A **2-to-4 Decoder** has two input lines and four output lines. Depending on the binary input combination, only one output is activated while all other outputs remain LOW.

Decoders are widely used in digital systems for:

* Memory address decoding
* Data routing and distribution
* Instruction decoding in processors
* Digital communication systems

---

## 3. Theory

A 2-to-4 Decoder accepts a 2-bit binary input and activates one of four output lines corresponding to the binary value of the input.

### 3.1 Truth Table

| Input (I1 I0) | Output (Y3 Y2 Y1 Y0) |
| ------------- | -------------------- |
| 00            | 0001                 |
| 01            | 0010                 |
| 10            | 0100                 |
| 11            | 1000                 |

Only one output remains HIGH for each input combination.

---

## 4. Working Principle

The decoder continuously monitors the 2-bit input and generates the corresponding output.

* If Input = 00, output **Y0** becomes HIGH.
* If Input = 01, output **Y1** becomes HIGH.
* If Input = 10, output **Y2** becomes HIGH.
* If Input = 11, output **Y3** becomes HIGH.

Thus, the binary input is decoded into one of four unique output lines.

---

## 5. Design Methodology

The design was implemented using a Verilog **case statement**.

### Inputs

* `i[1:0]` : 2-bit input

### Outputs

* `Y[3:0]` : 4-bit decoded output

### Verilog Logic

```verilog
case(i)
    2'b00 : Y = 4'b0001;
    2'b01 : Y = 4'b0010;
    2'b10 : Y = 4'b0100;
    2'b11 : Y = 4'b1000;
endcase
```

The case statement selects the appropriate output pattern based on the input value.

---

## 6. RTL Analysis

The RTL schematic generated in Vivado shows:

* A multiplexer-based implementation of the decoder logic.
* Four constant output values:

  * 0001
  * 0010
  * 0100
  * 1000
* Input lines acting as select signals.

The synthesized circuit correctly realizes the functionality of a 2-to-4 Decoder.

<img width="1036" height="538" alt="image" src="https://github.com/user-attachments/assets/c002e978-03d5-474c-aa4b-0512721c54d4" />


---

## 7. Simulation and Verification

A Verilog testbench was developed to verify all possible input combinations.

### Test Cases

| Input (i) | Expected Output (Y) |
| --------- | ------------------- |
| 00        | 0001                |
| 01        | 0010                |
| 10        | 0100                |
| 11        | 1000                |

### Example Observation

From the simulation waveform:

| Input | Output   |
| ----- | -------- |
| 10    | 0100 (4) |
| 11    | 1000 (8) |

The output changes correctly according to the applied input values.

**Result:** PASS

<img width="1524" height="759" alt="image" src="https://github.com/user-attachments/assets/6c238adf-fe38-436f-ade5-2c2210ab8fb2" />



---

## 8. Observations

* Only one output was HIGH at any given time.
* The output changed immediately with changes in the input.
* Simulation results matched the theoretical truth table.
* RTL schematic confirmed the correct synthesis of decoder logic.
* The design successfully converted binary input information into unique output lines.

---

## 9. Conclusion

A 2-to-4 Decoder was successfully designed, implemented, and verified using Verilog HDL. The simulation results matched the expected truth table, confirming the correctness of the design. RTL analysis further validated the hardware implementation. This assignment provided practical experience in combinational circuit design, Verilog coding, simulation, and RTL verification.

