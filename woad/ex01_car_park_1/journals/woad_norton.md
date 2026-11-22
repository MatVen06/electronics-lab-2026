# Journal � Exercise 1 � Car Park 1

> **You:** `woad_norton` � **Group:** `woad` � **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry � 2026-11-11
**Commit reference:** `<!-- paste: git log --oneline -1 -->`
d3c8cdb added Car_Parking_System.vhd in src


**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
I implemented the basic Car_Parking_System entity using a finite state machine with five states: IDLE, WAIT_PASS, WRONG_PASS, RIGHT_PASS and STOP. I separated the state register, timer/counter, blinking LED logic and next-state/output logic into different processes. I also implemented the password verification and the conditions for allowing or stopping a car from entering.


**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
I chose an FSM because the parking system has different operating phases, each with its own conditions and outputs. Separating the logic into different processes makes the implementation easier to read and maintain. I also decided to use a counter to manage time-dependent transitions, such as waiting for password input and determining how long the system should remain in certain states.

For the LEDs, I initially used separate blinking logic controlled by RED_BLK and GREEN_BLK signals. This allowed the FSM to decide when an LED should blink without directly handling the clock signal in every state.

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->
I am not completely sure whether the state register process is implemented correctly, especially its sensitivity list and the way it updates the state. I am also unsure whether the counter behaves as intended when transitioning between states, and whether the blinking LED process handles all possible conditions correctly.

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->
### Entry � 2026-11-11
**Commit reference:** `<!-- paste: git log --oneline -1 -->`
a72ac55 added testbench (not working)

**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
I created the first testbench for the Car Parking System and connected the DUT to signals representing the clock, reset, sensors, password inputs, LEDs and seven-segment displays. I generated a 10 ns clock and implemented three test scenarios: a car entering with the correct password, a car entering with an incorrect password, and a system reset.


**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
I decided to use a single process with fixed delays to simulate the sequence of events. This made it straightforward to reproduce the expected behaviour of the system step by step. I started with a successful parking attempt, followed by an incorrect password, and finally a reset, so I could test the main operating conditions.

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->
I am not sure whether the fixed delays are correctly aligned with the internal counter and state transitions of the FSM. In particular, I do not know whether the password is being entered at the right moment or whether the sensors change state at the appropriate time.

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->
### Entry � 2026-11-11
**Commit reference:** `<!-- paste: git log --oneline -1 -->`
f816925 correction led value and 2/4 scenario

**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
I revised the FSM and the testbench. In the FSM, I moved the LED blinking behaviour directly into the state logic, using the clock signal to make the red and green LEDs blink. This avoids having separate processes driving the same LED outputs. In the testbench, I added two scenarios: successful parking with the correct password and handling an incorrect password. I also made the clock period configurable through a constant.

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
I wanted the LED behaviour to be controlled in one place, so each output would have a single driver and its value would depend on the current FSM state. I kept the FSM divided into separate processes for state registration, counter management and next-state/output logic, since this makes the different responsibilities easier to understand. For the testbench, I used a single stimulus process with delays based on the clock period, making the scenarios easier to read and adjust.

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->
I am not completely sure that all the delays in the testbench are correctly aligned with the counter and the FSM transitions. In particular, I am unsure whether the second scenario fully tests the recovery from an incorrect password, since the system returns to the password-waiting state and may evaluate the password again. I also have not yet implemented the multiple-car scenario, despite having reserved a section for it.

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->

### Entry � 2026-11-11
**Commit reference:** `<!-- paste: git log --oneline -1 -->`
fb44169 4/4 scenario testbench

**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
I expanded the testbench to include four scenarios: successful parking, incorrect password handling, multiple cars, and system reset. I added resets between scenarios to ensure that each test starts from a known initial state. In the multiple-car scenario, I simulated a second car arriving while the first car was still passing through the parking system, and attempted to test the handling of an incorrect password from the second car.

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
I wanted to test not only the normal parking procedure but also how the system behaves in less straightforward situations. Resetting the system between the first two scenarios makes their results easier to distinguish, while the multiple-car scenario deliberately avoids an intermediate reset to test how the FSM handles consecutive arrivals. I kept the stimulus in one process, using delays based on the clock period to make the sequence of events easier to follow.

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->
I am not completely sure whether the multiple-car scenario accurately represents two consecutive cars. In particular, I am unsure whether the second car's password is evaluated at the intended time, since the FSM may still be in S_RIGHT_PASS rather than S_WAIT_PASS. I also wonder whether the fixed delays are sufficient to guarantee that each scenario reaches the expected state before the next inputs are applied.

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->

### Entry � 2026-11-11
**Commit reference:** `<!-- paste: git log --oneline -1 -->`
f8627e4 (HEAD -> Woad, origin/Woad) MADE BENCHMARK STOP WHEN FINISHED

**What I implemented or decided:**
<!-- 2�4 sentences. Be specific about architecture choices. -->
I modified the testbench so that the simulation terminates automatically when all four scenarios have finished. I added use std.env.finish and replaced the final indefinite wait with a call to finish. I also documented the GHDL commands required to compile the VHDL files using the VHDL-2008 standard, elaborate the testbench and generate a VCD waveform file.

**Why I structured it this way:**
<!-- What alternatives did you consider? Why did you reject them? -->
Previously, the testbench remained active indefinitely after completing the stimulus, requiring me to stop the simulation manually. Using finish makes the simulation stop automatically, which is more convenient when running repeated tests. I also chose to document the compilation and execution commands so the testbench can be reproduced more easily.

**What I am not sure about:**
<!-- Honest uncertainty. Never graded for correctness � only for presence. -->
I am still not completely sure that all four scenarios test the intended behaviour, especially the multiple-car scenario. The testbench currently relies on fixed delays and does not use assertions to verify the expected outputs, so I cannot automatically guarantee that every transition occurred correctly. I am also unsure whether the VCD waveform contains enough information to identify every possible issue without inspecting the internal FSM signals.

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->
During simulation, I discovered that having separate processes drive the same LED outputs caused conflicts. I initially tried to manage the blinking LEDs through a dedicated process, but this was problematic because the FSM was also assigning values to those outputs. I therefore moved the LED control into the FSM logic, ensuring that each LED had a single driver.
I also learned that fixed delays in the testbench do not necessarily guarantee that the FSM has reached the state I expect. In particular, testing multiple cars is more complicated than simply changing the sensor and password inputs, because the system must first complete the previous car's passage.

---
<!-- Copy the block above for each significant commit. -->

## Post-submission reflection

**What worked and why:**
We decided to use a finite state machine (FSM) to manage the different phases of the parking system. The implementation separates the state register, timer/counter and next-state/output logic into different processes. This makes the behaviour easier to understand and allows each part to have a specific responsibility.
For the testbench, we used a process to simulate different situations by changing the sensors, passwords and reset signal over time. We divided the tests into four scenarios to verify successful parking, incorrect passwords, multiple cars and reset behaviour. We also generated a clock with a 10 ns period (10Mhz) to simulate the system's internal clock operation.

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->
Honestly I'm satisfied with the resoult maybe I'd change how the count for the clock works as it looks sketchy...

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
I made the skeleton of both the SFM entity and the main scenarios, fixed the led conflict and helped with the testbench design.
