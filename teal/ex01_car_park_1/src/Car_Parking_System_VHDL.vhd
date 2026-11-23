library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Car_Parking_System_VHDL is 
generic(
    ClockFrequencyHz : integer := 50000000;
    BlinkDivider     : integer := 2
);
port( 
    clk          : in std_logic;
    reset_n      : in std_logic; -- Active low
    front_sensor : in std_logic;
    back_sensor  : in std_logic;
    password_1   : in std_logic_vector(1 downto 0);
    password_2   : in std_logic_vector(1 downto 0);
    GREEN_LED    : out std_logic;
    RED_LED      : out std_logic;
    HEX_1        : out std_logic_vector(6 downto 0); 
    HEX_2        : out std_logic_vector(6 downto 0)
);
end Car_Parking_System_VHDL;

architecture arch of Car_Parking_System_VHDL is

    -- State declarations
    type FSM_States is (IDLE, WAIT_PASSWORD, WRONG_PASS, RIGHT_PASS, STOP);
    signal current_state : FSM_States := IDLE;

    -- Counter for state delay
    signal counter_wait : std_logic_vector(3 downto 0) := "0000";

    -- Internal blink / flicker generation
    signal blink_counter : integer range 0 to 100000000 := 0;
    signal blink_toggle  : std_logic := '0';
    signal en_green_led  : std_logic := '0';
    signal en_red_led    : std_logic := '0';

    function is_pass_correct(pw1 : std_logic_vector(1 downto 0); pw2 : std_logic_vector(1 downto 0)) return boolean is
    begin
        if(pw1="01" and pw2="10") then
            return true;
        else
            return false;
        end if;
    end function;

begin

    -- Blink toggle generator (replaces external prescaler and led_block)
    process(clk, reset_n) is
    begin
        if reset_n = '0' then
            blink_counter <= 0;
            blink_toggle <= '0';
        elsif rising_edge(clk) then
            if blink_counter >= (BlinkDivider - 1) then
                blink_counter <= 0;
                blink_toggle <= not blink_toggle;
            else
                blink_counter <= blink_counter + 1;
            end if;
        end if;
    end process;

    -- Main FSM and output process
    process(clk, reset_n) is
    begin
        if(reset_n='0') then
            current_state <= IDLE;
            counter_wait <= "0000";
            HEX_1 <= "1111111"; -- off
            HEX_2 <= "1111111"; -- off
            GREEN_LED <= '0';
            RED_LED <= '0';
            en_green_led <= '0';
            en_red_led <= '0';
        elsif(rising_edge(clk)) then
            -- Defaults
            HEX_1 <= "1111111"; -- off
            HEX_2 <= "1111111"; -- off
            GREEN_LED <= '0';
            RED_LED <= '0';
            en_green_led <= '0';
            en_red_led <= '0';

            case current_state is
                -- IDLE state
                when IDLE =>
                    if front_sensor = '1' then
                        current_state <= WAIT_PASSWORD;
                    end if;

                -- WAIT_PASSWORD (RED LED steady on, display 'En')
                when WAIT_PASSWORD =>
                    RED_LED <= '1';
                    HEX_1 <= "0000110"; -- E
                    HEX_2 <= "0101011"; -- n 
                    if unsigned(counter_wait) >= 9 then
                        counter_wait <= "0000";
                        if (is_pass_correct(password_1, password_2)) then
                            current_state <= RIGHT_PASS;
                        else
                            current_state <= WRONG_PASS;
                        end if;
                    else
                        counter_wait <= std_logic_vector(unsigned(counter_wait) + 1);
                    end if;

                -- WRONG_PASS (RED LED blinks, display 'EE')
                when WRONG_PASS =>
                    en_red_led <= '1';
                    RED_LED <= blink_toggle;
                    HEX_1 <= "0000110"; -- E
                    HEX_2 <= "0000110"; -- E 
                    if unsigned(counter_wait) >= 9 then
                        counter_wait <= "0000";
                        if (is_pass_correct(password_1, password_2)) then
                            current_state <= RIGHT_PASS;
                        else
                            current_state <= WRONG_PASS;
                        end if;
                    else
                        counter_wait <= std_logic_vector(unsigned(counter_wait) + 1);
                    end if;

                -- RIGHT_PASS (GREEN LED blinks, display 'GO')
                when RIGHT_PASS =>
                    en_green_led <= '1';
                    GREEN_LED <= blink_toggle;
                    HEX_1 <= "0000010"; -- 6
                    HEX_2 <= "1000000"; -- O 
                    if back_sensor = '1' then
                        if front_sensor = '0' then
                            -- car has passed through
                            current_state <= IDLE;
                        else
                            -- queue
                            current_state <= STOP;
                        end if;
                    else
                        if front_sensor = '0' then
                            current_state <= IDLE;
                        end if;
                    end if;

                -- STOP (RED LED blinks, display 'SP')
                when STOP =>
                    en_red_led <= '1';
                    RED_LED <= blink_toggle;
                    HEX_1 <= "0100100"; -- S
                    HEX_2 <= "0001100"; -- P
                    if unsigned(counter_wait) >= 9 then
                        counter_wait <= "0000";
                        current_state <= IDLE;
                    else
                        counter_wait <= std_logic_vector(unsigned(counter_wait) + 1);
                    end if;

                when others =>
                    current_state <= IDLE;
            end case;
        end if;
    end process;

end arch;
