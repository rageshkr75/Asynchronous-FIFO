# \# Asynchronous FIFO: Sky130 RTL-to-GDSII

# 

# Physical implementation of a dual-clock asynchronous FIFO targeting the Skywater 130nm standard cell library. Generated via the OpenLane automated physical design flow.

# 

# \## Technical Specifications

# \* \*\*Architecture:\*\* Dual-clock domain (Asynchronous Read/Write).

# \* \*\*Cross-Domain Synchronization:\*\* 2-stage Flip-Flop synchronizers utilizing Gray Code pointers.

# \* \*\*Status Logic:\*\* Empty and Full flags resolved natively in their respective clock domains.

# \* \*\*Process Node:\*\* Skywater 130nm (`sky130A`).

# \* \*\*Standard Cell Library:\*\* `sky130\_fd\_sc\_hd`.

# 

# \## Verification Status: Tape-Out Ready

# Gate-Level Simulation (GLS) confirms structural and physical timing integrity.

# \* \*\*Methodology:\*\* Continuous functional assertion of the routed netlist against a behavioral golden reference model.

# \* \*\*Timing Checks:\*\* SDF back-annotation applied (Typical PVT corner). 

# \* \*\*Power-Aware Simulation:\*\* Physical power and ground pins (`VPWR`, `VGND`) explicitly driven to validate setup/hold limits and verify X-state suppression.

# \* \*\*Test Stimulus:\*\* Concurrent `fork/join` read/write stress threads maximizing throughput.

# \* \*\*Result:\*\* 0 functional mismatches; 0 timing violations.

# 

# \## Directory Structure

# \* `src/` - Verilog RTL source files.

# \* `sim/` - SystemVerilog testbench for continuous assertion.

# \* `openlane/` - Synthesis and routing configurations (`config.tcl`).

# \* `docs/` - GDSII layout captures and terminal execution logs.

