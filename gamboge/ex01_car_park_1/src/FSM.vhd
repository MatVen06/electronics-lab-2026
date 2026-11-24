library ieee;
use ieee.std_logic_1164.all;

entity FSM is
port( 
    clk        : in std_logic;
    reset_n    : in std_logic;
    front_sensor : in std_logic;
    back_sensor  : in std_logic;
    -- Status and control signals
    clock_10 : in std_logic; -- status signal from the datapath = 1 if 10 clock cycles have elapsed.
    clock_3 : in std_logic; -- Status signal, 3 clock cycles to blink.
    check_pswd : in std_logic; -- status signal (1 if password is correct).
    count_to_3 : out std_logic; -- control signal to start counting to 3.
    count_to_10 : out std_logic; -- control signal to start counting to 10.
    enable_green : out std_logic; -- control signal to enable green led
    enable_red : out std_logic; -- control signal to enable red led
    -- Displays encoded independently
    hex1_display : out std_logic_vector(2 downto 0); -- control signal left display
    hex2_display : out std_logic_vector(2 downto 0) -- control signal right display
);
end FSM;

architecture rtl of FSM is 
    type state_t is (IDLE, WAIT_PASSWORD, WRONG_PASS, RIGHT_PASS, STOP);
    signal state, next_state : state_t;
     
begin
    states : process (clk, reset_n) is  
    begin
        if (reset_n = '0') then
            state <= idle;
        elsif (rising_edge(clk)) then
            state <= next_state;
        end if;
    end process states;

    next_states : process (state, front_sensor, back_sensor, clock_10, clock_3, check_pswd) is
    begin
        next_state <= state;
        
        case state is
            when idle => 
                 if (front_sensor = '1') then
                    next_state <= wait_password;
                end if;
            when wait_password =>
                if (clock_10 = '1') then
                    if (check_pswd = '1') then
                        next_state <= right_pass;
                    elsif (check_pswd = '0') then
                        next_state <= wrong_pass;
                    end if;
                end if;
            when wrong_pass =>
                if (clock_3 = '1') then
                    next_state <= wait_password;
                end if;
            when right_pass =>
                if (clock_3 = '1') then
                    if (front_sensor = '0') then
                        next_state <= idle;
                    elsif (front_sensor = '1') then
                        if (back_sensor = '1') then
                            next_state <= stop;
                        elsif (back_sensor = '0') then
                            next_state <= wait_password;
                        end if;
                    end if;
                end if;
           when stop =>
                if (back_sensor = '0') then
                    next_state <= wait_password;
                end if;
            end case;
        end process next_states;


        outputs : process (state, next_state, clk) is
        begin
                enable_green <= '0';
                enable_red <= '0';
                hex1_display <= "000";
                hex2_display <= "000";
                -- Control signals for the datapath counters
                count_to_3 <= '0';
                count_to_10 <= '0';

            if (state = wait_password) then 
                if (state = next_state) then
                    count_to_10 <= '1';
                end if;
                enable_red <= '1';
                hex1_display <= "001"; -- E
                hex2_display <= "001"; -- n
            elsif (state = right_pass) then
                if (next_state = state) then  
                    count_to_3 <= '1';
                end if;
                enable_green <= clk; -- blink with clk
                hex1_display <= "011"; -- G
                hex2_display <= "101"; -- O
            elsif (state = wrong_pass) then
                if (next_state = state) then 
                    count_to_3 <= '1';
                end if;
                enable_red <= clk; -- blink with clk
                hex1_display <= "001"; -- E
                hex2_display <= "011"; -- E
            elsif (state = stop) then
                if (state = next_state) then
                    count_to_3 <= '1';
                end if;
                enable_red <= clk; -- blink with clk
                hex1_display <= "010"; -- S
                hex2_display <= "100"; -- P
            end if;
        end process outputs;
                
end architecture rtl;

