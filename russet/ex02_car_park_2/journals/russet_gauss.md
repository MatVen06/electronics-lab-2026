# Journal � Exercise 2 � Car Park 2

> **You:** `russet_gauss` � **Group:** `russet` � **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry � 2026-11-24
**Commit reference:** `<e7054b03d6bb9f24e31dd3362130b47d5d1b0aa1>`

**What I implemented or decided:**
For the countrmgt i decided to use a variable "delta", which is an integer that can have a range of values between -2 and 2 to process the counting of the cars during the clock cycle 

**Why I structured it this way:**
At first i used else if statements but then realized that if during one clock cycle 2 cars enter the counter will see them just as 1 as it remembers the count from the previous cycle. Instead using the variable delta it can keep count inside the same cycle of all the cars that enter. 

**What I am not sure about:**
The problem is that if there is 1 spot left and 2 cars are lined up to enter, I think the counter will simply allow both cars to enter allowing overbooking of the parking 

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->

---
<!-- Copy the block above for each significant commit. -->

### Entry - 2026-11-24 (testbenches 1 and 2)
**Commit reference:** `e1d8613e358804aa6e3dac683a8f5b9cb47bb051 a77cb827e219ab6f702a16ab3520eae71536eb71` 

**What I implemented or decided:**
I implemented both the testbenches, the first is simply testing the singular components and that the car counter and display work accordingly when a car enters and exits showing respectively 6 on the display and then 7.
The second testbench instead is built off the first but it testes more scenarios: two entries/exits at the same time, trying to enter when full or overbooking so 2 cars are entering with 1 spot left.

**Why I structured it this way:**
the test cases where given in the handout,so the structure was preatty straight forward
so I just had to write for everyone a case  
**What I am not sure about:**
The test benches work, but the code fails to run the scenario 6, and goes in overbooking yet and not sure how to handle the priority for the gates so that only one car enters  

**What the simulation or hardware told me I was wrong about:**
The simulation ran as expected in fact everything but the scenario 6 where we had doubts, ran without any problems 

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**