# Day 4– Task 1: BLOCK MEMORY GENERATOR

## Objective

To design and verify an **8-bit Single-Port RAM** using Verilog HDL and simulate its read and write operations using Xilinx Vivado.

---

## Introduction

Random Access Memory (RAM) is a storage device used to temporarily store data that can be accessed directly using memory addresses. Unlike sequential storage devices, RAM allows data to be written to and read from any memory location independently.

A **Single-Port RAM** uses one communication port for both read and write operations. The memory location is selected using an address input, and data can either be stored or retrieved depending on the control signals.

### Applications

* Data Storage Systems
* Embedded Systems
* Digital Signal Processing
* Microcontrollers
* FPGA-Based Designs
* Buffer Memory

---

## Theory

A Single-Port RAM consists of memory locations addressed through an address bus.

### Inputs

| Signal         | Description                   |
| -------------- | ----------------------------- |
| clk            | Clock Signal                  |
| arstn          | Active-Low Asynchronous Reset |
| wrenb          | Write Enable                  |
| wraddress[7:0] | Write Address                 |
| rdaddress[7:0] | Read Address                  |
| d_in[7:0]      | Input Data                    |

### Output

| Signal        | Description |
| ------------- | ----------- |
| data_out[7:0] | Output Data |

### Memory Organization

* Data Width = 8 bits
* Address Width = 8 bits
* Number of Locations = 256
* Memory Type = Single-Port RAM

---

## Working Principle

The RAM operates in two modes:

### Write Operation

When the write enable signal is HIGH:

```text
wrenb = 1
```

The input data is stored at the memory location specified by the write address.

```text
Memory[wraddress] ← d_in
```

### Read Operation

When a read address is provided, the data stored at the specified memory location is retrieved.

```text
data_out ← Memory[rdaddress]
```

The output reflects the contents of the selected memory location.

---

## Design Methodology

The RAM was implemented using:

* Memory Register Array
* Address Decoding Logic
* Read Multiplexer
* Write Control Logic
* Asynchronous Reset Circuit

### Functional Blocks

1. Memory Array
2. Write Address Decoder
3. Read Address Selection Logic
4. Output Register
5. Reset Logic

---

## RTL Analysis

The RTL schematic generated in Vivado shows:

* Multiple memory registers representing RAM locations.
* Address decoding logic for write operations.
* Multiplexer-based read logic.
* Output register for data retrieval.
* Reset circuitry for memory initialization.

The RTL structure confirms the implementation of a memory block with independent read and write addressing.

### RTL Diagram

<img width="1052" height="524" alt="image" src="https://github.com/user-attachments/assets/ce647c7f-ef3d-457c-bbab-3e954c037747" />


---

## Verilog Implementation

The design was implemented using Verilog HDL.

### Features

* 8-bit Data Storage
* 256 Addressable Locations
* Independent Read and Write Addresses
* Write Enable Control
* Asynchronous Reset
* Registered Output

---

## Simulation and Verification

A Verilog testbench was developed to verify memory operations.

### Test Case 1: Write Data

| Write Address | Data Written |
| ------------- | ------------ |
| 01            | 55           |
| 02            | AA           |

Expected Result:

```text
Memory[01] = 55
Memory[02] = AA
```

Result: PASS ✅

---

### Test Case 2: Read Data

| Read Address | Expected Output |
| ------------ | --------------- |
| 01           | 55              |
| 02           | AA              |

Observed Output:

| Address | Data Out |
| ------- | -------- |
| 01      | 55       |
| 02      | AA       |

Result: PASS ✅

---

### Test Case 3: Additional Data Access

| Address | Data |
| ------- | ---- |
| 02      | F0   |

The output correctly reflected the data stored at the selected memory location.

Result: PASS ✅

---

## Simulation Observation

The waveform confirms that:

* Reset initializes the memory system.
* Data values are written successfully when `wrenb` is asserted.
* Different memory locations store independent data values.
* Read operations correctly retrieve stored data.
* Address changes result in the expected output data.
* Memory contents are preserved until overwritten.

### Sample Memory Transactions

| Address | Data Stored |
| ------- | ----------- |
| 01      | 55          |
| 02      | AA          |
| 02      | F0          |

The output data matched the contents of the addressed memory location.

### Simulation Waveform

<img width="1551" height="711" alt="image" src="https://github.com/user-attachments/assets/fd1087a3-ce0f-4941-8a81-1855b7b3238f" />


---

## Observations

* Data was successfully written to the specified memory addresses.
* Read operations returned the correct stored values.
* Address decoding functioned properly.
* Memory contents remained intact after storage.
* Reset initialized the memory and output correctly.
* Simulation results matched expected RAM behavior.

---

## Conclusion

An **8-bit Single-Port RAM** was successfully designed, implemented, and verified using Verilog HDL. The memory correctly performed write and read operations based on the supplied addresses and control signals. Functional simulation and RTL analysis confirmed the correctness of the design. This task provided practical experience in memory design, address decoding, read/write control logic, and hardware verification using Xilinx Vivado.

