library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end entity;

architecture simulation of testbench is

    -- Signals for DUT
    signal clk : std_logic := '0';
    signal reset_n : std_logic := '1';
    signal front_sensor : std_logic := '0';
    signal back_sensor : std_logic := '0';
    signal password_1 : std_logic_vector(1 downto 0) := "00";
    signal password_2 : std_logic_vector(1 downto 0) := "00";

    signal GREEN_LED : std_logic;
    signal RED_LED : std_logic;
    signal HEX_1 : std_logic_vector(6 downto 0);
    signal HEX_2 : std_logic_vector(6 downto 0);

    constant clock_period : time := 10 ns;

begin

    -- Device Under Test (DUT)
    DUT : entity work.Car_Parking_System_VHDL
        port map (
            clk => clk,
            reset_n => reset_n,
            front_sensor => front_sensor,
            back_sensor => back_sensor,
            password_1 => password_1,
            password_2 => password_2,
            GREEN_LED => GREEN_LED,
            RED_LED => RED_LED,
            HEX_1 => HEX_1,
            HEX_2 => HEX_2
        );

    -- Clock generation: 10 ns period (100 MHz)
    clk <= not clk after clock_period / 2;

    -- Stimulus process
    stimulus : process
    begin

        -- Initial conditions
        reset_n <= '0';
        front_sensor <= '0';
        back_sensor <= '0';
        password_1 <= "00";
        password_2 <= "00";

        wait for clock_period * 2;
        reset_n <= '1';
        wait for clock_period;

        -------------------------------------------------------------
        -- SCENARIO 1: Successful Parking (Right Password)
        -------------------------------------------------------------
        report "--- Starting Scenario 1: Successful Parking ---";

        -- 1. Car arrives at the front sensor
        front_sensor <= '1';
        wait for 2 * clock_period; -- Enters S_WAIT_PASS, counter resets to 0

        -- 2. Enter correct password BEFORE counter reaches 10
        password_1 <= "10";
        password_2 <= "01";

        -- 3. Wait for timer to reach 10 so it evaluates and transitions to S_RIGHT_PASS
        wait for 9 * clock_period; 

        -- 4. Car passes through the sensors (clear front, activate back briefly)
        front_sensor <= '0';
        wait for clock_period;
        back_sensor <= '1';
        wait for 3 * clock_period;

        -- 5. Clear sensors and wait for S_RIGHT_PASS timer (>5 cycles) to return to S_IDLE
        back_sensor <= '0';
        wait for 7 * clock_period; 

        -- Reset passwords for next scenario
        password_1 <= "00";
        password_2 <= "00";
        wait for 5 * clock_period;

        -------------------------------------------------------------
        -- SCENARIO 2: Wrong Password Handling
        -------------------------------------------------------------
        report "--- Starting Scenario 2: Wrong Password ---";

        -- 1. Car arrives again
        front_sensor <= '1';
        wait for 2 * clock_period;

        -- 2. Enter incorrect password ("00" or anything other than 10/01)
        password_1 <= "00";
        password_2 <= "00";

        -- 3. Wait for timer to reach 10 -> triggers S_WRONG_PASS
        wait for 9 * clock_period;

        -- 4. Observe blinking red LED in S_WRONG_PASS for a few cycles (> 5 cycles)
        wait for 7 * clock_period;

        -- 5. Clear sensor to reset system cleanly
        front_sensor <= '0';
        wait for 10 * clock_period;

        report "--- Simulation Finished Successfully ---";

        -------------------------------------------------------------
        -- SCENARIO 3: Multiple cars
        -------------------------------------------------------------
        wait;

    end process;

end architecture;