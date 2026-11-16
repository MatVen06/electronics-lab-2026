# Journal � Exercise 1 � Car Park 1

> **You:** `indigo_laplace` � **Group:** `indigo` � **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry � 2026-11-11
**Commit reference:** b5130ce [TEST]: First scenario implementation and some changes

**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
1. I fixed the clock half period to match the note that asked for a 100MHz clock, replacing the haf-period of 500ps with 5ns (→which means that the clock period was 1ns (which is 1GHz)). I also alligned drive() and wait_state() procedures to a single clock cycle (of 10ns) instead of 1us and 5us.
2. I modified wait_state, expected_state procedures since the states have 3 bits width instead of 2 and added a timeout if the target state isn't reached within the max_cycles.
3. I moved the clock  statement outside the drive() and added a selected assignment to decode the 14 bits segments (e.g. off, En, EE etc) into the 3 bit-state signals. 
4. I implemented the first scenario (the one where there’s only one car that insert the correct password)

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
1. In order to allign to what the comment said after the clock assignment  (—100 MHz clock) and since the 100MHz period is 10ns, the semiperiod would become 5ns.
    
    Could also used 500ps for the clock outside the procedures, but since it is half of the period in the drive() I would have to put 1ns and 12ns to wait for the password.
    
    By alligning the waiting time with the clock period we can use wait_state() for wait_password which wasn’t consistent before as for the first clock cycle the state equal to C_WAIT_PASSWORD was false and by executing the previous waiting of 5 us with a clock of 1 ns and wait_state or other procedures wouldn’t see any change of state.
    
2. Previously they were logic vectors from 1 downto 0 but the states are 3 bits.
3. Previously the clock was inside the drive procedure, but if I hadn’t change it, everytime you call drive it would do only one movement from ‘0’ to ‘1’ and became flat afterwards.
4. I used three different procedures: drive, expect_state, wait_state.
    
    I could have used only two procedures (drive, expect_state) to define each state on the scenario, but I choose to use also wait_state in order to highlight the difference between the waiting_password state rather than the others,as the waiting_state has a fixed time duration and it is the only state that isn’t driven by external inputs (like sensors and passwords).

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->
Whether I should use type rather than constant for the states to mirror the source file or whether it is better if we change the use of states (like idle, waiting_password etc) with the use of outputs signals (e.g. green_light, red_light etc) to verify the scenario in order to check also the led behaviour.

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
