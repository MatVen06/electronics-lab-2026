library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Car_Parking_System_VHDL is 

    port ( 
        clk : in std_logic; 
        reset_n : in std_logic;   -- active low, asynchronou
        front_sensor: in std_logic; 
        back_sensor : in std_logic; 
        password_1 : in std_logic_vector(1 downto 0); 
        password_2 : in std_logic_vector(1 downto 0); 

        GREEN_LED : out std_logic; 
        RED_LED : out std_logic; 
        HEX_1 : out std_logic_vector(6 downto 0);-- segments gfedcba 
        HEX_2 : out std_logic_vector(6 downto 0)

    );
end Car_Parking_System_VHDL;

architecture CPS of Car_Parking_System_VHDL is
    type t_State is (
        IDLE,
        WAIT_PASS,
        WRONG_PASS,
        RIGHT_PASS,
        STOP
    );

    signal current_state : t_State := IDLE; -- := - there must be no space between the colon and equals sign.
    signal next_state : t_State;

    signal Counter : integer range 0 to 9 := 0;
    
    signal  red_temp : std_logic;
    signal  green_temp : std_logic;
    signal  blink   :   std_logic   := '0';

begin 
    state_register   : process(reset_n,clk)
    begin
        if  reset_n = '0' then
            current_state  <= Idle;

        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process ;

    ---------FSM STATE------------
    FSM : process (current_state, front_sensor, back_sensor,
              password_1, password_2, Counter)
    begin

        --Default: remain in the current state
        next_state <= current_state ;
            
            case current_State is

                --STATE 1: IDLE
            when IDLE =>
                if front_sensor = '1' then
                next_state  <= wait_pass;
            end if;
            
            --STATE 2: WAIT_PASS
            when wait_pass=>
                if front_sensor = '0' then
                    next_state  <=IDLE;

                    elsif counter = 9 then
                        if password_1 = "01" and password_2 = "10" then
                            next_state  <= right_pass;
                        else
                            next_state  <=  wrong_pass;
                        end if;
                    end if;

                    --STATE 3: wrong_pass
                when wrong_pass =>
                    if counter = 9 then
                        next_state  <= wait_pass;
                    end if;

                    --STATE 4: right_pass
                when right_pass =>
                    if front_sensor = '1' and back_sensor ='1' then
                        next_state  <= stop;

                    elsif front_sensor ='0' and back_sensor ='1' then
                        next_state  <=idle;
                    end if;

                    --STATE 5:  STOP
                when stop =>
                    if back_sensor = '0' then
                        next_state  <= wait_pass;
                    end if;

                end case;

            end process FSM;

counter_process :   process(clk, reset_n )
begin
    if reset_n = '0' then
        counter <= 0;

    elsif   rising_edge(clk) then

        if  next_state  /= current_state then -- detects a state transition; the operator /= means not equal
            counter <= 0;
        
        elsif   current_state   = wait_pass or
                current_state   = wrong_pass then

                if counter  < 9 then
                    counter <= counter + 1;
                else
                    counter <= 0;
                end if;

            else
                counter <= 0;
            end if;
        end if;
    end process counter_process;

blink_process   :   process(clk,reset_n)
begin
    if reset_n  =   '0' then
        blink   <=  '0';

    elsif   rising_edge(clk)    then
        blink   <=  not blink; -- reverses the current value

    end if;
end process blink_process;

output_logic    :   process(current_state, blink)
begin

    --Default ouput: everything is OFF
    green_led   <=  '0';
    red_led     <=  '0';

    hex_1   <= "1111111";
    hex_2   <= "1111111";

    case    current_state is

        --STATE 1:  idle
    when idle   =>
        null;

        --STATE 2: wait_pass
    when    wait_pass   =>
        red_led     <='1';

        hex_1 <= "0000110"; -- E
        hex_2 <= "0101011"; -- n

        --STATE 3: WRONG_PASS
    when wrong_pass =>
        red_led <=  blink;

         HEX_1 <= "0000110"; -- E
        HEX_2 <= "0000110"; -- E

        --state 4: right_pass
    when right_pass =>
        green_led   <= blink;

        hex_1   <= "0000010"; -- G
        HEX_2 <= "1000000"; -- O

        --state 5:stop
    when stop =>
        red_led <= blink;

        HEX_1 <= "0100100"; -- S
        HEX_2 <= "0001100"; -- P

    end case;
end process output_logic;
end architecture CPS;