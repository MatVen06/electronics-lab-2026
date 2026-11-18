# Journal � Exercise 1 � Car Park 1

> **You:** `cobalt_tesla` � **Group:** `cobalt` � **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry � 2026-11-18
**Commit reference:** `7a2d693 [IMPL] State logic to architecture`

**What I implemented or decided:**
I used a counter that goes from 0 to 9 to count clock cycles.
I used a default password "00" "00" to remain inside WAIT_PASS when nothing was inputted instead of going to wrong password
I also decided to wait 5 clock cycles inside WRONG_PASS to keep the DISPLAY and the LEDs that signal "wrong password" on

**Why I structured it this way:**
Having it go from 0 to 9 and reset whenever it's needed is useful since unexpected behaviour can be more easily caught when the counter goes over 9 (which is never intended)
The default password makes it so the WRONG_PASS state doesn't trigger immediately if the user still hasn't inputted anything
Waiting 5 clock cycles inside WRONG_PASS gives time to the user to see the LEDs and display, altough the number of cycles can be adjusted in the future

**What I am not sure about:**
I am still a bit unsure on how VHDL handles unassigned variables and overflows of ranged variable, for that reason I have refrained from using anything of the sort

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
