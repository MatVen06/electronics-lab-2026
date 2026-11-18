
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.env.all;

entity car_parking_tb is
end car_parking_tb;

architecture simulation of car_parking_tb is

    -- Signals connected to the parking system
    signal clk         : std_logic := '0';
    signal reset_n     : std_logic := '1';
    signal front_sensor: std_logic := '0';
    signal back_sensor : std_logic := '0';

    signal password_1  : std_logic_vector(1 downto 0) := "00";
    signal password_2  : std_logic_vector(1 downto 0) := "00";

    signal GREEN_LED   : std_logic;
    signal RED_LED     : std_logic;
    signal HEX_1       : std_logic_vector(6 downto 0);
    signal HEX_2       : std_logic_vector(6 downto 0);

begin

    -- Instantiate the design under test (DUT)
    DUT: entity work.Car_Parking_System_VHDL
        port map (
            clk          => clk,
            reset_n      => reset_n,
            front_sensor => front_sensor,
            back_sensor  => back_sensor,
            password_1   => password_1,
            password_2   => password_2,
            GREEN_LED    => GREEN_LED,
            RED_LED      => RED_LED,
            HEX_1        => HEX_1,
            HEX_2        => HEX_2
        );

    -- Clock generation: 10 ns period
    clk_process: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- Input stimulus
    stimulus_process: process
    begin

        -- Initial reset
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';
        wait for 10 ns;

        ------------------------------------------------
        -- SCENARIO 1: Correct password
        ------------------------------------------------
        front_sensor <= '1';
        password_1 <= "01";
        password_2 <= "10";

        -- Wait for 10 clock cycles
        for i in 1 to 15 loop
            wait until rising_edge(clk);
        end loop;

        -- Car leaves
        back_sensor <= '1';
        front_sensor <= '0';
        wait for 30 ns;

         back_sensor <= '0';
        front_sensor <= '0';
        reset_n <= '0';

        wait for 20 ns;

        ------------------------------------------------
        -- SCENARIO 2: Wrong password, then retry
        ------------------------------------------------
        reset_n <= '1';

        back_sensor <= '0';
        front_sensor <= '1';
        password_1 <= "00";
        password_2 <= "00";

        -- Wait for 10 clock cycles
        for i in 1 to 15 loop
            wait until rising_edge(clk);
        end loop;

        -- Supply the correct password for retry
        password_1 <= "01";
        password_2 <= "10";

        wait for 200 ns;

         back_sensor <= '0';
        front_sensor <= '0';
        
        reset_n <= '0';

        wait for 20 ns;
                



        ------------------------------------------------
        -- SCENARIO 3: A second car arrives
        ------------------------------------------------
        reset_n <= '1';

        front_sensor <= '1';
        password_1 <= "01";
        password_2 <= "10";

        wait for 150 ns;

        back_sensor <= '1';
        wait for 50 ns;

        back_sensor <= '0';

        wait for 150 ns;
        front_sensor<='0';
        reset_n <= '0';

        wait for 20 ns;

        

        ------------------------------------------------
        -- SCENARIO 4: Reset during operation
        ------------------------------------------------
        reset_n <= '1';

        front_sensor <= '1';
        wait for 20 ns;

        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';

        wait for 20 ns;

        -- End simulation
        report "Simulation finished" severity note;
        finish;

    end process;

end simulation;
