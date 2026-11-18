# Journal � Exercise 1 � Car Park 1

> **You:** `indigo_maxwell` � **Group:** `indigo` � **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry - 2026-11-11
**Commit reference:** `dca582a [TEST]: add skeleton of testbench`

**What I implemented or decided:**
I added the first testbench skeleton (`src/tb_car_parking_system.vhd`): DUT instantiation and the signals for the ports. It has no stimulus or checks yet.

**Why I structured it this way:**
We wanted a testbench that compiles before writing any behaviour, so the RTL could be simulated as soon as it existed.

**What I am not sure about:**
Where the testbench belongs. Mine is in `src/`, but `indigo_laplace` later developed the real one in `tb/` (`cd278e6`, `b5130ce`), so we now have two copies.

**What the simulation or hardware told me I was wrong about:**

---
### Entry - 2026-11-11
**Commit reference:** `816f55b [IMPL]: add entity`

**What I implemented or decided:**
I declared the `Car_Parking_System_VHDL` entity exactly as given in the specification: `clk`, asynchronous active-low `reset_n`, `front_sensor`/`back_sensor`, two 2-bit password inputs, `GREEN_LED`/`RED_LED` and two 7-segment outputs (`gfedcba`).

**Why I structured it this way:**
The interface is fixed by the specification and by the shared testbench, so there was nothing to choose.

**What I am not sure about:**

**What the simulation or hardware told me I was wrong about:**

---
### Entry - 2026-11-11
**Commit reference:** `2ee448c [IMPL]: add state register and initial FSM implementation`

**What I implemented or decided:**
I defined the enumerated `state_type` (IDLE, WAIT_PASSWORD, WRONG_PASSWORD, RIGHT_PASSWORD, STOP) and split the design into a `reg` process (state register with asynchronous reset) and an `FSM` process for next-state logic. Only IDLE -> WAIT_PASSWORD on `front_sensor` was filled in.

**Why I structured it this way:**
It keeps the sequential and combinational parts clearly separated so that counters can live in the register synchronous domain while the combinational logic decides the next state.

**What I am not sure about:**
The `FSM` process was sensitive to `clk` only, not to `current_state` and the inputs, so it was not really combinational.

**What the simulation or hardware told me I was wrong about:**


---
### Entry - 2026-11-11
**Commit reference:** `7adfd18 [IMPL]: continue implementation of WAIT_PASSWORD state`

**What I implemented or decided:**
With `indigo_turing`, I started working on WAIT_PASSWORD. I added the `TRUE_PASSWORD = "1010"` constant, a `tick` counter with `increment_tick`/`reset_tick` procedures and an `is_stable` flag. I also merged the register and the next-state logic into one clocked process, wrapped inside a `RESET_LOGIC` process.

**Why I structured it this way:**
WAIT_PASSWORD needs time: the password must stay stable for some cycles before it is checked, so I needed a counter and a stability flag.

**What I am not sure about:**
Whether one clocked process is better than the two-process version from `2ee448c`.

**What the simulation or hardware told me I was wrong about:**

---
### Entry - 2026-11-18
**Commit reference:** `8edf9f0 [IMPL]: continue implementation of FSM`

**What I implemented or decided:**
I restructured the architecture into three processes:
- `DATA_PATH` (clocked, asynchronous reset): the state register, a `tick` counter that restarts on every state change, and a `counter_tick` that counts stable-password cycles while in WAIT_PASSWORD.
- `FSM` (combinational next-state logic): implemented IDLE, WAIT_PASSWORD (password checked once it has been stable for 10 cycles; leaving the front sensor goes back to IDLE) and WRONG_PASSWORD (back to WAIT_PASSWORD after 20 ticks). RIGHT_PASSWORD and STOP are still TODO.
- `OUTPUTS` (Moore outputs): the LEDs, blinking based on `tick mod 2`, and the 7-segment codes `En`, `EE`, `GO`, `SP`. These codes match the decoder in `indigo_laplace`'s testbench.

**Why I structured it this way:**
I went back to separating the clocked logic from the combinational logic after the `7adfd18` attempt failed. Moore outputs depend only on the state (plus `tick` for blinking), which matches how the testbench detects the state from `HEX_1 & HEX_2`. The display codes are named constants so they are not repeated as magic vectors.

**What I am not sure about:**
There are still a lot of caveats in the logic, expecially the synced counters and the stability check. I am not sure if the `counter_tick` is incremented correctly, or if it should be reset in other states than WAIT_PASSWORD.

**What the simulation or hardware told me I was wrong about:**
---

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
