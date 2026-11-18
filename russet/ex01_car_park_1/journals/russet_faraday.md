# Journal � Exercise 1 � Car Park 1

> **You:** `russet_faraday` � **Group:** `russet` � **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry � 2026-11-11
**Commit reference:** `8e5b907 journal entry & tb draft`

**What I implemented or decided:**
Worked together with heaviside on her computer, and she made the commit. Implemented the FSM for the car parking system with five states (IDLE, WAIT_PASSWORD, WRONG_PASSWORD, RIGHT_PASSWORD, STOP). Implemented the outputs so that they depend on state only.

**Why I structured it this way:**
The wait counter and the blinking are handles once, outside the individual states to keep the state logic simpler

**What I am not sure about:**
Whether our interpetation of the task is correct, for example the blinking speed and the 10-cycle wait

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
