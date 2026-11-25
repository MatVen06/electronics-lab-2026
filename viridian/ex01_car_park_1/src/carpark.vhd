library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Car_Parking_System_VHDL is
    port(
        clk : in std_logic;
        reset_n : in std_logic; -- active low, asynchronous
        front_sensor: in std_logic;
        back_sensor : in std_logic;
        password_1 : in std_logic_vector(1 downto 0);
        password_2 : in std_logic_vector(1 downto 0);
        GREEN_LED : out std_logic;
        RED_LED : out std_logic;
        HEX_1 : out std_logic_vector(6 downto 0); -- segments gfedcba
        HEX_2 : out std_logic_vector(6 downto 0)
    );
end Car_Parking_System_VHDL;

architecture rtl of Car_Parking_System_VHDL is
    type FSM_States is (IDLE, WAIT_PASSWORD, WRONG_PASS, RIGHT_PASS, STOP);
    signal current_state, next_state : FSM_States;
    signal clk_counter : unsigned(3 downto 0);
    signal blink : std_logic;

    constant CHAR_E   : std_logic_vector(6 downto 0) := "0000110";
    constant CHAR_n   : std_logic_vector(6 downto 0) := "0101011";
    constant CHAR_G   : std_logic_vector(6 downto 0) := "0000010";
    constant CHAR_O   : std_logic_vector(6 downto 0) := "1000000";
    constant CHAR_S   : std_logic_vector(6 downto 0) := "0100100";
    constant CHAR_P   : std_logic_vector(6 downto 0) := "0001100";
    constant CHAR_OFF : std_logic_vector(6 downto 0) := "1111111";


begin

    clkandreset: process (clk, reset_n)
    begin
        if reset_n = '0' then
            current_state <= IDLE;
            clk_counter <= (others => '0');
            --blink <= '0';
        elsif rising_edge(clk) then
            current_state <= next_state;

            if current_state /= next_state then
                clk_counter <= (others => '0');
            elsif clk_counter < 9 then
                    clk_counter <= clk_counter + 1;
            end if;
        end if;
    end process clkandreset;

    state_processes: process(current_state, front_sensor, back_sensor, password_1, password_2, clk_counter)
    begin

        next_state <= current_state;
        GREEN_LED <= '0';
        RED_LED <= '0';
        HEX_1 <= CHAR_OFF;
        HEX_2<= CHAR_OFF;

        case current_state is 
            when IDLE =>
                if(front_sensor = '1') then
                    next_state <= WAIT_PASSWORD;
                end if;
            --Idle done

            when WAIT_PASSWORD =>
                RED_LED <= '1';
                HEX_1 <= CHAR_E;
                HEX_2<= CHAR_n;
                
                if clk_counter = 9 then
                    if (password_1 = "01" and password_2 = "10") then
                        next_state <= RIGHT_PASS;
                    else
                        next_state <= WRONG_PASS;
                    end if;
                end if;
            
            when RIGHT_PASS =>
                GREEN_LED <= clk_counter(0);
                HEX_1 <= CHAR_G;
                HEX_2 <= CHAR_O;

                if clk_counter >= 9 then    
                    if (front_sensor = '1' and back_sensor = '1') then
                        next_state <= STOP;
                    elsif back_sensor = '1' then
                        next_state <= IDLE;
                    end if;
                end if;
            
            when WRONG_PASS =>
                RED_LED <= clk_counter(0);
                HEX_1 <= CHAR_E;
                HEX_2 <= CHAR_E;

                if clk_counter >= 9 then
                    next_state <= WAIT_PASSWORD;
                end if;

            when STOP =>
                RED_LED <= '1';
                HEX_1 <= CHAR_S;
                HEX_2 <= CHAR_P;

                if (password_1 = "01" and password_2 = "10") then
                    next_state <= RIGHT_PASS;
                end if;
            end case;
        end process state_processes;
    end architecture rtl;
