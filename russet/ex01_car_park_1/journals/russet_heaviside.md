# Journal � Exercise 1 � Car Park 1

> **You:** `russet_heaviside` � **Group:** `russet` � **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry � 2026-11-11
**Commit reference:** 8e5b907 `<!-- paste: git log --oneline -1 -->`

**What I implemented or decided:**
- read scenario and tasks 
- brainstormed with the group how we want to approach task
- write down important information to clarify
- entity is given in the task
- started with the architecture (inspiration from sliding door exercise)
 - signals -> important for different features of the system
 - constants -> all the different display states
 - variable for password check
 - case for each state sastifying the stages of system based on State table
 - display output
 - light output
 -> both dependent on state of fsm
- begin of testbench (also inspiration from sliding door exercise)
 - write down most important aspects for clarification (scenarios and conventions)
 - initialize entity
 - define signals and constants needed for all scenarios
 - dut initialization
 - procedures for each aspect we want to check ... & expected outputs
 - helpers
 - reset types
- test first scenario -> normal entry (not finished?)


<!-- 2�4 sentences. Be specific about architecture choices. -->

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
- we had different ways of counting the waiting time but as we built the architecture this was the only that made sense for us
- the same is true for the blinking light -> we first tried to implement it in each state seperately but this is a lot easier and simpler
- we learned not to put everything in the states and decompose each
- this temporary result had the best overview

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->
- if anything will actually work because we could not really test it yet -> maybe we need to change everything again
- if we understood the details of the task correctly
- 

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->

---
<!-- Copy the block above for each significant commit. -->
### Entry � 2026-11-18
**Commit reference:**  fe35f03`<!-- paste: git log --oneline -1 -->`

**What I implemented or decided:**
We worked on the other testbench scenarios and had to run a few tests before everything was working, I was surprised though that our architecture did not need any changes.
We ran the simulation and all the scenarios were passed. Now we started looking at the waveform and doublecheck our simulations.

### Entry � 2026-11-25
**Commit reference:**  6c62deb`<!-- paste: git log --oneline -1 -->`

**What I implemented or decided:**
Checked the simulation and the waveform. Adjusted files to submission format.

**What I am not sure about:**
If we interpreted it in the right way. 

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->
We misunderstood the front and back sensor. We thought the back sensor would be a sensor for a car behind but it turned out to be a sensor baehind the gate which activates when the car has passed through. So if both sensors are active we know that a new car is at the gate while the first one is passing through.

## Post-submission reflection

**What worked and why:**
We wrote down assumptions and interpretations of the task so we could work more structured and the communication in the group was easier. Separating the work because it was easier to focus working on one problem instead of doing all the tasks with everyone.

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->
Consider the scenarios earlier and think of the testbench when doing the architecture for example in commit fe35f03ac89449ba47027d2e635a5df9d6279b6b. In general commit smaller changes and not only once for each lab so you can afterwards the different steps we went through.

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
I worked on most of the exercise myself but it very helpful to discuss decisions with teammates and have someone doublecheck your work. Especially in the first part of getting to know the exercise.