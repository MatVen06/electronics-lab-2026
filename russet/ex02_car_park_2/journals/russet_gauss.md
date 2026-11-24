# Journal � Exercise 2 � Car Park 2

> **You:** `russet_gauss` � **Group:** `russet` � **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry � 2026-11-24
**Commit reference:** `<e7054b03d6bb9f24e31dd3362130b47d5d1b0aa1>`

**What I implemented or decided:**
i decided to use delta, a variable for counter so it's limited and never surpasses the parking capacity as it is cleaner

**Why I structured it this way:**
i think it's a neater way to write the code 

**What I am not sure about:**
i am not really sure wheter it works or it just hides the car if there is 1 spot left and 2 cars enter 

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->

---
<!-- Copy the block above for each significant commit. -->

### Entry - 2026-11-24 (testbenches 1 and 2)
**Commit reference:** `e1d8613e358804aa6e3dac683a8f5b9cb47bb051 a77cb827e219ab6f702a16ab3520eae71536eb71` 

**What I implemented or decided:**
I implemented both the testbenches

**Why I structured it this way:**
i structured tb 2 this way even if it fails to run the vhdl so that we can look for a fix  
**What I am not sure about:**
how should i fix the overbooking, and the payment as one pulse could affect both gates to open 

**What the simulation or hardware told me I was wrong about:**
that the code doesn't work for case where 2 cars are lined up and there is only one spot left, as it goes in overbooking

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**