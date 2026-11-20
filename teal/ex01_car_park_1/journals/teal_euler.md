# Journal — Exercise 1 — Car Park 1

> **You:** `teal_euler` · **Group:** `teal` · **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry — 2026-11-11
**Commit reference:** `<!-- paste: git log --oneline -1 -->`

**What I implemented or decided:**
<!-- 2–4 sentences. Be specific about architecture choices. -->
I've helped in the design of the state diagram and redrawn it as we fix a few things (some mistakes or misunderstandings of the exercise).

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
Regarding the state diagram, based on the requirements of the esercise such diagram fit best, with no added functions based on assumptions (for example it wasn't added the fuction of the system going back to IDLE from WAIT_PASS or WRONG_PASS if front_sensor returns to 0, since it wasn't implied or required by the exercise)

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness — only for presence. -->
I'm a bit confused by the difference between FSM diagram and state diagram. From my undesrtanding the FSM diagram shows the the different states but specifies the requirements to change state and their outputs. As for the state diagram it only shows the states and calls the change in states in wordings (for example IDLE --> WAIT_PASS in FSM diagram front_sensor = 1 as it detects a car, in state diagram i'd just call it "car detected".

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->
While testing out the code with the testbench we noticed the variable number of cars which we at first didn't know how to implemented as it wasn't present in any scenario as an output. We asked and found out we could just use it as an output during the testing with the tb to understand if the scenario with both cars worked at a glance.
As for mistakes made with the code there were none as we polished well (with many remakes) the state diagram.
---
<!-- Copy the block above for each significant commit. -->

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
