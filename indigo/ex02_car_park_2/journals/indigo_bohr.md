# Journal — Exercise 2 — Car Park 2

> **You:** `indigo_bohr` · **Group:** `indigo` · **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry — 2026-11-25
**Commit reference:** f28a2f8

**What I implemented or decided:**
- Implemented the state machine for entry gates Gin1 and Gin2.

**Why I structured it this way:**
- Separated Gin1 and Gin2 into independent combinational processes so both entry gates can operate at the same time without interfering with each other.

**What I am not sure about:**
- How the shared car_count signal will handle simultaneous arrivals if inc_Gin1 and inc_Gin2 pulse on the same clock cycle.
- Whether the _prev sensor signals in the sensitivity list are needed for edge detection, or if level-sensitive sensor checks are sufficient once tested against the testbenches.

**What the simulation or hardware told me I was wrong about:**
- In CAR_ENTERED, when sensor_B went back to '0', I transitioned back to IDLE without setting inc_Gin1 <= '1' or inc_Gin2 <= '1', while car_count remained at 0.
- I initially forgot to open the barrier (barrier_Gin <= '1') once a car was detected with available capacity in CAR_DETECTED, which would block the car from driving to reach sensor_B.
- When I first added barrier_Gin <= '1', I placed it inside the elsif sensor_B = '1' branch rather than unconditionally at the top of CAR_DETECTED. While waiting for the car to move, neither branch executed, so the barrier was still closed.
---
<!-- Copy the block above for each significant commit. -->

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
