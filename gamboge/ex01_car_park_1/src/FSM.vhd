library ieee;
use ieee.std_logic_1164.all;

entity FSM is
port( 
-- TODO
)
end FSM;

architecture rtl of FSM is 
    type state_t is (IDLE, WAIT_PASSWORD, WRONG_PASS, RIGHT_PASS, STOP);
    signal state, next_state : state_t;
begin
-- TODO
end architecture rtl;
