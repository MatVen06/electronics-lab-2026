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
### Entry - 2026-11-25
**Commit reference:** `6b4c9f1 [IMPL]: add testbench`

**What I implemented or decided:**
I added `tb/tb_car_parking_system.vhd` (made by the other part of the group) to follow the four scenarios of the handout (section 5): normal entry, wrong password, multiple cars, reset.

**Why I structured it this way:**
The previous testbench was built around a vector-driving procedure and only covered Part A. Writing one block per handout scenario makes it easy to check that every scenario is covered and to explain it in the report.

**What I am not sure about:**

**What the simulation or hardware told me I was wrong about:**
The first run gave 6 assertion errors.

---
### Entry - 2026-11-25
**Commit reference:** `913efb9 [IMPL]: add state enumerator for debug`

**What I implemented or decided:**
- I added `state_code` and `next_state_code`, 3-bit mirrors of `current_state`/`next_state`, produced by an `encode()` function (IDLE = 000, WAIT_PASSWORD = 001, WRONG_PASSWORD = 010, RIGHT_PASSWORD = 011, STOP = 100).
- I changed `TRUE_PASSWORD` from `"1010"` to `"0110"`.

**Why I structured it this way:**
GHDL does not write signals of an enumerated type to the VCD file, so `current_state` was invisible in `out.vcd`. With the 3-bit codes I can read the state sequence directly in the waveform. The FSM logic does not use these signals, so synthesis removes them. The password change follows the handout (`"01"` and `"10"`).

**What I am not sure about:**

**What the simulation or hardware told me I was wrong about:**
The waveform made the password bug obvious: the state went `000 -> 001 -> 010 -> 000` and never reached `011`.

---
### Entry - 2026-11-25
**Commit reference:** `a23ecc9 [IMPL]: modify blink logic`

**What I implemented or decided:**
I added a `blink` register in `DATA_PATH` that toggles on every clock edge (reset to `'0'`). The blinking LEDs are now driven by `blink` instead of `tick mod 2`.

**Why I structured it this way:**
`tick` saturates and restarts on every state change, so it is not a good clock for blinking: once it stops counting, the LED stops blinking. A free-running toggle does not depend on how long we stay in a state. The handout says blinking happens at clock frequency, so toggling every cycle is enough for simulation.

**What I am not sure about:**

**What the simulation or hardware told me I was wrong about:**
In this commit I also wrote `GREEN_LED <= blink` in STOP, where the handout says the red LED blinks. The testbench did not catch it because it does not check the LEDs. Fixed in `927e916`.

---
### Entry - 2026-11-25
**Commit reference:** `0aa7632 [FIX]: fix bug for idle transition`

**What I implemented or decided:**
- RIGHT_PASSWORD now goes to IDLE when `back_sensor = '1'`, instead of `back_sensor = '0'` and `tick >= 10`.
- The WRONG_PASSWORD wait went from 20 to 10 ticks.

**Why I structured it this way:**
The handout's Scenario 1 asserts `back_sensor = '1'` and expects IDLE: the car reaching the back sensor means it has passed the gate. With my old condition, the car stayed in RIGHT_PASSWORD while it was on the back sensor, and the FSM only left after a timeout. I only changed this one transition, to see its effect alone in the simulation (5 errors down to 3).

**What I am not sure about:**

**What the simulation or hardware told me I was wrong about:**
Scenario 1 passes now, and the Scenario 2 "EE" check also passes: it was failing only because Scenario 1 left the FSM in the wrong state.

---
### Entry - 2026-11-25
**Commit reference:** `efe6964 [FIX]: modify stable password logic to clocked version`

**What I implemented or decided:**
- In `DATA_PATH` I added `password_prev` (last cycle's password) and `pw_stable_cnt`, which counts how many cycles the password has not changed and restarts at 0 when it changes.
- WRONG_PASSWORD now goes to RIGHT_PASSWORD when the password is correct and has been stable for `STABLE_CYCLES = 10` cycles. It no longer goes back to WAIT_PASSWORD after a timeout.

**Why I structured it this way:**
The handout says that in WRONG_PASSWORD, entering the correct password leads to RIGHT_PASSWORD. I wanted the same rule as in WAIT_PASSWORD: the password must be stable for 10 cycles before it is accepted. A previous-value register and a counter make that clocked and synthesizable, unlike `'event`.

**What I am not sure about:**

**What the simulation or hardware told me I was wrong about:**

---
### Entry - 2026-11-25
**Commit reference:** `6ebab2c [FIX]: make testbench wait for 10 cycles`

**What I implemented or decided:**
In Scenario 2, after entering the correct password, the testbench now waits 12 clock periods instead of 2 before checking for RIGHT_PASSWORD.

**Why I structured it this way:**
With the 10-cycle stability rule from `efe6964`, 2 cycles are too short, and the check failed even though the design was behaving as intended. 12 cycles gives 1-2 cycles of margin, as in the other scenarios.

**What I am not sure about:**

**What the simulation or hardware told me I was wrong about:**

---
### Entry - 2026-11-25
**Commit reference:** `927e916 [FIX]: replace password checks with clocked logic ∙ fix small led blink bug in stop`

**What I implemented or decided:**
- I removed `stable` and the `password_1'event`/`password_2'event` check completely. A combinational signal `password_ok` (correct password, same as last cycle, `pw_stable_cnt >= 10`) is now used by WAIT_PASSWORD, WRONG_PASSWORD and STOP.
- STOP waits for car 1 to clear the back sensor. Then, if `password_ok`, it goes to RIGHT_PASSWORD; if car 2 has gone away too (both sensors `'0'`), it goes back to IDLE.
- The red LED (not the green one) blinks in STOP.
- Clean-up:
  - `tick` reduced to `0 to 15`.
  - `tick` removed from the `OUTPUTS` sensitivity list.
  - The comment about the debug codes corrected.

**Why I structured it this way:**

**What I am not sure about:**

**What the simulation or hardware told me I was wrong about:**
After this commit the testbench runs with 0 assertion errors, the waveform goes through all five states, and `ghdl --synth` accepts the design.


---

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
