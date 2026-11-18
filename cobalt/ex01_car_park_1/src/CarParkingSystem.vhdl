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

begin
    clock : process(clk, reset_n) is
    begin
        -- Asynchronous, active-low reset
        if reset_n = '0' then
            state   <= S_IDLE;
            counter <= 0;
        elsif rising_edge(clk) then
            case state is
                when S_IDLE =>
                    --TODO LEDs and display OFF

                    -- If front sensor detects car then go wait for password
                    if front_sensor = '1' then
                        state <= S_WAIT_PASSWORD;
                    end if;
                when S_WAIT_PASSWORD =>
                    --TODO Red LED ON steady, display says "En"

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
                    --TODO Red LED blinks, display says "EE"

                    -- Wait 5 clock cycles then go back to waiting for password
                    if counter = 4 then
                        state   <= S_WAIT_PASSWORD;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                when S_RIGHT_PASSWORD =>
                    --TODO Green LED blinks, display says "GO"

                    -- If both sensors are on at the same time go to stop
                    if front_sensor = '1' and back_sensor = '1' then
                        state <= S_STOP;

                    -- If the car reaches the back sensor (and no second car is waiting) go to idle
                    elsif back_sensor = '1' then
                        state <= S_IDLE;
                    end if;
                when S_STOP =>
                    --TODO Red LED blinks, display says "SP"

                    -- When back sensor turns off then we can go wait for the password of the next car
                    if back_sensor = '0' then
                        state <= S_WAIT_PASSWORD;
                    end if;
            end case;
        end if;
    end process;
end architecture Car_Park;
