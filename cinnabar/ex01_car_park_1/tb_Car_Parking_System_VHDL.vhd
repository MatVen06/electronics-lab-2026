library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Car_Parking_System_VHDL is

end tb_Car_Parking_System_VHDL;

architecture Behavior of tb_Car_Parking_System_VHDL is

    component Car_Parking_System_VHDL
        port(
            clk          : in  std_logic;
            reset_n      : in  std_logic;
            front_sensor : in  std_logic;
            back_sensor  : in  std_logic;
            password_1   : in  std_logic_vector(1 downto 0);
            password_2   : in  std_logic_vector(1 downto 0);
            GREEN_LED    : out std_logic;
            RED_LED      : out std_logic;
            HEX_1        : out std_logic_vector(6 downto 0);
            HEX_2        : out std_logic_vector(6 downto 0)
        );
    end component;

    signal clk          : std_logic := '0';
    signal reset_n      : std_logic := '0';
    signal front_sensor : std_logic := '0';
    signal back_sensor  : std_logic := '0';
    signal password_1   : std_logic_vector(1 downto 0) := "00";
    signal password_2   : std_logic_vector(1 downto 0) := "00";

    signal GREEN_LED    : std_logic;
    signal RED_LED      : std_logic;
    signal HEX_1        : std_logic_vector(6 downto 0);
    signal HEX_2        : std_logic_vector(6 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    uut: Car_Parking_System_VHDL port map (
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

    clk_process :process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
    begin
        -- initialization
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';
        wait for 20 ns;

        -- Scenario 1 normal entry
        front_sensor <= '1';
        password_1 <= "01";
        password_2 <= "10";
        wait for 12 * CLK_PERIOD;

        assert (HEX_1 = "1000000" and HEX_2 = "0000010") report "Displays should show GO after correct password" severity error;
        
        front_sensor <= '0';
        wait for 10 ns;
        back_sensor <= '1';
        wait for 20 ns;
        back_sensor <= '0';
        wait for 20 ns;

        -- Scenario 2 wrong password
        front_sensor <= '1';
        password_1 <= "00";
        password_2 <= "00";
        wait for 12 * CLK_PERIOD;

        assert (HEX_1 = "0000110" and HEX_2 = "0000110") report "Displays should show EE after wrong password" severity error;

        password_1 <= "01";
        password_2 <= "10";
        wait for 20 ns;

        assert (HEX_1 = "1000000" and HEX_2 = "0000010") report "Displays should show GO after correct password" severity error;

        front_sensor <= '0';
        wait for 10 ns;
        back_sensor <= '1';
        wait for 20 ns;
        back_sensor <= '0';
        wait for 20 ns;

        -- Scenario 3 multiple cars
        front_sensor <= '1';
        password_1 <= "01";
        password_2 <= "10";
        wait for 12 * CLK_PERIOD;

        password_1 <= "00";
        password_2 <= "00";
        back_sensor <= '1';
        wait for 10 ns;

        assert (HEX_1 = "0001100" and HEX_2 = "0100100") report "Displays should show SP in STOP state" severity error;
        
        password_1 <= "01";
        password_2 <= "10";
        wait for 20 ns;

        assert (HEX_1 = "1000000" and HEX_2 = "0000010") report "Displays should show GO after second correct password" severity error;

        front_sensor <= '0';
        back_sensor <= '1';
        wait for 20 ns;
        back_sensor <= '0';
        wait for 20 ns;

        -- Scenario 4 reset
        front_sensor <= '1';
        password_1 <= "00";
        password_2 <= "00";
        wait for 5 * CLK_PERIOD;
        reset_n <= '0';
        wait for 20 ns;
        assert (GREEN_LED = '0' and RED_LED = '0') report "LEDs should be OFF after reset" severity error;

        assert (HEX_1 = "1111111" and HEX_2 = "1111111") report "Displays should be OFF after reset" severity error;
        
        reset_n <= '1';

        report "Testbench completed successfully" severity note;
        wait;
    end process;

end Behavior;
