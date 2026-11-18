library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end entity;

architecture simulation of testbench is

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

begin

    -- Device Under Test
    DUT : entity work.Car_parking_system_VHDL
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

    -- Clock: 10 ns period
    clk <= not clk after 5 ns;

    stimulus : process
    begin

        -- Initial state-- Idle
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';

        -- Scenario 1: Car arrives
        wait for 10 ns;
        front_sensor <= '1';

        -- Enter correct password
        wait for 100 ns;
        password_1 <= "10";
        password_2 <= "01";

        -- Wait for password timeout
        wait for 10 ns;

        -- Car enters
        back_sensor <= '1';
        wait for 30 ns;

        -- Car leaves
        front_sensor <= '0';
        back_sensor <= '0';
        wait for 70 ns;

        -- Scenario 2: Car arrives with wrong password
        front_sensor <= '1';
        password_1 <= "00";
        password_2 <= "11";

        wait for 150 ns;

        -- Scenario 3: Reset
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';

        wait;
    end process;

end architecture;
