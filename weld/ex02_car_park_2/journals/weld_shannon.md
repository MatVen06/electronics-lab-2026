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

### Entry � 2026-11-20
**Commit reference:** `<!-- paste: git log --oneline -1 -->`
b1ad175 (HEAD -> main, origin/main, origin/HEAD) Merge branch 'main' of https://github.com/philippevelha/electronics-lab-2026

**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
fixed up the parking controller more and finished testing. I did have to fix a bug with the exit gates since I hadn't accounted for the scenario where someone entered from the wrong side and the system stayed in wait_payment. I fixed this by adding a very simple check to wait_payment to make sure the front sensor is on.

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
The check makes sure that people who enter from the wrong gate don't fuck up the whole system.

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->
I am content.

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->
It helped me discover that bug

---
<!-- Copy the block above for each significant commit. -->

## Post-submission reflection

**What worked and why:**
The code given from the handout, except when it didn't, then I had to change it until it worked.

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->
I would probably split the one architecture into multiple files, it seems inefficient to run everything on one control device.

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->
That there would only be one gate.

**What part of this was my own contribution, and what did I learn from a teammate:**
I did all of the coding but I did use the code given in the handout as a base and then filled in the rest.