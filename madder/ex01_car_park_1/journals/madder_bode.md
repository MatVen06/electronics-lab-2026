# Journal — Exercise 1 — Car Park 1

> **You:** `madder_bode` · **Group:** `madder` · **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry — 2026-11-11
**Commit reference:** nothing

**What I implemented or decided:**
Me and Thevenin started working on the Data Path and we decided the general shape (right word?) of it while the other designed the diagram. We drew a draft with the essential components like 4-bit registers for the inputs and the saved password, a 4-bit counter for the clock, a mulitplexer and a 4-bit comparator.

**Why I structured it this way:**
We designed the Data path to follow the constraints like the clock. The counter counts the clock and the register stores the password that is inserted, when the clock reaches 10 the multiplexer let the inputs in (default input is 0000) that goes straight to a comparator that compares the inputs to the password saved in a register, if they are the same we get the output 1 otherwise 0. 

**What I am not sure about:**
I don't really get what is a FSM, I mean I know how to do the diagram, that's easy, but it seems (Thevenin said so) that it is a circuit like the data path but is different because there is no clock and no calculation ?? or is it the entire circuit and the Data path is a part of the FSM? What is the part that will manage the sensors and the lights and the screen? or is the Data path that should manage the screen and the lights? And the sensors? 

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->

---
<!-- Copy the block above for each significant commit. -->

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
