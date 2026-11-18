# Journal — Exercise 1 — Car Park 1

> **You:** `gamboge_faraday` · **Group:** `gamboge` · **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry — 2026-11-16 
**Commit reference:** [REFLECT] Changed the file structure and added TODOS + 
[IMPL] Added the files for datapath and FSM with skeleton.

**What I implemented or decided:**
I decided to divide the system in three files. One for the datapath, one for the Control unit (FSM) and one for the instantiation and connection of the signals.

**Why I structured it this way:**
I considered doing everything in one file, however, I think this division makes it easier to debug and to implement later. 

**What I am not sure about:**
I'm not sure whether this is the best way to structure it in the end, since I haven't had direct experience yet. Going forward in the project will allow me to evaluate if this is the case, and provide insights also for later projects.

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->

---
<!-- Copy the block above for each significant commit. -->

### Entry — 2026-11-18 
**Commit reference:** [IMPL] Implementation of the FSM. 

**What I implemented or decided:**
Starting from the FSM that we have drawn on paper last wednesday, I wrote the code for the FSM while my groupmates checked and tested the logic. I decided to create three separate processes for states, next states and outputs. I decided to encode the control signals for the two displays independently using a 3-bit gray code. We decided together to make the led blink for three clock cycles, using a counter in the datapath (to be implemented).

**Why I structured it this way:**
I used three processes to decouple the code and have an easier time debugging and finding out what breaks later. I decided to use two independent 3-bit gray codes to minimize the bits used and to avoid glitches.

**What I am not sure about:**
I'm not sure if using two 3-bit codes is the best idea or if there are better alternatives, also considering the future structure of the datapath.

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->

---

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
