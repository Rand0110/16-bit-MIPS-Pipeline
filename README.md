# 16-bit MIPS Pipeline in Verilog

A compact **5-stage pipelined 16-bit MIPS-style processor** implemented in Verilog. The design demonstrates the core ideas behind a classic pipelined CPU, including instruction fetch/decode, execution, memory access, write-back, data forwarding, load-use hazard detection, control-flow handling, and simulation/debug support.

## Features

* 16-bit datapath
* 16 general-purpose registers (`r0`-`r15`)
* 5-stage pipeline:

  * **IF** - Instruction Fetch
  * **ID** - Instruction Decode / Register Read
  * **EX** - Execute / ALU
  * **MEM** - Data Memory Access
  * **WB** - Register Write-Back
* Pipeline registers between ID/EX, EX/MEM, and MEM/WB
* Data forwarding from EX/MEM and MEM/WB
* Load-use hazard detection and pipeline stalling
* Branch and jump control-flow handling
* 256-word instruction memory
* 256-word data memory
* Memory-mapped output at address `0xFFFC`
* `HALT` instruction for terminating simulation
* Cycle-by-cycle pipeline debug output
* VCD waveform generation for waveform viewers such as GTKWave

## Project Structure

```text
16-bit-MIPS-Pipeline/
├── alu.v                    # 16-bit arithmetic/logic unit
├── control_unit.v           # Instruction decode and control signals
├── ex_mem_reg.v             # EX/MEM pipeline register
├── forwarding_unit.v        # EX/MEM and MEM/WB forwarding logic
├── hazard_detection_unit.v  # Load-use hazard detection
├── id_ex_reg.v              # ID/EX pipeline register
├── instr_mem.v              # Instruction memory and test program
├── instr_mem.hex            # Optional instruction-memory data file
├── mem_wb_reg.v             # MEM/WB pipeline register
├── mips_pipeline.v          # Top-level pipelined processor
├── mips_pipeline_tb.v       # Simulation testbench
├── reg_file.v               # 16 x 16-bit register file
└── README.md
```

## Pipeline Overview

```text
        +------+     +------+     +------+     +------+     +------+
 PC --> |  IF  | --> |  ID  | --> |  EX  | --> | MEM  | --> |  WB  |
        +------+     +------+     +------+     +------+     +------+
                        |              ^            |            |
                        |              |            |            |
                        +-------- Hazard / Forwarding -----------+
```

## Hazard Handling

### Data Forwarding

`forwarding_unit.v` detects dependencies between the instruction in the EX stage and destination registers in the EX/MEM and MEM/WB stages.

Forwarding priority:

1. EX/MEM result
2. MEM/WB result
3. Original ID/EX register value

### Load-Use Stall

`hazard_detection_unit.v` stalls the program counter and IF/ID update when an instruction immediately depends on a value being loaded by the instruction ahead of it.

### Control Hazards

Taken branches and jump-style instructions cause the IF/ID instruction register to be cleared, inserting a bubble into the pipeline.

## Instruction Support

The control logic currently contains decode paths for:

| Type      | Instructions / Operations                    |
| --------- | -------------------------------------------- |
| R-type    | `ADD`, `SUB`, `AND`, `OR`, `SLTU`            |
| Immediate | `LUI`, `ANDI`, `ORI`, `SLTU`-style immediate |
| Memory    | `LW`, `SW`                                   |
| Branch    | `BEQ`, `BNE`                                 |
| Jump      | `J`, `JAL`, `JR`                             |
| Control   | `HALT`                                       |

> **Note:** This is a custom 16-bit MIPS-style ISA and is not binary-compatible with the standard 32-bit MIPS ISA.

## Running the Simulation

### Icarus Verilog

```bash
iverilog -g2012 -o mips_pipeline_sim \
  mips_pipeline_tb.v \
  mips_pipeline.v \
  alu.v \
  control_unit.v \
  reg_file.v \
  hazard_detection_unit.v \
  forwarding_unit.v \
  id_ex_reg.v \
  ex_mem_reg.v \
  mem_wb_reg.v \
  instr_mem.v
```

Run:

```bash
vvp mips_pipeline_sim
```

## Waveforms

The testbench creates:

```text
wave.vcd
```

Open the waveform with GTKWave:

```bash
gtkwave wave.vcd
```

Useful signals include:

* `instr`
* `if_id_instr`
* `id_ex_reg_data1`
* `ex_mem_alu_result`
* `write_back_data`

## Memory-Mapped I/O

Stores to:

```text
0xFFFC
```

are treated as console output rather than normal memory writes.

The simulator displays:

```text
MMIO OUTPUT: <decimal value> (0x<hex value>)
```

## Current Implementation Notes

A few parts of the current source are useful targets for further verification and development:

* ALU control encodings should be kept synchronized between `control_unit.v` and `alu.v`.
* Instruction bit patterns in `instr_mem.v` should remain synchronized with the opcode definitions in `control_unit.v`.
* Some comments in the bundled instruction-memory test program currently name instructions whose bit patterns do not match the control-unit decode table.
* `JAL` link-register handling may need additional pipeline/write-back logic for complete architectural behavior.
* Branch decisions are made from register-file values during decode, so branch dependencies may require additional forwarding or stalls.
* `r0` is initialized to zero, but writes to `r0` are not explicitly blocked.

## Suggested Improvements

* Add an assembler/instruction encoder
* Add self-checking testbench assertions
* Add expected-vs-actual register checking
* Add branch forwarding/stalling
* Hardwire `r0` to zero
* Complete `JAL` write-back to `r15`
* Load programs using `$readmemh`
* Add FPGA synthesis support
* Add GitHub Actions simulation

## Educational Goals

This project demonstrates:

* Pipelined processor organization
* Pipeline registers
* RAW data hazards
* Forwarding/bypassing
* Pipeline stalls
* Control hazards
* Register-file access
* ALU control
* Load/store memory behavior
* Verilog simulation
* Waveform-based debugging

## License

No license file is currently included. Consider adding a license such as MIT if the repository will be publicly shared or reused.

---

Built as a Verilog implementation of a compact 16-bit MIPS-style pipelined processor for learning, simulation, and further experimentation.
