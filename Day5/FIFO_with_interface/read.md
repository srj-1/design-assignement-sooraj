
# Day 5 – Task 2: FIFO Verification Using SystemVerilog Interface

## Objective

To verify the **FIFO (First-In First-Out) Memory** designed on Day 3 using a **SystemVerilog Interface-based testbench**, thereby simplifying signal connections and improving verification methodology.

---

# Introduction

A FIFO (First-In First-Out) memory is a data storage structure in which the first data written into the memory is the first data read out. FIFOs are widely used in digital systems for buffering and synchronizing data transfer between modules operating at different speeds.

In Day 3, a FIFO was designed and verified using a conventional Verilog testbench. In this task, the same FIFO design is verified using a **SystemVerilog Interface**, which groups related signals into a single communication channel between the DUT and the testbench.

---

# Theory

## FIFO (First-In First-Out)

FIFO stores data sequentially and retrieves it in the same order.

### FIFO Characteristics

* First data written is the first data read.
* Supports independent write and read operations.
* Provides status indicators such as Full and Empty.
* Commonly used for buffering and data synchronization.

---

## SystemVerilog Interface

An Interface is a SystemVerilog construct that bundles multiple related signals together.

Instead of connecting each signal separately:

```text
clk
rst
wrenb
rdenb
data_in
data_out
full
empty
```

all signals are grouped into a single interface.

### Benefits

* Reduces wiring complexity
* Improves readability
* Simplifies DUT connections
* Supports reusable verification environments
* Forms the basis for advanced verification methodologies such as UVM

---

# FIFO Overview

### Inputs

| Signal       | Description  |
| ------------ | ------------ |
| clk          | Clock Signal |
| rst          | Reset Signal |
| wrenb        | Write Enable |
| rdenb        | Read Enable  |
| data_in[7:0] | Input Data   |

### Outputs

| Signal        | Description          |
| ------------- | -------------------- |
| data_out[7:0] | Output Data          |
| full          | FIFO Full Indicator  |
| empty         | FIFO Empty Indicator |

---

# Interface Declaration

The interface contains all FIFO signals.

### Signals Included

| Signal        | Description  |
| ------------- | ------------ |
| clk           | Clock        |
| rst           | Reset        |
| wrenb         | Write Enable |
| rdenb         | Read Enable  |
| data_in[7:0]  | Input Data   |
| data_out[7:0] | Output Data  |
| full          | Full Flag    |
| empty         | Empty Flag   |

### Example Interface Structure

```systemverilog
interface fifo_if;

logic clk;
logic rst;

logic wrenb;
logic rdenb;

logic [7:0] data_in;
logic [7:0] data_out;

logic full;
logic empty;

endinterface
```

---

# Design Methodology

The verification environment consists of:

### 1. Interface

Stores all FIFO signals.

### 2. FIFO DUT

The FIFO design implemented on Day 3.

### 3. Testbench

Applies write and read operations through the interface.

### Verification Flow

```text
Testbench
    ↓
Interface
    ↓
FIFO DUT
    ↓
Output Observation
```

---

# RTL Analysis

The FIFO architecture remains unchanged from Day 3.

The design consists of:

* Memory Array
* Read Pointer
* Write Pointer
* Full Detection Logic
* Empty Detection Logic
* Read/Write Control Logic

Since only the verification methodology changed, the RTL structure remains identical to the original FIFO design.

### RTL Diagram

*(Insert RTL Schematic Image Here)*

---

# Verilog/SystemVerilog Implementation

The existing FIFO design was connected to the testbench using a SystemVerilog interface.

### Features

* Interface-based signal connection
* FIFO Write Operation
* FIFO Read Operation
* Full and Empty Status Monitoring
* Simplified Testbench Structure

---

# Simulation and Verification

A SystemVerilog testbench was developed to verify FIFO functionality.

---

## Write Operation

The following data values were written into the FIFO:

| Sequence | Data |
| -------- | ---- |
| 1        | 11   |
| 2        | 22   |
| 3        | 33   |
| 4        | 44   |

Expected FIFO Contents:

```text
11 → 22 → 33 → 44
```

Result: PASS ✅

---

## Read Operation

After asserting the read enable signal, the stored data was retrieved.

Expected Output Sequence:

| Read Order | Data |
| ---------- | ---- |
| 1          | 11   |
| 2          | 22   |
| 3          | 33   |
| 4          | 44   |

Observed Output Sequence:

| Read Order | Data |
| ---------- | ---- |
| 1          | 11   |
| 2          | 22   |
| 3          | 33   |
| 4          | 44   |

Result: PASS ✅

---

# Simulation Observation

The waveform confirms:

### Write Phase

| Data Written |
| ------------ |
| 11           |
| 22           |
| 33           |
| 44           |

The FIFO successfully stores incoming data.

### Read Phase

| Data Read |
| --------- |
| 11        |
| 22        |
| 33        |
| 44        |

The FIFO outputs data in the same order in which it was written.

### FIFO Status Flags

| Signal | Function                |
| ------ | ----------------------- |
| Full   | Indicates FIFO is full  |
| Empty  | Indicates FIFO is empty |

The flags behaved correctly during write and read operations.

### Simulation Waveform

<img width="1600" height="899" alt="image" src="https://github.com/user-attachments/assets/85b64044-94c9-4177-abbb-6071cf400c39" />


---

# Comparison with Traditional Testbench

| Traditional Verilog TB        | Interface-Based TB          |
| ----------------------------- | --------------------------- |
| Individual signal connections | Single interface connection |
| More wiring                   | Less wiring                 |
| Difficult to maintain         | Easy to maintain            |
| Less reusable                 | Highly reusable             |
| Basic verification style      | Modern verification style   |

---

# Observations

* FIFO successfully stored input data.
* Data was read in FIFO order.
* Full and Empty flags operated correctly.
* Interface reduced connection complexity.
* Verification code became cleaner and easier to understand.
* Simulation results matched the expected FIFO behavior.

---

# Conclusion

The FIFO designed on Day 3 was successfully verified using a **SystemVerilog Interface-based testbench**. The interface simplified communication between the DUT and the testbench while preserving the original FIFO functionality. Simulation results confirmed correct FIFO operation, including write, read, full, and empty conditions. This task provided practical experience in interface-based verification and demonstrated the advantages of modern SystemVerilog verification techniques.

---

# Tools Used

* Xilinx Vivado
* Verilog HDL
* SystemVerilog Interface

---

# Concepts Learned

* FIFO Architecture
* FIFO Verification
* SystemVerilog Interface
* DUT-Testbench Communication
* Full and Empty Flag Detection
* RTL Analysis
* Functional Simulation
* Interface-Based Verification Methodology
