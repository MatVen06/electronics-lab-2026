
- we only need a counter during the pass states (WAIT, WRONG, PASS) so we added a reset to the counter when passing by idle.

- we originally chose to keep a single transition from the STOP state (pointing to IDLE) to make the state machine simpler, we believe that in this case, given that the IDLE state implies the gate is closed and also resets the counter, that the lost cycle in the transition STOP to IDLE to WAIT_PASS should not have any negative effects on the functionality of the simulation. this decision also covers us in the case that the second car decides to back up and leave instead of entering the parking.

- based on the original exercise description, we decided to keep the machine in the "wrong pass" state until either the password is inserted correctly or the car leaves (in that case we switch to idle).
