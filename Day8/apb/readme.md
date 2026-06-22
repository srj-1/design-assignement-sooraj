# Day 8 – Task 1: APB Interface Design and Verification

## 1. Objective

To design and implement a SystemVerilog APB Interface for APB Slave verification. The interface groups all APB protocol signals into a single reusable communication channel and simplifies interaction between the Design Under Test (DUT) and verification components.

---

## 2. Introduction

SystemVerilog Interfaces provide an efficient mechanism for grouping related signals into a single construct. In verification environments, interfaces reduce the complexity of port connections and improve code readability.

The Advanced Peripheral Bus (APB) is widely used in System-on-Chip (SoC) designs for communication with low-bandwidth peripherals. The APB interface developed in this task contains all signals required for APB communication and serves as a bridge between the DUT and verification components such as the Driver and Monitor.

---

## 3. Theory

### APB Protocol Overview

APB is a simple, low-power bus protocol used for peripheral communication. Transactions are performed in two phases:

### Setup Phase

During the setup phase:

* PSEL = 1
* PENABLE = 0

The address and control information are placed on the bus.

### Access Phase

During the access phase:

* PSEL = 1
* PENABLE = 1

The read or write operation takes place.

### APB Interface Signals

| Signal  | Width | Description                |
| ------- | ----- | -------------------------- |
| clk     | 1     | Clock signal               |
| rst_n   | 1     | Active-low reset           |
| paddr   | 32    | Address bus                |
| psel    | 1     | Slave select               |
| penable | 1     | Transfer enable            |
| pwrite  | 1     | Read/Write control         |
| pwdata  | 32    | Write data bus             |
| prdata  | 32    | Read data bus              |
| pready  | 1     | Transfer completion signal |

---

## 4. Working Principle

The APB Interface acts as a shared communication medium between the DUT and verification components.

### Write Operation

1. Driver places address on `paddr`
2. Driver places data on `pwdata`
3. Driver sets `pwrite = 1`
4. Driver asserts `psel`
5. Driver asserts `penable`
6. DUT stores data at the specified address
7. Transaction completes when `pready = 1`

### Read Operation

1. Driver places address on `paddr`
2. Driver sets `pwrite = 0`
3. Driver asserts `psel`
4. Driver asserts `penable`
5. DUT returns data on `prdata`
6. Transaction completes when `pready = 1`

The Monitor observes these signals through the interface and forwards transaction information to the Scoreboard for verification.

---

## 5. Design Methodology

The APB Interface was implemented using a SystemVerilog interface construct.

### Interface Code

```systemverilog
interface apb_if(input logic clk);

    logic rst_n;

    logic [31:0] paddr;

    logic psel;

    logic penable;

    logic pwrite;

    logic [31:0] pwdata;

    logic [31:0] prdata;

    logic pready;

endinterface
```

### Design Features

* Groups all APB signals into a single interface
* Reduces testbench complexity
* Supports virtual interfaces
* Improves code reusability
* Simplifies Driver and Monitor implementation

---

## 6. RTL Analysis

The APB Interface contains all control, address, and data signals required for APB communication.

### RTL Functionality

* Clock synchronizes all APB transfers.
* Reset initializes the DUT and verification environment.
* Address bus selects memory locations.
* Control signals determine transfer type.
* Data buses carry read and write information.
* Ready signal indicates completion of transactions.

### RTL Schematic

**Figure 1: RTL Schematic of APB Interface**

<img width="814" height="408" alt="image" src="https://github.com/user-attachments/assets/c38b547e-def4-4372-9e46-8b6f83456f66" />


**Analysis:**

The RTL schematic shows the APB Interface containing all protocol signals grouped together. The interface acts as a centralized communication structure between the verification environment and the DUT, reducing the need for multiple signal connections.

---

## 7. Simulation Results

The APB Interface was verified using a SystemVerilog testbench. During simulation, APB signals were driven according to protocol timing requirements.

### Observed Operations

* Clock generated successfully.
* Reset asserted and deasserted correctly.
* Write transactions transferred data using `pwdata`.
* Read transactions returned data through `prdata`.
* `psel` and `penable` followed APB timing requirements.
* `pready` indicated successful completion of transfers.

### Simulation Waveform

**Figure 2: APB Interface Simulation Waveform**

<img width="1133" height="468" alt="image" src="https://github.com/user-attachments/assets/376c9b55-26eb-488c-975d-0e3745f8a378" />


**Analysis:**

The simulation waveform confirms correct operation of the APB Interface. Setup and Access phases are clearly visible, and all protocol signals transition according to APB specifications.

---

## 8. Observations

* Successfully created an APB Interface using SystemVerilog.
* All APB protocol signals were grouped into a reusable construct.
* Reduced the number of signal connections in the verification environment.
* Enabled Driver and Monitor communication through a virtual interface.
* Improved readability and maintainability of the testbench.
* APB transactions followed correct protocol timing during simulation.

---

## 9. Conclusion

A SystemVerilog APB Interface was successfully designed and verified. The interface encapsulates all APB protocol signals into a reusable communication structure and simplifies connectivity between the DUT and verification components. The RTL analysis and simulation results confirm correct interface functionality, making it a fundamental building block for transaction-based APB verification environments.

### Key Concepts Learned

* SystemVerilog Interfaces
* APB Protocol Fundamentals
* Virtual Interfaces
* RTL Analysis
* Simulation-Based Verification
* Reusable Verification Components
