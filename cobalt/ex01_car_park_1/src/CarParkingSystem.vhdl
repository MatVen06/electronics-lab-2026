library ieee;
use ieee.std_logic_1164.all;

entity Car_Parking_System_VHDL is
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;   -- active low, asynchronous
        front_sensor : in  std_logic;
        back_sensor  : in  std_logic;
        password_1   : in  std_logic_vector(1 downto 0);
        password_2   : in  std_logic_vector(1 downto 0);
        GREEN_LED    : out std_logic;
        RED_LED      : out std_logic;
        HEX_1        : out std_logic_vector(6 downto 0); -- segments gfedcba
        HEX_2        : out std_logic_vector(6 downto 0)
    );
end Car_Parking_System_VHDL;

architecture Car_Park of Car_Parking_System_VHDL is
    type   state_t is (S_IDLE, S_WAIT_PASSWORD, S_WRONG_PASSWORD, S_RIGHT_PASSWORD, S_STOP);
    signal state   : state_t;
    signal counter : integer range 0 to 9;

    -- Correct password
    constant CORRECT_PASSWORD_1 : std_logic_vector(1 downto 0) := "01";
    constant CORRECT_PASSWORD_2 : std_logic_vector(1 downto 0) := "10";
    constant DISPLAY_E          : std_logic_vector(6 downto 0) := "0000110";
    constant DISPLAY_N          : std_logic_vector(6 downto 0) := "0101011";
    constant DISPLAY_G          : std_logic_vector(6 downto 0) := "0000010";
    constant DISPLAY_O          : std_logic_vector(6 downto 0) := "1000000";
    constant DISPLAY_S          : std_logic_vector(6 downto 0) := "0100100";
    constant DISPLAY_P          : std_logic_vector(6 downto 0) := "0001100";
    constant DISPLAY_OFF        : std_logic_vector(6 downto 0) := "1111111";

begin
    clock : process(clk, reset_n) is
    begin
        -- Asynchronous, active-low reset
        if reset_n = '0' then
            state     <= S_IDLE;
            counter   <= 0;
            GREEN_LED <= '0';
            RED_LED   <= '0';
            HEX_1     <= DISPLAY_OFF;
            HEX_2     <= DISPLAY_OFF;
        elsif rising_edge(clk) then
            case state is
                when S_IDLE =>
                    -- LED's off
                    GREEN_LED <= '0';
                    RED_LED   <= '0';

                    HEX_1 <= DISPLAY_OFF;
                    HEX_2 <= DISPLAY_OFF;

                    -- If front sensor detects car then go wait for password
                    if front_sensor = '1' then
                        counter <= 0;
                        state   <= S_WAIT_PASSWORD;
                    end if;

                when S_WAIT_PASSWORD =>
                    -- Green LED off
                    GREEN_LED <= '0';

                    -- Red LED on steady
                    RED_LED <= '1';

                    HEX_1 <= DISPLAY_E;
                    HEX_2 <= DISPLAY_N;

                    -- Check for password after 10 clock cycles
                    if counter = 9 then
                        if password_1 = CORRECT_PASSWORD_1 and password_2 = CORRECT_PASSWORD_2 then
                            state <= S_RIGHT_PASSWORD;
                        else
                            state <= S_WRONG_PASSWORD;
                        end if;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;

                when S_WRONG_PASSWORD =>
                    -- Green LED off
                    GREEN_LED <= '0';

                    -- Red LED blinks
                    if counter mod 2 = 0 then
                        RED_LED <= '1';
                    else
                        RED_LED <= '0';
                    end if;

                    HEX_1 <= DISPLAY_E;
                    HEX_2 <= DISPLAY_E;

                    -- Wait 5 clock cycles then go back to waiting for password
                    if counter = 4 then
                        counter <= 0;
                        state   <= S_WAIT_PASSWORD;
                    else
                        counter <= counter + 1;
                    end if;

                when S_RIGHT_PASSWORD =>
                    -- Red LED off
                    RED_LED <= '0';

                    -- Green LED blinks
                    if counter mod 2 = 0 then
                        GREEN_LED <= '1';
                    else
                        GREEN_LED <= '0';
                    end if;

                    HEX_1 <= DISPLAY_G;
                    HEX_2 <= DISPLAY_O;

                    -- Add to counter every cycle for the blinking LED
                    if counter = 9 then
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;

                    -- If both sensors are on at the same time go to stop
                    if front_sensor = '1' and back_sensor = '1' then
                        counter <= 0;
                        state   <= S_STOP;

                    -- If the car reaches the back sensor (and no second car is waiting) go to idle
                    elsif back_sensor = '1' then
                        state <= S_IDLE;
                    end if;

                when S_STOP =>
                    -- Green LED off
                    GREEN_LED <= '0';

                    -- Red LED blinks
                    if counter mod 2 = 0 then
                        RED_LED <= '1';
                    else
                        RED_LED <= '0';
                    end if;

                    --Display says 'SP'
                    HEX_1 <= DISPLAY_S;
                    HEX_2 <= DISPLAY_P;

                    -- When back sensor turns off then we can go wait for the password of the next car
                    if back_sensor = '0' then
                        counter <= 0;
                        state   <= S_WAIT_PASSWORD;
                    else
                        counter <= counter + 1;
                    end if;
            end case;
        end if;
    end process;
end architecture Car_Park;
