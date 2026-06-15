# Day 6 – Task 1: Creating a Transaction Class for FIFO Verification

## Objective

To create a SystemVerilog **Transaction Class** for FIFO verification and generate randomized stimulus using constraints. This task introduces Object-Oriented Programming (OOP) concepts in SystemVerilog and serves as the foundation for building a verification environment.

---

# Introduction

In modern verification methodologies, transactions are used to represent data packets exchanged between the testbench and the Design Under Test (DUT).

A **Transaction Class** groups all FIFO-related signals into a single object and allows random generation of stimulus using constraints. This approach improves code reusability, readability, and scalability compared to traditional signal-by-signal testbench coding.

---

# Theory

## What is a Transaction?

A transaction is a collection of input and output signals represented as a class object.

For FIFO verification, a transaction contains:

- Reset signal
- Write enable signal
- Read enable signal
- Input data
- Output data
- Full flag
- Empty flag

Instead of handling these signals individually, they are bundled into a single transaction object.

---

## Randomization

SystemVerilog supports constrained random stimulus generation using the `rand` keyword.

### Advantages

- Automatic test generation
- Better coverage
- Reduced manual effort
- Helps uncover corner-case bugs

---

## Constraint-Based Verification

Constraints control how random values are generated.

In this task:

### Reset Distribution

```systemverilog
rst_tb dist {0:=8, 1:=2};
```

Meaning:

- Reset inactive (0) → 80%
- Reset active (1) → 20%

---

### Write Enable Distribution

```systemverilog
wrenb_tb dist {0:=2, 1:=8};
```

Meaning:

- Write disabled → 20%
- Write enabled → 80%

---

### Read Enable Distribution

```systemverilog
rdenb_tb dist {0:=8, 1:=2};
```

Meaning:

- Read disabled → 80%
- Read enabled → 20%

---

### Data Distribution

```systemverilog
data_in_tb dist {
    8'hFF := 10,
    8'hAA := 5,
    8'h55 := 5
};
```

Meaning:

| Data Value | Weight |
|------------|---------|
| FF | 10 |
| AA | 5 |
| 55 | 5 |

The value `FF` has the highest probability of being generated.

---

# Transaction Class Structure

The transaction class contains:

### Random Variables

```systemverilog
rand bit rst_tb;
rand bit wrenb_tb;
rand bit rdenb_tb;
rand bit [7:0] data_in_tb;
```

These variables are randomized during simulation.

---

### Non-Random Variables

```systemverilog
bit [7:0] data_out_tb;
bit full;
bit empty;
```

These variables store DUT outputs.

---

### Display Method

A display function is included for printing transaction contents.

```systemverilog
function void display();
```

This helps monitor generated stimulus and DUT responses.

---

# SystemVerilog Implementation

```systemverilog
class transaction;

    rand bit rst_tb, wrenb_tb, rdenb_tb;
    rand bit [7:0] data_in_tb;

    bit [7:0] data_out_tb;
    bit full, empty;

    constraint c1 {

        rst_tb   dist {0:=8, 1:=2};
        wrenb_tb dist {0:=2, 1:=8};
        rdenb_tb dist {0:=8, 1:=2};

        data_in_tb dist {
            8'hFF := 10,
            8'hAA := 5,
            8'h55 := 5
        };
    }

    function void display();
        $display("rst=%0d wrenb=%0d rdenb=%0d din=%0h dout=%0h full=%0b empty=%0b",
                  rst_tb, wrenb_tb, rdenb_tb,
                  data_in_tb, data_out_tb,
                  full, empty);
    endfunction

endclass
```

---

# Features of the Transaction Class

✔ Uses Object-Oriented Programming

✔ Supports Constrained Random Verification

✔ Generates FIFO input stimulus

✔ Stores FIFO output responses

✔ Includes built-in transaction printing

✔ Easily reusable in Generator, Driver, and Monitor components

---

# Verification Significance

This transaction class forms the foundation for advanced verification environments.

It will later be used by:

- Generator
- Driver
- Monitor
- Scoreboard
- Environment

These components communicate using transaction objects rather than individual signals.

---

# Observations

- Successfully created a reusable FIFO transaction object.
- Random variables were declared using the `rand` keyword.
- Constraints controlled reset, read, write, and data generation.
- Distribution constraints biased stimulus toward meaningful FIFO operations.
- Display method provides easy transaction debugging.

---

# Conclusion

A SystemVerilog Transaction Class was successfully created for FIFO verification. The class encapsulates FIFO inputs and outputs into a reusable object and uses constrained randomization to generate realistic stimulus. This task introduces the core concept of transaction-based verification and serves as the first step toward building a complete SystemVerilog verification environment.

---

- Constraint Randomization
- Distribution Constraints (`dist`)
- Display Functions
- FIFO Verification Fundamentals
- Object-Oriented Verification Methodology
