# Journal — Exercise 1 — Car Park 1

> **You:** `madder_bode` · **Group:** `madder` · **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry — 2026-11-11
**Commit reference:** nothing

**What I implemented or decided:**
Me and Thevenin started working on the Data Path and we decided the general shape (right word?) of it while the other designed the diagram. We drew a draft with the essential components like 4-bit registers for the inputs and the saved password, a 4-bit counter for the clock, a mulitplexer and a 4-bit comparator.

**Why I structured it this way:**
We designed the Data path to follow the constraints like the clock. The counter counts the clock and the register stores the password that is inserted, when the clock reaches 10 the multiplexer let the inputs in (default input is 0000) that goes straight to a comparator that compares the inputs to the password saved in a register, if they are the same we get the output 1 otherwise 0. 

**What I am not sure about:**
I don't really get what is a FSM, I mean I know how to do the diagram, that's easy, but it seems (Thevenin said so) that it is a circuit like the data path but is different because there is no clock and no calculation ?? or is it the entire circuit and the Data path is a part of the FSM? What is the part that will manage the sensors and the lights and the screen? or is the Data path that should manage the screen and the lights? And the sensors? 

**What the simulation or hardware told me I was wrong about:**
<!-- Leave blank now. Fill in when you find out. Most important field. -->


### Entry — 2026-18-11
**Commit reference:** 0487ed5affeaa8a7be28456b6ad2f234539b9e24

**What I implemented or decided:**
I have corrected the car_park1.vhd file (formerly cp1.vhd) as it did not comply with the FSM diagram: whilst in the ‘WRONG_PASS’ state, it would check whether the password was correct in order to transition to the ‘RIGHT_PASS’ state, but this behaviour was not specified in the FSM diagram; Furthermore, I reworked the counter so that it remained in the “WRONG_PASS” state long enough for the flashing of the red LED to be visible and noticeable. I then corrected testbenches 1 and 4 because they terminated in a way that caused an error in GHDL, and finally, I split testbenches 2 and 3 into two separate files.

**Why I structured it this way:**
As I said, I configured the red LED in that way so that it would flash; I did not apply the same logic to the green LED for the ‘RIGHT_PASS’ state simply because it remains in that state until the car moves away (the back sensor goes to 1). I’ve split testbenches 2 and 3 because the handout explicitly states ‘testbenches’ – in the plural – so there are multiple testbenches. Apart from that, I’ve simply modified the names and VCD files to make them easier to understand.

**What I am not sure about:**
Two things caught my attention: 1) “--vcd=scenario1.vcd” and “--wave=scenario1.vcd” produce different results; not that the waves or behaviour have suddenly changed, but in the first case, in the Vaporwave netlist, the circuit is saved as a ‘module’, whilst in the second it is saved as “vhdlarchitecture”; the main difference I’ve noticed is that one shows the current state and the next state (wave), whilst the other does not (vcd); so I continue to use the “wave” command to make it easier to understand the states. 2) What are the best practices? I realise that the main VHD file should simulate the hardware, whilst the testbench should simulate what is happening (which is why the hardware simply receives sensor data as another input, whilst the testbench has to manage timings etc. to give the impression that the car is actually moving); however, I’ve found myself changing the password in the register at random moments, which shouldn’t be the case; I should be entering the password only in the "WAIT_PASS" state. So, on the one hand, I think I could add an ‘ENTER’ button to improve the logic, and on the other hand, I reckon that, for a first project, it’s more than adequate as it is; so starting from scratch on a whim because of an insignificant detail seems a bit silly to me.

**What the simulation or hardware told me I was wrong about:**
As I said earlier, I made the mistake of writing the passwords into the register before the "WAIT_PASS" state; this actually helped me spot the incorrect status change, because in the second scenario the ‘RIGHT_PASS’ status flashed before reverting to the ‘IDLE’ status, which made no sense at all. Furthermore, it allowed me to notice that the red LED only flashed once during the ‘WRONG_PASS’ state, so there was something wrong there too. And, it helped me understand the difference between “--wave” and “--vcd”; finally, it provided me with the key to perhaps better understanding of logic networks, as it gave me an insight into the machine’s logic – into how the machine ‘thinks’ – and I hope that, by understanding how the machine thinks, I can understand how the logic networks work, though for now it’s just a hunch.

---
<!-- Copy the block above for each significant commit. -->

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
