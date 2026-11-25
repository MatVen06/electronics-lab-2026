# Journal — Exercise 2 — Car Park 2

> **You:** `russet_fourier` · **Group:** `russet` · **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry — 2026-11-11
**Commit reference:** `<!-- paste: git log --oneline -1 -->`

**What I implemented or decided:**
<!-- 2–4 sentences. Be specific about architecture choices. -->
My assigned part was Tasks 1–3 (types and signals, state register, entry gate FSMs) and Test Case 1.

Tasks 1 and 2 in the provided template already matched the handout (state types, per-gate state signals, synchronous state register with active-low reset), so I kept them unchanged.
I implemented the entry gate FSMs for Gin1 and Gin2 as two independent processes with four states each: IDLE, CAR_DETECTED, CAR_ENTERING, CAR_ENTERED.
The barrier opens in CAR_DETECTED (while there is a free spot) and stays open through CAR_ENTERING and CAR_ENTERED. It closes when the car clears sensor B.
inc_Gin1 / inc_Gin2 are one-clock-cycle pulses generated on the transition CAR_ENTERED -> IDLE.
A car that reverses out of CAR_ENTERING (A = 1, B = 0) goes back to CAR_DETECTED and is not counted.
I wrote a self-checking testbench for Test Case 1 (reset, one car entering through Gin1, one car exiting through Gout1 with payment). It checks barriers, payment signals, lights and the display, and prints a final PASSED/FAILED summary.

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
I opened the barrier in CAR_DETECTED instead of CAR_ENTERING as in the handout template. With the template, the barrier would only open after the car had already reached sensor B, which is physically wrong. The provided testbenches also expect the barrier to be open shortly after sensor A goes high.
I keep the barrier open in CAR_ENTERED because section 2.2.1 says the barrier closes only after the car clears sensor B.
I check the capacity twice, in IDLE and again in CAR_DETECTED. If the other entry gate takes the last spot while this gate is in CAR_DETECTED, this gate returns to IDLE and its barrier stays closed.
I generate inc_Gin as a pulse on the exit transition from CAR_ENTERED, so each car is counted exactly once.
I kept the FSMs level-based. The *_prev signals suggested by the handout are declared and reset, but not used.

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness — only for presence. -->
If one spot is left and two cars arrive at Gin1 and Gin2 in the same clock cycle, both pass the capacity check and the counter could exceed the capacity. This needs arbitration in the counter (Task 5), which is not my part, i still have to check with my group.
There is no timeout or debouncing: a stuck sensor could keep a gate in CAR_ENTERING forever.
The testbench checks the counter only through the display, because car_count is not an output port.

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->
Running Test Case 1 against the template showed that payment_request was driven by two processes, that the payment light never turned on in the normal case, and that the display showed occupied spots instead of free spots

<!-- Copy the block above for each significant commit. -->

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
