# Journal — Exercise 1 — Car Park 1

> **You:** `plum_kirchhoff` · **Group:** `plum` · **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry — 2026-11-11
**Commit reference:** `<!-- paste: git log --oneline -1 -->`

**What I implemented or decided:**
I designed a car parking controller using a Finite State Machine with five states: IDLE, WAIT_PASS, WRONG_PASS, RIGHT_PASS, and STOP. I implemented the FSM in VHDL, separating the entity and port declarations, state registers, next-state logic, counter, blinking logic, and output logic for the LEDs and seven-segment displays. I also developed a testbench to verify vehicle detection, password verification, and vehicle movement through the entrance.

**Why I structured it this way:**
I chose an FSM because the parking controller has clearly defined operating states and transitions depending on the front and back sensors, password inputs, and counter. I first designed the state diagram on paper and then refined it with my groupmate before implementing it in VHDL. I used separate processes for the state register, next-state logic, counter, and output behaviour to make the design easier to understand and debug.

**What I am not sure about:**
I was not completely confident about how the front and back sensors should interact in every possible situation, particularly when a second vehicle approaches while the first vehicle is still passing. I also needed to understand more clearly how the counter and clock cycles affected the transitions between WAIT_PASS, WRONG_PASS, and RIGHT_PASS.

**What the simulation or hardware told me I was wrong about:**
During simulation, I initially suspected that some unexpected behaviour was caused by errors in the FSM itself. However, I discovered that part of the problem was related to the simulation duration and the missing reset sequence in my testbench. Increasing the simulation time made the waveforms clearer, while adding the reset sequence ensured that the system started from a known initial state before testing.
<!-- Copy the block above for each significant commit. -->

## Post-submission reflection

**What worked and why:**
The FSM design worked as intended for the main scenarios tested. The system transitioned from IDLE to WAIT_PASS when a vehicle was detected, returned to IDLE when a vehicle left before password verification, and entered RIGHT_PASS when the correct password was entered. The counter, LED blinking behaviour, and seven-segment messages were also observed in the simulation. Using a testbench and inspecting the waveforms helped me verify the behaviour instead of relying only on successful compilation.

**What I would change and why:**
I would pay more attention to the reset sequence and simulation timing from the beginning. I would also develop the testbench more systematically, testing each state transition and sensor combination separately before running the complete parking scenario. This would make it easier to identify whether an issue comes from the FSM implementation or from the testbench.

**What assumption did I carry in from the previous exercise that I had to revise here:**
I initially underestimated the importance of properly initializing a sequential circuit before simulation. I learned that a design may compile successfully but still behave unexpectedly if the reset signal is not correctly handled. I also realised that simulation time must be sufficient to observe the complete sequence of state transitions and counter operations.

**What part of this was my own contribution, and what did I learn from a teammate:**
I contributed to the initial FSM design, its VHDL implementation, and the development and debugging of the testbench. I also worked on understanding the state transitions and the behaviour of the sensors, counter, LEDs, and seven-segment displays. From my teammate, I learned the importance of refining the FSM together and checking the simulation timing. His suggestion to increase the simulation duration helped us obtain clearer waveforms, and our discussion also helped us identify and correct the missing reset sequence.
