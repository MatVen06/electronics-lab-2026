# Journal � Exercise 1 � Car Park 1

> **You:** `weld_lorentz` � **Group:** `weld` � **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log


### Entry � 2026-11-11
**Commit reference:** `9c2e184ceece7a8f3cc43e26803db24fdd2b7e9f`

**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
We broke down the exercise and decided on a State Diagram. This was useful to understand what the exercise asked for. We also decided to add new state transitions, mainly to include the hypothetical scenario of a car driving off while waiting. Furhtermore, decided that from WRONG_PASS it would make sense to let the user know the password is wrong (output "EE"), and then go back to WAIT for password resubmission. Considered how processing of multiple cars might work like.

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
We tried following closely the counter and how it is being initialized/ incremented, hence it made sense to initialize it in the starting IDLE state, and reset it between WAIT and WRONG_PASS as both those states increment it. 

Also considered an intuitive scenario, when a user inputs the wrong password he should go to wrong pass, the display and LED should let them know it is wrong for a specific given period of time, and then it should go back to WAIT to signal resubmission.

When processing multiple cars in a queue, STOP transitions to IDLE when 'back_sensor = 0' (the first car has driven past the gate), because of the car behind/waiting 'front_sensor = 1', we transition to IDLE and since 'front_sensor = 1' transitions to WAIT for processing the new car.

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->
We addes two extra states "RESET_COUNTER" between WAIT -> WRONG_PASS, but the handout specifies we have 5 states.

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->


---
<!-- Copy the block above for each significant commit. -->


### Entry � 2026-15-11
**Commit reference:** `bb49e8f876b28f8f073c5c4460ce8d3d650f21e0`

**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
Reworked the states to fix some logical problems and edge-cases. 

Mainly removed the RESET_COUNTER states.

Reworked the WRONG_PASS state to closer match '5.2 Scenario 2' (now it does not return to WAIT, it stays in WRONG_PASS until the correct password is provided or the car leaves). 

Decided on handling hypothetical scenario of the user leaving after inputting wrong password.

Reworked the conditions inside RIGHT_PASS to address the issue of the car being between sensors (front & back = 0) and not have the gate close as they drive through. RIGHT_PASS now loops if back_sensor = 0. 

Decided that STOP loops on 'back_sensor = 1', whatever front_sensor is.

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
The resetting of the counter is now abstracted. We assume the counter is being reset with each state transition.

Originally, we intended on staying in WRONG_PASS, display "EE" for 10 cylces, then move back to WAIT ("En") and check for password again. Now: WRONG_PASS → RIGHT_PASS when the password is correct, otherwise stay. WRONG_PASS needs no counter (this was done to more accurately reflect '5.2 Scenario 2').

Going back to IDLE when 'front_sensor = 0' in WRONG_PASS means the user drove off, we need an exit from WRONG_PASS or else a new user would arrive to the gate in that state. HEnce we return to IDLE.

For RIGHT_PASS -> IDLE
To prevent gate from closing as car drives through (BEFORE: RIGHT_PASS → IDLE if
'front_sensor = 0' & 'back_sensor = 0'). Now transitions to IDLE iff 'front_sensor = 0' &'back_sensor = 1'. (Also done to accurately represent '5.1 Scenario 1')

Loop in RIGHT_PASS, makes it stay in RIGHT_PASS if 'back_sensor = 0', aka to stay in RIGHT_PASS as car drives through.

Since STOP is entered when both sensors are 1, checking if front_sensor is also 1 each time for the loop condition was redundant.

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->


**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->
We had initially agreed on a certain layout for the sensors, however after a while it became evident that we had the wrong layout. It did not change much, but setting up the actual layout revealed such logical flow issues. Furthermore we realized that we were wasting 10 cycles by staying in WRONG_PASS and then tranistioning back to WAIT for resubmission.

Scenario 1 specifies that the transition from RIGHT_PASS to IDLE should happen when back_sensor = 1

---
<!-- Copy the block above for each significant commit. -->


### Entry � 2026-15-11
**Commit reference:** `8e9977c8cc45188ba88e44ca8157beab17afa67a`

**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
Uploaded the correct state diagram, added some safeguards for WAIT transition to RIGHT_PASS or WRONG_PASS, and removed unecessary counter.

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
The added Safeguard condition on WAIT → WRONG_PASS or RIGHT_PASS states and  WRONG_PASS → RIGHT_PASS. Now requires 'front_sensor = 1' as a guard. This was required since we are adding a path that returns to IDLE when 'front_sensor = 0', meaning we had an overlap in logic as 'front_sensor = 0' can be true at the same time as every other exit from WAIT. In WRONG_PASS it can be true together with the correct-password exit and with the self-loop.

Removed 'counter >= 10' guard when transitioning from WRONG_PASS → RIGHT_PASS, as counter is no longer used in WRONG_PASS

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->
In our previous implementation of WAIT, we had an overlap in logic as 'front_sensor = 0' could be true at the same time as every other exit from WAIT.

---
<!-- Copy the block above for each significant commit. -->


### Entry � 2026-17-11
**Commit reference:** `8e9977c8cc45188ba88e44ca8157beab17afa67a`

**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
Slight adjustments to the VHDL code for the parking system. Mainly to match the functionality of WRONG_PASS and RIGHT_PASS from the state diagram. (Added some comments and whitespace for readability)

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
Changed it so it now loops in WRONG_PASS until passwords match, if so the next state should be RIGHT_PASS.

Added extra condition of front_sensor = '0' and back_sensor = '1' in RIGHT_PASS to transition to IDLE. Meaning had to modifiy the overriding condition of whenever 'front_sensor = 0' go to IDLE, to exclude the RIGHT_PASS state.

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->

---
<!-- Copy the block above for each significant commit. -->


### Entry � 2026-17-11
**Commit reference:** `45b8860c57c8c1842eaba06969a82d87c6a9e573`

**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
Modifications to tb1 and tb2 to work with the updated code. 

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
Changed the tb2 to expecct the WRONG_PASS loop
Changed the tb1 to include the car driving between two sensors.

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->

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

