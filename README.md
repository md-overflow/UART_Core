# UART Core — RTL Design & UVM Verification

**A complete UART Core**  
*Designed in Verilog/SystemVerilog · Verified with a full UVM testbench · Simulated on QuestaSim & VCS*

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Project Structure](#-project-structure)
- [RTL Architecture](#-rtl-architecture)
  - [Module Hierarchy](#module-hierarchy)
  - [Baud Rate Generator](#baud-rate-generator)
  - [UART Transmitter FSM](#uart-transmitter-fsm)
  - [UART Receiver FSM](#uart-receiver-fsm)
  - [FIFO Buffer](#fifo-buffer)
- [UVM Testbench Architecture](#-uvm-testbench-architecture)
  - [Testbench Hierarchy](#testbench-hierarchy)
  - [TX Agent](#tx-agent)
  - [RX Agent](#rx-agent)
  - [Scoreboard](#scoreboard)
- [UART Frame Format](#-uart-frame-format)
- [Interface Signals](#-interface-signals)
- [Simulation Results](#-simulation-results)
- [Getting Started](#-getting-started)
- [Makefile Targets](#-makefile-targets)
- [Tools & Requirements](#-tools--requirements)
- [Author](#-author)

---

## 🔭 Overview

This project implements a full **UART (Universal Asynchronous Receiver/Transmitter)** IP Core from scratch, covering both RTL design and functional verification. The design follows a classic FIFO-buffered architecture with a 16× oversampling baud rate generator, operating at configurable baud rates and clock frequencies.

The verification environment is built entirely in **UVM 1.1d** following industry best practices — dual agents (TX and RX), a self-checking scoreboard, constrained-random stimulus, and HTML coverage reports generated from QuestaSim.

> UART converts parallel data from a CPU bus into a serial bitstream for transmission, and reconstructs a serial bitstream back to parallel bytes on reception — all without a shared clock between communicating devices.

**Simulation result (7 transactions):**

```
Successful Comparisons = 7  |  Unsuccessful = 0  |  UVM_ERROR = 0  |  UVM_FATAL = 0
```

---

## ✨ Key Features

### RTL Design

| Feature | Details |
|---|---|
| **Default Baud Rate** | 115,200 bps (parameterizable) |
| **Clock Frequency** | 25 MHz (parameterizable) |
| **Oversampling** | 16× — samples each bit at center for maximum noise margin |
| **Data Width** | 8 bits |
| **Stop Bits** | 1 (16 baud ticks) |
| **TX FIFO** | 8-deep × 8-bit with `full` / `empty` / `not_empty` flags |
| **RX FIFO** | 8-deep × 8-bit with `full` / `empty` / `not_empty` flags |
| **Reset** | Active-low asynchronous reset |
| **Loopback** | TX → RX loopback available in testbench top |

### Verification

| Feature | Details |
|---|---|
| **Methodology** | UVM 1.1d |
| **Agents** | Dual agents: TX (active) + RX (active) |
| **Stimulus** | Constrained-random via `uvm_sequence` |
| **Checking** | Self-checking scoreboard — TX vs RX byte comparison |
| **Coverage** | Code + functional coverage via QuestaSim `vcover` |
| **Report** | HTML coverage report via `covhtmlreport/` |
| **Simulators** | Mentor QuestaSim, Synopsys VCS + Verdi |

---

## 📁 Project Structure

```
UART_Core/
├── rtl/                        # RTL Design Files
│   ├── uart_top.v              # Top-level module — DUT entry point
│   ├── baudGenerator.v         # Parameterized modulo-M baud rate generator
│   ├── uart_txmt.v             # Transmitter subsystem (TX FIFO + TX FSM)
│   ├── uart_tx.v               # UART TX 4-state shift-register FSM
│   ├── uart_rcvr.v             # Receiver subsystem (RX FSM + RX FIFO)
│   ├── uart_rx.v               # UART RX 4-state shift-register FSM
│   ├── fifo_buf.v              # Parameterized synchronous FIFO buffer
│   ├── txmt_if.sv              # SystemVerilog clocking-block interface (TX)
│   └── rcvr_if.sv              # SystemVerilog clocking-block interface (RX)
│
├── tx_agent_top/               # UVM TX Agent
│   ├── tx_xtn.sv               # TX transaction (sequence item)
│   ├── tx_config.sv            # TX agent configuration object
│   ├── tx_sequencer.sv         # TX sequencer
│   ├── tx_sequence.sv          # tx_base_seqs + tx_write_sequence
│   ├── tx_driver.sv            # TX driver — applies stimulus to DUT via clocking block
│   └── tx_monitor.sv           # TX monitor — observes TX interface, writes to analysis port
│
├── rx_agent_top/               # UVM RX Agent
│   ├── rx_xtn.sv               # RX transaction (sequence item)
│   ├── rx_config.sv            # RX agent configuration object
│   ├── rx_sequencer.sv         # RX sequencer
│   ├── rx_sequence.sv          # rx_base_seqs + rx_read_sequence
│   ├── rx_driver.sv            # RX driver — pulses rd_uart when data is available
│   └── rx_monitor.sv           # RX monitor — captures received data, writes to analysis port
│
├── tb/                         # UVM Environment & Top
│   ├── top.sv                  # Simulation top — DUT + interfaces + clock gen
│   ├── uart_tb.sv              # UVM environment (uart_tb extends uvm_env)
│   ├── uart_sb.sv              # Scoreboard — compares TX w_data vs RX r_data
│   └── env_config.sv           # Environment configuration object
│
├── test/                       # UVM Tests
│   ├── uart_test_pkg.sv        # SystemVerilog package — includes all UVM files
│   └── uart_test_lib.sv        # uart_base_test + tx_write_rx_read_test
│
└── sim/                        # Simulation Workspace
    ├── Makefile                # All build, run, regression, and coverage targets
    ├── test1.log               # QuestaSim simulation output log
    ├── wave_file1.wlf          # Waveform dump (QuestaSim format)
    ├── mem_cov1                # Coverage database (test 1)
    └── covhtmlreport/          # HTML coverage report directory
```

---

## 🔧 RTL Architecture

### Module Hierarchy

```
uart_top  (uart_top.v)
├── baudGenerator            Parameterized modulo-M counter; produces s_tick
│                            at 16× the configured baud rate
│
├── uart_rcvr                RX subsystem wrapper
│   ├── uart_rx              4-state FSM: IDLE → START → DATA → STOP
│   │                        16× oversampled; asserts rx_done_tick on byte complete
│   └── fifo_buf [RX FIFO]   8×8 synchronous FIFO; written by rx_done_tick
│
└── uart_txmt                TX subsystem wrapper
    ├── fifo_buf [TX FIFO]   8×8 synchronous FIFO; written by CPU (wr_uart)
    └── uart_tx              4-state FSM: IDLE → START → DATA → STOP
                             Reads from TX FIFO via tx_done_tick feedback
```

---

### Baud Rate Generator

`baudGenerator.v` implements a **modulo-M counter** that divides the system clock to produce a `max_tick` pulse at 16× the desired baud rate. This oversampling allows the RX FSM to sample each bit at its temporal center, providing robustness against timing skew.

```
DVSR  =  CLK_FREQ  /  (16 × BAUD_RATE)
      =  25,000,000  /  (16 × 115,200)
      ≈  13  (counter counts 0 → 13, then resets)
```

| Parameter | Default | Description |
|---|---|---|
| `CLK_FREQ` | 25,000,000 | System clock frequency in Hz |
| `BAUD_RATE` | 19,200 | Target baud rate (overridden to 115,200 by `uart_top`) |
| `WIDTH` | 8 | Counter register width |

---

### UART Transmitter FSM

`uart_tx.v` implements a 4-state Moore FSM that serializes an 8-bit parallel byte onto the TX line, **LSB first**.

```
              tx_start = 1
  ┌──────┐  ──────────────►  ┌───────┐
  │ IDLE │                   │ START │  TX = 0  (start bit, 16 ticks)
  └──────┘  ◄──────────────  └───────┘
      ▲      tx_done_tick=1       │  s_reg == 15
      │                           ▼
  ┌──────┐  ◄──────────────  ┌──────┐
  │ STOP │   n_reg==(DBIT-1) │ DATA │  TX = b_reg[0], shifts right each 16 ticks
  └──────┘                   └──────┘
  TX = 1 (stop bit, 16 ticks)
  asserts tx_done_tick
```

- **IDLE**: TX held high. Starts when `tx_start` (FIFO `not_empty`) is asserted.
- **START**: Drives TX = 0 for 16 baud ticks. Latches `din` into shift register at tick 15.
- **DATA**: Outputs `b_reg[0]`, shifts right every 16 ticks. Repeats for all 8 data bits.
- **STOP**: Drives TX = 1 for 16 ticks. Asserts `tx_done_tick` → triggers FIFO read-advance.

---

### UART Receiver FSM

`uart_rx.v` implements the complementary 4-state FSM that samples and deserializes the RX serial line.

```
  ┌──────┐  rx == 0  ┌───────┐
  │ IDLE │ ─────────► │ START │  waits 8 ticks to confirm start bit
  └──────┘            └───────┘  (samples at bit center, not edge)
      ▲                   │  s_reg == 7
      │                   ▼
  ┌──────┐           ┌──────┐
  │ STOP │ ◄──────── │ DATA │  samples at s_reg==15 (center of each bit)
  └──────┘           └──────┘  shifts rx into b_reg MSB, 8 times
  asserts rx_done_tick
  → FIFO write
```

The 8-tick delay before entering DATA ensures the FSM samples all subsequent data bits at their center points, maximizing noise margin.

---

### FIFO Buffer

`fifo_buf.v` is a parameterized synchronous FIFO used by both TX and RX subsystems for buffering.

| Parameter | Default | Description |
|---|---|---|
| `WIDTH` | 8 | Data path width in bits |
| `DEPTH` | 8 | Number of FIFO entries |

Full/empty detection uses the **extra MSB pointer technique** — no subtraction needed:

```verilog
assign full  = (wr_ptr[MSB] != rd_ptr[MSB]) &&
               (wr_ptr[MSB-1:0] == rd_ptr[MSB-1:0]);
assign empty = (wr_ptr == rd_ptr);
```

The `not_empty` signal is wired directly to `tx_start` in the TX path, ensuring the TX FSM begins serializing as soon as data is available in the TX FIFO.

---

## 🧪 UVM Testbench Architecture

### Testbench Hierarchy

```
uvm_test_top  (tx_write_rx_read_test)
└── envh  (uart_tb  extends uvm_env)
    │
    ├── tx_agth  (tx_agent  extends uvm_agent)  [UVM_ACTIVE]
    │   ├── seqrh  (tx_sequencer)
    │   ├── drvh   (tx_driver)    ──→  txmt_if.DRV  ──→  DUT TX pins
    │   └── monh   (tx_monitor)   ←──  txmt_if.MON  ←──  DUT TX pins
    │                │
    │                │ uvm_analysis_port #(tx_xtn)
    │                ▼
    ├── rx_agth  (rx_agent  extends uvm_agent)  [UVM_ACTIVE]
    │   ├── seqrh  (rx_sequencer)
    │   ├── drvh   (rx_driver)    ──→  rcvr_if.DRV  ──→  DUT RX pins
    │   └── monh   (rx_monitor)   ←──  rcvr_if.MON  ←──  DUT RX pins
    │                │
    │                │ uvm_analysis_port #(rx_xtn)
    │                ▼
    └── sb_h  (uart_sb  extends uvm_scoreboard)
        ├── tx_fifo  uvm_tlm_analysis_fifo #(tx_xtn)
        └── rx_fifo  uvm_tlm_analysis_fifo #(rx_xtn)
```

The simulation top (`top.sv`) instantiates the DUT with `tx` wired back to `rx` — a **loopback connection** that lets the TX and RX paths be verified end-to-end in a single test run without external hardware.

---

### TX Agent

**`tx_xtn`** — Transaction class with randomizable fields `wr_uart` and `w_data [7:0]`. A static `trans_id` counter increments on every `post_randomize()` call to track total transaction count.

**`tx_driver`** — On startup, asserts then deasserts reset. In `send_to_dut()`, waits for `tx_fifo_full == 0` before writing — correctly respecting FIFO back-pressure.

**`tx_monitor`** — Waits for `wr_uart == 1` on the clocking block, samples `w_data`, creates a `tx_xtn`, and writes it to `monitor_port` for the scoreboard.

**`tx_write_sequence`** — Repeats `no_of_trans` iterations, randomizing each transaction with constraint `{wr_uart == 1'b1}`.

---

### RX Agent

**`rx_xtn`** — Transaction class capturing `rd_uart`, `r_data [7:0]`, `rx_fifo_full`, `rx_fifo_empty`.

**`rx_driver`** — Waits for `rx_fifo_empty == 0` (data available in hardware FIFO), then pulses `rd_uart` for one clock cycle to dequeue the received byte.

**`rx_monitor`** — Waits for `rd_uart == 1`, captures `r_data` from the clocking block, and writes an `rx_xtn` to `monitor_port`.

**`rx_read_sequence`** — Generates `no_of_trans` read transactions with constraint `{rd_uart == 1'b1}`.

---

### Scoreboard

`uart_sb` uses two **`uvm_tlm_analysis_fifo`** instances — one connected to the TX monitor's analysis port, one to the RX monitor's. In `run_phase`, it `fork-join`s to collect one packet from each simultaneously, then calls `compare()`:

```systemverilog
task uart_sb::compare(tx_xtn t_xtn, rx_xtn r_xtn);
    if (t_xtn.w_data == r_xtn.r_data)
        pass_count++;        // DATA COMPARISON SUCCESSFUL
    else
        fail_count++;        // DATA COMPARISON FAILED
endtask
```

The `report_phase` prints the final pass/fail tally.

---

## 📡 UART Frame Format

```
Idle line (held high)
│
▼
────┐                                              ┌────────
    │  Start  D0   D1   D2   D3   D4   D5   D6   D7  │ Stop
    │   bit   LSB                              MSB │  bit
    │                                              │
    └──────────────────────────────────────────────┘

    ◄── 1 ──►◄───────────── 8 data bits ──────────►◄─ 1 ─►
       start bit        (LSB transmitted first)       stop bit

    Total frame = 10 bit periods
```

At **115,200 baud** with a 25 MHz system clock and 16× oversampling:

| Parameter | Value |
|---|---|
| DVSR (counter top) | ≈ 13 |
| Baud tick period | 16 × (1/25 MHz) = 640 ns |
| 1 bit period | 16 × 640 ns = 10.24 µs |
| Full frame (10 bits) | ≈ 102.4 µs |
| Simulation: 7 transactions | ≈ 311 µs total |

---

## 🔌 Interface Signals

### `uart_top` Port List

| Port | Dir | Width | Description |
|---|---|---|---|
| `clk` | in | 1 | System clock |
| `reset` | in | 1 | Active-low async reset |
| `wr_uart` | in | 1 | Write strobe — push `w_data` into TX FIFO |
| `rd_uart` | in | 1 | Read strobe — pop received byte from RX FIFO |
| `w_data` | in | 8 | Parallel data to transmit |
| `rx` | in | 1 | Serial receive line |
| `tx` | out | 1 | Serial transmit line |
| `r_data` | out | 8 | Received parallel data (from RX FIFO) |
| `tx_fifo_full` | out | 1 | TX FIFO full — do not write when asserted |
| `rx_fifo_empty` | out | 1 | RX FIFO empty — no data available to read |
| `rx_fifo_full` | out | 1 | RX FIFO full — receiver may drop data if not drained |

### SystemVerilog Interfaces

**`txmt_if`** (TX side) — Two clocking blocks:
- `drv_cb`: drives `reset`, `wr_uart`, `w_data`; samples `tx_fifo_full`
- `mon_cb`: samples `reset`, `wr_uart`, `w_data`, `tx`, `tx_fifo_full`

**`rcvr_if`** (RX side) — Two clocking blocks:
- `drv_cb`: drives `rd_uart`, `rx`; samples `rx_fifo_full`, `rx_fifo_empty`
- `mon_cb`: samples `rd_uart`, `rx`, `r_data`, `rx_fifo_full`, `rx_fifo_empty`

---

## 📊 Simulation Results

Simulation run on **Mentor QuestaSim** with `tx_write_rx_read_test`, 7 constrained-random transactions, loopback configuration.

### Transaction Log

| # | TX `w_data` Sent | RX `r_data` Received | Scoreboard |
|---|---|---|---|
| 1 | `0x24` | `0x24` | ✅ PASS |
| 2 | `0x5A` | `0x5A` | ✅ PASS |
| 3 | `0xA8` | `0xA8` | ✅ PASS |
| 4 | `0x75` | `0x75` | ✅ PASS |
| 5 | `0x08` | `0x08` | ✅ PASS |
| 6 | *(random)* | *(random)* | ✅ PASS |
| 7 | *(random)* | *(random)* | ✅ PASS |

### UVM Final Report

```
─────────────────────────────────────────────────
  UVM Report counts by severity
─────────────────────────────────────────────────
  UVM_INFO    :  22
  UVM_WARNING :   0
  UVM_ERROR   :   0
  UVM_FATAL   :   0
─────────────────────────────────────────────────
  Scoreboard Summary
─────────────────────────────────────────────────
  Number of Successful Comparisons   =  7
  Number of Unsuccessful Comparisons =  0
  Total Transactions                 =  7
─────────────────────────────────────────────────
  Simulation end time : 311,470 ns
  Errors: 0  |  Warnings: 2
─────────────────────────────────────────────────
```

---

## 🚀 Getting Started

### Prerequisites

- **Mentor QuestaSim** (primary) or **Synopsys VCS + Verdi**
- UVM 1.1d (bundled with QuestaSim)
- GNU `make`

### Clone

```bash
git clone https://github.com/md-overflow/UART_Core.git
cd UART_Core/sim
```

### Step 1 — Compile

```bash
make sv_cmp
```

Creates the `work` library and compiles:
- All RTL files from `../rtl/`
- All UVM files via `../test/uart_test_pkg.sv`
- Simulation top `../tb/top.sv`

### Step 2 — Run the Test

```bash
make run_test
```

Runs `tx_write_rx_read_test` in batch mode. On completion:
- Simulation log → `test1.log`
- Waveform → `wave_file1.wlf`
- Coverage database → `mem_cov1`
- Coverage HTML report → `covhtmlreport/`

### Step 3 — View Waveform

```bash
make view_wave1
```

### Step 4 — View Coverage Report

```bash
make cov
# Opens covhtmlreport/index.html in Firefox
```

### Run Full Regression

```bash
make regress
```

Cleans, compiles, runs all 3 tests, merges coverage databases, and opens the HTML report.

---

## 🛠 Makefile Targets

| Target | Description |
|---|---|
| `make help` | Show all targets with usage descriptions |
| `make sv_cmp` | Create library and compile all source files |
| `make run_test` | Compile + run `tx_write_rx_read_test` (batch) |
| `make run_test1` | Run `incr_write_read_test` |
| `make run_test2` | Run `wrap_write_read_test` |
| `make view_wave1` | Open waveform for test 1 in QuestaSim |
| `make view_wave2` | Open waveform for test 2 |
| `make view_wave3` | Open waveform for test 3 |
| `make regress` | Clean → compile → run all 3 tests → merge coverage |
| `make report` | Merge coverage databases → generate HTML |
| `make cov` | Open merged HTML coverage report in Firefox |
| `make clean` | Remove all generated files (logs, waveforms, coverage) |

> All targets have VCS equivalents — see the `_VCS` suffix targets in the Makefile, or set `SIMULATOR=VCS`.

---

## 🔩 Tools & Requirements

| Tool | Purpose |
|---|---|
| Mentor QuestaSim | Primary simulator, coverage, waveform viewer |
| Synopsys VCS | Alternative simulator |
| Synopsys Verdi (T-2022.06-SP1) | FSDB waveform viewer for VCS flow |
| UVM 1.1d | Verification methodology library |
| GNU Make | Build and regression automation |
| Firefox | HTML coverage report viewer |

---

## 👤 Author

**Md Mudassir Ahmed**

---

*Built with Verilog/SystemVerilog · Verified with UVM 1.1d · Simulated on QuestaSim*
