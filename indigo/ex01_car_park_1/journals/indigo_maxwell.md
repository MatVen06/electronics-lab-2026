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
### Entry - 2026-11-18
**Commit reference:** `fc4b0d4 [DOCS]: Update journal entries.`

**What I implemented or decided:**
Besides the journal update, this commit also changed the RTL:
- RIGHT_PASSWORD: goes to STOP when both `front_sensor` and `back_sensor` are high (a second car arrives while the first is passing); goes back to IDLE when `back_sensor` is low and `counter_tick >= 10`.
- STOP: goes back to IDLE once `back_sensor` goes low.
- In `DATA_PATH`, `counter_tick` is now incremented unconditionally instead of only while the password is stable in WAIT_PASSWORD.
- `OUTPUTS` is now sensitive to `tick` as well as `current_state`, so the blinking LEDs actually update, and the "display off" default uses the `HEX_OFF` constant.

**Why I structured it this way:**
I wanted all five states implemented so the first scenario in `indigo_laplace`'s testbench could run end to end. `OUTPUTS` reads `tick` for blinking, so leaving it out of the sensitivity list was a bug.

**What I am not sure about:**

**What the simulation or hardware told me I was wrong about:**

---
### Entry - 2026-11-18
**Commit reference:** `4bd990e [FIX]: fix tick counter`

**What I implemented or decided:**
I removed `counter_tick` completely. WAIT_PASSWORD (10 cycles) and RIGHT_PASSWORD (10 cycles) now use the same `tick` counter as WRONG_PASSWORD, which already restarts on every state change in `DATA_PATH`.

**Why I structured it this way:**
After `fc4b0d4` the two counters did the same job, and `counter_tick` was driven from both `DATA_PATH` and `FSM`. One counter that is only written in the clocked process is simpler and avoids multiple drivers. This also answers the question from my `8edf9f0` entry about where `counter_tick` should be reset: it no longer needs to be.

**What I am not sure about:**
`stable` is still assigned inside the combinational `FSM` process and not in every branch.

**What the simulation or hardware told me I was wrong about:**

---
### Entry - 2026-11-18
**Commit reference:** `19336b3 [FIX]: fix stable check in wait password`

**What I implemented or decided:**
Two fixes in WAIT_PASSWORD:
- The password was built with `password_1 and password_2`, which is a bitwise AND of two 2-bit vectors (a 2-bit result) and can never equal the 4-bit `TRUE_PASSWORD`. I changed it to concatenation, `password_1 & password_2`.
- The decision is now taken as soon as `tick >= 10`: if the password was stable and correct we go to RIGHT_PASSWORD, otherwise to WRONG_PASSWORD. Before, an unstable password made the FSM wait in WAIT_PASSWORD forever.

**Why I structured it this way:**
The `and` was a typo for `&`. Moving `stable` inside the check guarantees the FSM always leaves WAIT_PASSWORD after 10 cycles.

**What I am not sure about:**
The stability check uses `password_1'event` / `password_2'event` inside a combinational process. I am not sure if that will work on the testbench, though I will have to wait for the testbench to be done.

**What the simulation or hardware told me I was wrong about:**

---
### Entry - 2026-11-18
**Commit reference:** `191cf1e [IMPL]: finish first implemetation and delete duplicate tb`

**What I implemented or decided:**
- I replaced `tick < tick'high` with `tick < 255` in `DATA_PATH`.
- I deleted my skeleton testbench `src/tb_car_parking_system.vhd` (from `dca582a`). `tb/tb_car_parking_system.vhd` by `indigo_laplace` is now the only testbench.
- This is the first complete implementation: all five states and their outputs.

To run the simulation I use a local `script.sh` (not committed) that compiles `src/car_parking_system.vhd` and `tb/tb_car_parking_system.vhd` with GHDL (`--std=08`), runs `tb_car_parking_system` for 10 us, and writes the waveform to `out.vcd`.

**Why I structured it this way:**
GHDL rejects `tick'high` ("object prefix must be an array"): on a scalar, `'high` has to be applied to a type or subtype, not to a signal.

**What I am not sure about:**

**What the simulation or hardware told me I was wrong about:**

---

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
