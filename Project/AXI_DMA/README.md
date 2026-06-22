AXI DMA Verification Environment
-------------------------------
Project Description:
This is the verification environment for an AXI DMA Controller. This project uses layering and constrained randomization to verify both normal DMA operations and Scatter Gather (SG).

Testbench Architecture
-----------------------
The testbench implementation adheres to the commonly-used modular approach:

transaction.sv:Specifies the data object (DMA parameters, such as src_addr, dest_addr, transfer_bytes, and sg_mode) and constraints.

generator.sv: Responsible for creating and randomizing transaction objects and supporting test-specific customization (forcing the mode or size).

driver.sv: Controls the virtual interface (axi_dma_if) by converting transactions into AXI/Control pins.

monitor.sv: Monitors the AXI bus traffic and forwards data to the scoreboard for checking.

scoreboard.sv:Stores the observed transactions and checks the output (such as the number of valid write transactions).

agent.sv: Component responsible for creating instances of the Generator, Driver, and Monitor.

environment.sv:The top-level verification component.

test.sv: File containing the base test class and individual tests (test_16bit_normal, test_scatter_gather, test_randomized).

testbench.sv: The top-level module containing the design under test (DUT), clock generation, reset logic, and slave models (memory emulation).


Features
--------
Constrained Random Verification: Utilizes SystemVerilog's rand and constraint blocks for varied traffic generation.  
Scatter-Gather Capability: Supports testing in both normal operation mode and SG (descriptor) mode.  
Hierarchical Testing: Shows versatility by implementing class hierarchy, facilitating the creation of different test scenarios (Normal, SG and Random).  
Simulation Control: Has custom reset procedures and tear down methods for reliable operation between tests in the same simulation session.


The Common Control Logic:
In both waveforms, you should notice the normal “handshaking” procedure used to start a transfer, matching what you implemented in your driver.sv code:
DMA_EN (Enable): Should be high before the transfer begins. Means that the DMA is ready to take instructions.
DMA_GO (Start): Pulse (normally for one clock cycle) that instructs the DMA to “capture” the register values (Address, Length, Chunk Size) and start the transfer.
DMA_DONE (Status): Signal asserted by the hardware after the transfer is done.

Waveform 2: DMA Operation in Normal Mode
In this waveform, the firmware (or the generator/driver, in your case) manually sets the source address, destination address, and transfer count to the DMA registers.
Important Signals to be identified:
SG_MODE = 0: Shows that the DMA is not seeking for any descriptor in the memory.
Data Registers: DMA_SRC, DMA_DST, and DMA_BNUM (Byte Number) will show steady values just before the DMA_GO pulse.
Operation: The DMA transfers data in one block from the source address to the destination address. When DMA_DONE pulse occurs, the transfer is complete.

Waveform 2: Scatter-Gather (SG) Mode
It is applied for more complicated transfers when the data may not be located in contiguous memory addresses.

Important Signals to identify:
SG_MODE = 1: It means that the DMA engine has been programmed to fetch “Buffer Descriptors” (BDs) from the memory.
SG_DESC_ADDR: Now you have to provide the address of the beginning of the Descriptor table in memory instead of Source/Destination.

Operation:
The DMA pulses DMA_GO.
The DMA engine automatically fetches the descriptor from the memory.
Then it executes all transfers as defined by this descriptor.
If there are several descriptors, it follows “Next Descriptor” pointers until the end of the whole list. 
SG_DONE / DMA_DONE: In SG mode you may observe SG_DONE signal being asserted after processing the whole list of descriptors or individual DMA_DONE pulses if the DMA engine works with several descriptors.



<img width="1600" height="654" alt="WhatsApp Image 2026-06-22 at 7 22 05 PM (1)" src="https://github.com/user-attachments/assets/2141ff69-036e-4dc1-923e-4745e326a64f" />
<img width="1600" height="634" alt="WhatsApp Image 2026-06-22 at 7 22 05 PM (4)" src="https://github.com/user-attachments/assets/59918d0c-c47a-4350-9e46-c77b3d09294f" />
