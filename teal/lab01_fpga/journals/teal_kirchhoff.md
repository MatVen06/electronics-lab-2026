# Journal � Lab 1 � FPGA Implementation

> **You:** `teal_kirchhoff` � **Group:** `teal` � **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry � 2026-11-11
**Commit reference:** `<!-- paste: git log --oneline -1 -->`

**What I implemented or decided:**
3cb55ea, a3f3743 I fixed the state diagram, because I realized that there were some scenarios that we didnt consider. 

**Why I structured it this way:**
From the state Wrong_Pass if a wrong password is entered we must stay in the state Wrong_Pass. We didnt consider this possibility

**What I am not sure about:**
I'm still not sure about the reset. Up to now we decided to keep an arrow that goes into Idle with reset_n=0 but I'm not sure it is the right way.

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
