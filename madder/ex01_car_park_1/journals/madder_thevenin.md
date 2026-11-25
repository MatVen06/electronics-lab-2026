# Journal — Exercise 1 — Car Park 1

> **You:** `madder_thevenin` · **Group:** `madder` · **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry — 2026-11-11
**Commit reference:** `no reference`

**What I implemented or decided:**
Me and Bode worked on the datapath structure, first by speaking about it, and then we drew the graph on paper using 4-bit registers for input and reference password values linked to a comparator, same for a 4 bit counter and its check value. The comparator will receive data after a multiplexer made sure that counter value was 10. 

**Why I structured it this way:**
We wanted a simple and reusable graph. We made sure each component did the right job and followed the logic we decided to use.

**What I am not sure about:**
I think there might be a simpler way of organizing the datapath. For example, I'm not fully convinced about the multiplexer. 

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->
### Entry — 2026-18-11
**Commit reference:** `no reference`

**What I implemented or decided:**
I revised the datapath and found out there was a simpler way of doing it by splitting the password and the counter parts. I made sure the datapath was implemented correctly in the code. Then I helped Bode to understand the waveform logic to understand if what we did was correct or not.

**Why I structured it this way:**
By splitting the datapath, I could remove the multiplexer which I wasn't sure about. Now we have two 4-bit registers and a comparator for the password part; a 4 bit register, a 4 bit counter, and a comparator for the clock part. The 2 parts are now separated and will work together only in the logic circuit. 

**What I am not sure about:**
I'm not fully sure about my waveform interpretations since I still have to improve my VHDL coding skills, but from what Bode said, my assumptions weren't bad. 

**What the simulation or hardware told me I was wrong about:**
---
The simulation told me the new datapath configuration worked; I don't know if the old one would have worked since we didn't implement it due to the easier implementation of the newest version.

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
