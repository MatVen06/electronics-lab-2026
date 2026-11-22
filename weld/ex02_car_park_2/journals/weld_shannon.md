# Journal � Exercise 2 � Car Park 2

> **You:** `weld_shannon` � **Group:** `weld` � **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry � 2026-11-20
**Commit reference:** `<!-- paste: git log --oneline -1 -->`

**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
Implemented the vhdl and begun testing, most of the code was copied from the handout but I had to modify a few things to get things to work (such as the countermgt process not accounting for simultaneous entry and exit). Some of the testbenches also needed to be fixed (they looped endlessly).

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
It's easier to do what is already known to work, so I used the code from the handout.

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->
why assert payment_requested = '0'?

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->
countermgt needed updating.

---
<!-- Copy the block above for each significant commit. -->

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
