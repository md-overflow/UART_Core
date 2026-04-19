<div align="center">

# UART Core — RTL Design \& UVM Verification

**A complete, production-quality UART IP Core**
*Designed in Verilog/SystemVerilog · Verified with a full UVM testbench · Simulated on QuestaSim \& VCS*

\---

\---

## 📑 Table of Contents

* [Overview](#-overview)
* [Key Features](#-key-features)
* [Project Structure](#-project-structure)
* [RTL Architecture](#-rtl-architecture)

  * [Module Hierarchy](#module-hierarchy)
  * [Baud Rate Generator](#baud-rate-generator)
  * [UART Transmitter FSM](#uart-transmitter-fsm)
  * [UART Receiver FSM](#uart-receiver-fsm)
  * [FIFO Buffer](#fifo-buffer)
* [UVM Testbench Architecture](#-uvm-testbench-architecture)

  * [Testbench Hierarchy](#testbench-hierarchy)
  * [TX Agent](#tx-agent)
  * [RX Agent](#rx-agent)
  * [Scoreboard](#scoreboard)
* [UART Frame Format](#-uart-frame-format)
* [Interface Signals](#-interface-signals)
* [Simulation Results](#-simulation-results)
* [Getting Started](#-getting-started)
* [Makefile Targets](#-makefile-targets)
* [Tools \& Requirements](#-tools--requirements)
* [Author](#-author)

\---

## 🔭 Overview

This project implements a full **UART (Universal Asynchronous Receiver/Transmitter)** IP Core from scratch, covering both RTL design and functional verification. The design follows a classic FIFO-buffered architecture with a 16× oversampling baud rate generator, operating at configurable baud rates and clock frequencies.

The verification environment is built entirely in **UVM 1.1d** following industry best practices — dual agents (TX and RX), a self-checking scoreboard, constrained-random stimulus, and HTML coverage reports generated from QuestaSim.

> UART converts parallel data from a CPU bus into a serial bitstream for transmission, and reconstructs a serial bitstream back to parallel bytes on reception — all without a shared clock between communicating devices.

**Simulation result (7 transactions):**

```
Successful Comparisons = 7  |  Unsuccessful = 0  |  UVM\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_ERROR = 0  |  UVM\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_FATAL = 0
```

\---

## ✨ Key Features

### RTL Design

|Feature|Details|
|-|-|
|**Default Baud Rate**|115,200 bps (parameterizable)|
|**Clock Frequency**|25 MHz (parameterizable)|
|**Oversampling**|16× — samples each bit at center for maximum noise margin|
|**Data Width**|8 bits|
|**Stop Bits**|1 (16 baud ticks)|
|**TX FIFO**|8-deep × 8-bit with `full` / `empty` / `not\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_empty` flags|
|**RX FIFO**|8-deep × 8-bit with `full` / `empty` / `not\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_empty` flags|
|**Reset**|Active-low asynchronous reset|
|**Loopback**|TX → RX loopback available in testbench top|

### Verification

|Feature|Details|
|-|-|
|**Methodology**|UVM 1.1d|
|**Agents**|Dual agents: TX (active) + RX (active)|
|**Stimulus**|Constrained-random via `uvm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sequence`|
|**Checking**|Self-checking scoreboard — TX vs RX byte comparison|
|**Coverage**|Code + functional coverage via QuestaSim `vcover`|
|**Report**|HTML coverage report via `covhtmlreport/`|
|**Simulators**|Mentor QuestaSim, Synopsys VCS + Verdi|

\---

## 📁 Project Structure

```
UART/
├── rtl/                        # RTL Design Files
│   ├── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_top.v              # Top-level module — DUT entry point
│   ├── baudGenerator.v         # Parameterized modulo-M baud rate generator
│   ├── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_txmt.v             # Transmitter subsystem (TX FIFO + TX FSM)
│   ├── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tx.v               # UART TX 4-state shift-register FSM
│   ├── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_rcvr.v             # Receiver subsystem (RX FSM + RX FIFO)
│   ├── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_rx.v               # UART RX 4-state shift-register FSM
│   ├── fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_buf.v              # Parameterized synchronous FIFO buffer
│   ├── txmt\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_if.sv              # SystemVerilog clocking-block interface (TX)
│   └── rcvr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_if.sv              # SystemVerilog clocking-block interface (RX)
│
├── tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_agent\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_top/               # UVM TX Agent
│   ├── tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn.sv               # TX transaction (sequence item)
│   ├── tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_config.sv            # TX agent configuration object
│   ├── tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sequencer.sv         # TX sequencer
│   ├── tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sequence.sv          # tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_base\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_seqs + tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_write\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sequence
│   ├── tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_driver.sv            # TX driver — applies stimulus to DUT via clocking block
│   └── tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_monitor.sv           # TX monitor — observes TX interface, writes to analysis port
│
├── rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_agent\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_top/               # UVM RX Agent
│   ├── rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn.sv               # RX transaction (sequence item)
│   ├── rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_config.sv            # RX agent configuration object
│   ├── rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sequencer.sv         # RX sequencer
│   ├── rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sequence.sv          # rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_base\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_seqs + rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_read\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sequence
│   ├── rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_driver.sv            # RX driver — pulses rd\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart when data is available
│   └── rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_monitor.sv           # RX monitor — captures received data, writes to analysis port
│
├── tb/                         # UVM Environment \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\& Top
│   ├── top.sv                  # Simulation top — DUT + interfaces + clock gen
│   ├── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tb.sv              # UVM environment (uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tb extends uvm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_env)
│   ├── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sb.sv              # Scoreboard — compares TX w\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data vs RX r\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data
│   └── env\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_config.sv           # Environment configuration object
│
├── test/                       # UVM Tests
│   ├── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_pkg.sv        # SystemVerilog package — includes all UVM files
│   └── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_lib.sv        # uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_base\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test + tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_write\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_read\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test
│
└── sim/                        # Simulation Workspace
    ├── Makefile                # All build, run, regression, and coverage targets
    ├── test1.log               # QuestaSim simulation output log
    ├── wave\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_file1.wlf          # Waveform dump (QuestaSim format)
    ├── mem\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_cov1                # Coverage database (test 1)
    └── covhtmlreport/          # HTML coverage report directory
```

\---

## 🔧 RTL Architecture

### Module Hierarchy

```
uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_top  (uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_top.v)
├── baudGenerator            Parameterized modulo-M counter; produces s\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tick
│                            at 16× the configured baud rate
│
├── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_rcvr                RX subsystem wrapper
│   ├── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_rx              4-state FSM: IDLE → START → DATA → STOP
│   │                        16× oversampled; asserts rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_done\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tick on byte complete
│   └── fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_buf \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\[RX FIFO]  8×8 synchronous FIFO; written by rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_done\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tick
│
└── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_txmt                TX subsystem wrapper
    ├── fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_buf \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\[TX FIFO]  8×8 synchronous FIFO; written by CPU (wr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart)
    └── uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tx              4-state FSM: IDLE → START → DATA → STOP
                             Reads from TX FIFO via tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_done\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tick feedback
```

\---

### Baud Rate Generator

`baudGenerator.v` implements a **modulo-M counter** that divides the system clock to produce a `max\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tick` pulse at 16× the desired baud rate. This oversampling allows the RX FSM to sample each bit at its temporal center, providing robustness against timing skew.

```
DVSR  =  CLK\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_FREQ  /  (16 × BAUD\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_RATE)
      =  25,000,000  /  (16 × 115,200)
      ≈  13  (counter counts 0 → 13, then resets)
```

|Parameter|Default|Description|
|-|-|-|
|`CLK\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_FREQ`|25,000,000|System clock frequency in Hz|
|`BAUD\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_RATE`|19,200|Target baud rate (overridden to 115,200 by `uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_top`)|
|`WIDTH`|8|Counter register width|

\---

### UART Transmitter FSM

`uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tx.v` implements a 4-state Moore FSM that serializes an 8-bit parallel byte onto the TX line, **LSB first**.

```
              tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_start = 1
  ┌──────┐  ──────────────►  ┌───────┐
  │ IDLE │                   │ START │  TX = 0  (start bit, 16 ticks)
  └──────┘  ◄──────────────  └───────┘
      ▲      tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_done\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tick=1       │  s\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_reg == 15
      │                           ▼
  ┌──────┐  ◄──────────────  ┌──────┐
  │ STOP │   n\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_reg==(DBIT-1) │ DATA │  TX = b\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_reg\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\[0], shifts right each 16 ticks
  └──────┘                   └──────┘
  TX = 1 (stop bit, 16 ticks)
  asserts tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_done\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tick
```

* **IDLE**: TX held high. Starts when `tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_start` (FIFO `not\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_empty`) is asserted.
* **START**: Drives TX = 0 for 16 baud ticks. Latches `din` into shift register at tick 15.
* **DATA**: Outputs `b\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_reg\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\[0]`, shifts right every 16 ticks. Repeats for all 8 data bits.
* **STOP**: Drives TX = 1 for 16 ticks. Asserts `tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_done\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tick` → triggers FIFO read-advance.

\---

### UART Receiver FSM

`uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_rx.v` implements the complementary 4-state FSM that samples and deserializes the RX serial line.

```
  ┌──────┐  rx == 0  ┌───────┐
  │ IDLE │ ─────────► │ START │  waits 8 ticks to confirm start bit
  └──────┘            └───────┘  (samples at bit center, not edge)
      ▲                   │  s\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_reg == 7
      │                   ▼
  ┌──────┐           ┌──────┐
  │ STOP │ ◄──────── │ DATA │  samples at s\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_reg==15 (center of each bit)
  └──────┘           └──────┘  shifts rx into b\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_reg MSB, 8 times
  asserts rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_done\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tick
  → FIFO write
```

The 8-tick delay before entering DATA ensures the FSM samples all subsequent data bits at their center points, maximizing noise margin.

\---

### FIFO Buffer

`fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_buf.v` is a parameterized synchronous FIFO used by both TX and RX subsystems for buffering.

|Parameter|Default|Description|
|-|-|-|
|`WIDTH`|8|Data path width in bits|
|`DEPTH`|8|Number of FIFO entries|

Full/empty detection uses the **extra MSB pointer technique** — no subtraction needed:

```verilog
assign full  = (wr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_ptr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\[MSB] != rd\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_ptr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\[MSB]) \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\&\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\&
               (wr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_ptr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\[MSB-1:0] == rd\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_ptr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\[MSB-1:0]);
assign empty = (wr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_ptr == rd\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_ptr);
```

The `not\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_empty` signal is wired directly to `tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_start` in the TX path, ensuring the TX FSM begins serializing as soon as data is available in the TX FIFO.

\---

## 🧪 UVM Testbench Architecture

### Testbench Hierarchy

```
uvm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_top  (tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_write\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_read\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test)
└── envh  (uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tb  extends uvm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_env)
    │
    ├── tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_agth  (tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_agent  extends uvm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_agent)  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\[UVM\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_ACTIVE]
    │   ├── seqrh  (tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sequencer)
    │   ├── drvh   (tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_driver)    ──→  txmt\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_if.DRV  ──→  DUT TX pins
    │   └── monh   (tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_monitor)   ←──  txmt\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_if.MON  ←──  DUT TX pins
    │                │
    │                │ uvm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_analysis\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_port #(tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn)
    │                ▼
    ├── rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_agth  (rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_agent  extends uvm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_agent)  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\[UVM\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_ACTIVE]
    │   ├── seqrh  (rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sequencer)
    │   ├── drvh   (rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_driver)    ──→  rcvr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_if.DRV  ──→  DUT RX pins
    │   └── monh   (rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_monitor)   ←──  rcvr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_if.MON  ←──  DUT RX pins
    │                │
    │                │ uvm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_analysis\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_port #(rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn)
    │                ▼
    └── sb\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_h  (uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sb  extends uvm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_scoreboard)
        ├── tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo  uvm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tlm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_analysis\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo #(tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn)
        └── rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo  uvm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tlm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_analysis\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo #(rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn)
```

The simulation top (`top.sv`) instantiates the DUT with `tx` wired back to `rx` — a **loopback connection** that lets the TX and RX paths be verified end-to-end in a single test run without external hardware.

\---

### TX Agent

**`tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn`** — Transaction class with randomizable fields `wr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart` and `w\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\[7:0]`. A static `trans\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_id` counter increments on every `post\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_randomize()` call to track total transaction count.

**`tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_driver`** — On startup, asserts then deasserts reset. In `send\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_to\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_dut()`, waits for `tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_full == 0` before writing — correctly respecting FIFO back-pressure.

**`tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_monitor`** — Waits for `wr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart == 1` on the clocking block, samples `w\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data`, creates a `tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn`, and writes it to `monitor\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_port` for the scoreboard.

**`tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_write\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sequence`** — Repeats `no\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_of\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_trans` iterations, randomizing each transaction with constraint `{wr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart == 1'b1}`.

\---

### RX Agent

**`rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn`** — Transaction class capturing `rd\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart`, `r\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\[7:0]`, `rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_full`, `rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_empty`.

**`rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_driver`** — Waits for `rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_empty == 0` (data available in hardware FIFO), then pulses `rd\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart` for one clock cycle to dequeue the received byte.

**`rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_monitor`** — Waits for `rd\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart == 1`, captures `r\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data` from the clocking block, and writes an `rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn` to `monitor\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_port`.

**`rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_read\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sequence`** — Generates `no\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_of\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_trans` read transactions with constraint `{rd\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart == 1'b1}`.

\---

### Scoreboard

`uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sb` uses two **`uvm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_tlm\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_analysis\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo`** instances — one connected to the TX monitor's analysis port, one to the RX monitor's. In `run\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_phase`, it `fork-join`s to collect one packet from each simultaneously, then calls `compare()`:

```systemverilog
task uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_sb::compare(tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn t\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn, rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn r\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn);
    if (t\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn.w\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data == r\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_xtn.r\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data)
        pass\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_count++;        // DATA COMPARISON SUCCESSFUL
    else
        fail\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_count++;        // DATA COMPARISON FAILED
endtask
```

The `report\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_phase` prints the final pass/fail tally.

\---

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

    ◄──── 1 ────►◄──────────── 8 data bits ────────►◄─ 1 ─►
       start bit        (LSB transmitted first)       stop bit

    Total frame = 10 bit periods
```

At **115,200 baud** with a 25 MHz system clock and 16× oversampling:

|Parameter|Value|
|-|-|
|DVSR (counter top)|≈ 13|
|Baud tick period|16 × (1/25 MHz) = 640 ns|
|1 bit period|16 × 640 ns = 10.24 µs|
|Full frame (10 bits)|≈ 102.4 µs|
|Simulation: 7 transactions|≈ 311 µs total|

\---

## 🔌 Interface Signals

### `uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_top` Port List

|Port|Dir|Width|Description|
|-|-|-|-|
|`clk`|in|1|System clock|
|`reset`|in|1|Active-low async reset|
|`wr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart`|in|1|Write strobe — push `w\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data` into TX FIFO|
|`rd\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart`|in|1|Read strobe — pop received byte from RX FIFO|
|`w\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data`|in|8|Parallel data to transmit|
|`rx`|in|1|Serial receive line|
|`tx`|out|1|Serial transmit line|
|`r\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data`|out|8|Received parallel data (from RX FIFO)|
|`tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_full`|out|1|TX FIFO full — do not write when asserted|
|`rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_empty`|out|1|RX FIFO empty — no data available to read|
|`rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_full`|out|1|RX FIFO full — receiver may drop data if not drained|

### SystemVerilog Interfaces

**`txmt\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_if`** (TX side) — Two clocking blocks:

* `drv\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_cb`: drives `reset`, `wr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart`, `w\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data`; samples `tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_full`
* `mon\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_cb`: samples `reset`, `wr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart`, `w\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data`, `tx`, `tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_full`

**`rcvr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_if`** (RX side) — Two clocking blocks:

* `drv\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_cb`: drives `rd\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart`, `rx`; samples `rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_full`, `rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_empty`
* `mon\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_cb`: samples `rd\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_uart`, `rx`, `r\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data`, `rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_full`, `rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_fifo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_empty`

\---

## 📊 Simulation Results

Simulation run on **Mentor QuestaSim** with `tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_write\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_read\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test`, 7 constrained-random transactions, loopback configuration.

### Transaction Log

|#|TX `w\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data` Sent|RX `r\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_data` Received|Scoreboard|
|-|-|-|-|
|1|`0x24`|`0x24`|✅ PASS|
|2|`0x5A`|`0x5A`|✅ PASS|
|3|`0xA8`|`0xA8`|✅ PASS|
|4|`0x75`|`0x75`|✅ PASS|
|5|`0x08`|`0x08`|✅ PASS|
|6|*(random)*|*(random)*|✅ PASS|
|7|*(random)*|*(random)*|✅ PASS|

### UVM Final Report

```
─────────────────────────────────────────────────
  UVM Report counts by severity
─────────────────────────────────────────────────
  UVM\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_INFO    :  22
  UVM\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_WARNING :   0
  UVM\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_ERROR   :   0
  UVM\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_FATAL   :   0
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

\---

## 🚀 Getting Started

### Prerequisites

* **Mentor QuestaSim** (primary) or **Synopsys VCS + Verdi**
* UVM 1.1d (bundled with QuestaSim)
* GNU `make`

### Clone

```bash
git clone https://github.com/md-overflow/UART\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_Core.git
cd UART\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_Core/sim
```

### Step 1 — Compile

```bash
make sv\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_cmp
```

Creates the `work` library and compiles:

* All RTL files from `../rtl/`
* All UVM files via `../test/uart\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_pkg.sv`
* Simulation top `../tb/top.sv`

### Step 2 — Run the Test

```bash
make run\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test
```

Runs `tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_write\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_read\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test` in batch mode. On completion:

* Simulation log → `test1.log`
* Waveform → `wave\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_file1.wlf`
* Coverage database → `mem\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_cov1`
* Coverage HTML report → `covhtmlreport/`

### Step 3 — View Waveform

```bash
make view\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_wave1
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

\---

## 🛠 Makefile Targets

|Target|Description|
|-|-|
|`make help`|Show all targets with usage descriptions|
|`make sv\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_cmp`|Create library and compile all source files|
|`make run\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test`|Compile + run `tx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_write\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_rx\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_read\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test` (batch)|
|`make run\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test1`|Run `incr\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_write\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_read\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test`|
|`make run\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test2`|Run `wrap\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_write\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_read\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_test`|
|`make view\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_wave1`|Open waveform for test 1 in QuestaSim|
|`make view\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_wave2`|Open waveform for test 2|
|`make view\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_wave3`|Open waveform for test 3|
|`make regress`|Clean → compile → run all 3 tests → merge coverage|
|`make report`|Merge coverage databases → generate HTML|
|`make cov`|Open merged HTML coverage report in Firefox|
|`make clean`|Remove all generated files (logs, waveforms, coverage)|

> All targets have VCS equivalents — see the `\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_VCS` suffix targets in the Makefile, or set `SIMULATOR=VCS`.

\---

## 🔩 Tools \& Requirements

|Tool|Purpose|
|-|-|
|Mentor QuestaSim|Primary simulator, coverage, waveform viewer|
|Synopsys VCS|Alternative simulator|
|Synopsys Verdi (T-2022.06-SP1)|FSDB waveform viewer for VCS flow|
|UVM 1.1d|Verification methodology library|
|GNU Make|Build and regression automation|
|Firefox|HTML coverage report viewer|



\---

## 👤 Author

**Md Mudassir Ahmed**



\---

<div align="center">

*Built with Verilog/SystemVerilog · Verified with UVM 1.1d · Simulated on QuestaSim*

</div>

