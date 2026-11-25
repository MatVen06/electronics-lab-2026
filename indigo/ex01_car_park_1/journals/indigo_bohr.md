# Journal — Exercise 1 — Car Park 1

> **You:** `indigo_bohr` · **Group:** `indigo` · **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log
### Entry — 2026-11-11
**Commit reference:** `<!-- paste: git log --oneline -1 -->` *(Note: Pushed by a classmate on my behalf due to a pending GitHub repository invitation issue.)*

**What I implemented or decided:**
- Implemented the initial states of the testbench (`IDLE`) using a white-box approach.

**Why I structured it this way:**
- Although we later realized it was not optimal, we initially chose this structure because we thought bundling all inputs and outputs into a single command would be more efficient and specific.

**What I am not sure about:**
- How to cover all input combinations efficiently, as manually driving a 7-bit vector for every test case quickly became tedious and difficult to manage.
- How to properly verify the LEDs and the `HEX_1` and `HEX_2` 7-segment displays within this testbench format.
- How long the wait delays should be depending on the specific scenario being tested.

**What the simulation or hardware told me I was wrong about:**
- We quickly realized that the structural limitations of this setup went well beyond simple syntax errors, which led us to discard it and switch to a black-box approach.

Entry - 2026-11-18
Commit reference: <paste-your-commit-hash> (Note: Pushed by a classmate on my behalf due to a GitHub invitation issue.)

[TEST]: Switch to black-box self-checking testbench and implement all 4 scenarios

What I implemented or decided:
- Implemented the testbench for the parking system from a white-box approach to a black-box.
- Implemented assert checks for all four scenarios
- Verified system transitions through the 7-segment display outputs and LED levels and adjusted wait durations (CLK_PERIOD * 12 for password validation and CLK_PERIOD * 2 for state settling) and reset sensor inputs between scenarios.

Why I structured it this way:
- Used the drive for each input signal individually by name instead of packing everything into a 7-bit vector ("0000000") for convenience.
- Used CLK_PERIOD * 12 (120 ns) instead of single 10 ns steps so that the password inputs remain stable across the full 10-cycle, to give the FSM sufficient clock edges to settle before the assertions.
- In states where GREEN_LED or RED_LED blink at clock frequency (RIGHT_PASSWORD, WRONG_PASSWORD, STOP), checking the steady 7-segment display values avoids false assertion failures.

What I am not sure about:
- How closely the sensor overlap timing in Scenario 3 (asserting front_sensor while back_sensor is active, then releasing back_sensor) aligns with the RTL implementation's exact transition conditions for STOP.

What the simulation or hardware told me I was wrong about:
- The assertions failed because they were placed right after signal assignments (<=) without a wait statement, and because back_sensor was left at '1' between scenarios.
- I also realized that checking GREEN_LED = '1' or RED_LED = '1' at a single moment in blinking states can fail randomly depending on which half of the clock cycle the simulation samples, so checking the steady 7-segment display characters ("GO", "EE", "SP") is much more reliable


## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**
