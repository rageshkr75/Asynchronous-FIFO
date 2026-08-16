# Asynchronous FIFO: Sky130 RTL-to-GDSII

Physical implementation of a dual-clock asynchronous FIFO targeting the Skywater 130nm standard cell library. Generated via the OpenLane automated physical design flow.

## Technical Specifications
* **Architecture:** Dual-clock domain handling asynchronous read and write operations.
* **Cross-Domain Synchronization:** 2-stage Flip-Flop synchronizers utilized to mitigate metastability when signals cross clock boundaries.
* **Pointer Encoding:** Gray Code is used for pointer synchronization to ensure only a single bit changes per transition, preventing multi-bit transition errors and unpredictable data loss across asynchronous boundaries.
* **Status Logic:** Empty and Full flags resolved natively in their respective clock domains.
* **Process Node:** Skywater 130nm (`sky130A`).
* **Standard Cell Library:** `sky130_fd_sc_hd`.

## Verification Status: Tape-Out Ready
Gate-Level Simulation (GLS) confirms structural and physical timing integrity.
* **Methodology:** Verification of the routed netlist against a behavioral golden reference model.
* **Timing Checks:** SDF back-annotation applied (Typical PVT corner). 
* **Power-Aware Simulation:** Physical power and ground pins (`VPWR`, `VGND`) explicitly driven to validate setup/hold limits and verify X-state suppression.
* **Result:** 0 functional mismatches; 0 timing violations.

## Directory Structure
* `src/` - Verilog RTL source files.
* `sim/` - Testbench File.
* `openlane/` - constraint file and .json file.
* `docs/` - GDSII layout captures and terminal execution logs.

## References
1. Cummings, C. E. (2002). Simulation and Synthesis Techniques for Asynchronous FIFO Design. *Synopsys Users Group (SNUG)*. 
2. Cadence Design Systems. (2004). *Clock Domain Crossing: Closing the loop on clock domain functional implementation problems*.
