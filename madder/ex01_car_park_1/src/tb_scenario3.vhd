library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_scenario3 is
end entity tb_scenario3;

architecture sim of tb_scenario3 is

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

    -- Stimulus signals
    signal clk         : std_logic := '0';
    signal reset_n     : std_logic := '0';
    signal front_sens  : std_logic := '0';
    signal back_sens   : std_logic := '0';
    signal pass_1      : std_logic_vector(1 downto 0) := "00";
    signal pass_2      : std_logic_vector(1 downto 0) := "00";

    -- Output monitoring signals
    signal green_led_s : std_logic;
    signal red_led_s   : std_logic;
    signal hex1_s      : std_logic_vector(6 downto 0);
    signal hex2_s      : std_logic_vector(6 downto 0);

    constant clk_period : time := 10 ns;

    -- Display verification constants
    constant SEG_OFF : std_logic_vector(6 downto 0) := "1111111";
    constant SEG_E   : std_logic_vector(6 downto 0) := "0000110";
    constant SEG_N   : std_logic_vector(6 downto 0) := "0101011";
    constant SEG_G   : std_logic_vector(6 downto 0) := "0000010";
    constant SEG_O   : std_logic_vector(6 downto 0) := "1000000";
    constant SEG_S   : std_logic_vector(6 downto 0) := "0100100";
    constant SEG_P   : std_logic_vector(6 downto 0) := "0001100";

begin

    -- Unit Under Test (UUT) instantiation
    UUT: Car_Parking_System_VHDL
    port map (
        clk          => clk,
        reset_n      => reset_n,
        front_sensor => front_sens,
        back_sensor  => back_sens,
        password_1   => pass_1,
        password_2   => pass_2,
        GREEN_LED    => green_led_s,
        RED_LED      => red_led_s,
        HEX_1        => hex1_s,
        HEX_2        => hex2_s
    );

    -- Clock generation process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initial reset
        reset_n    <= '0';
        front_sens <= '0';
        back_sens  <= '0';
        pass_1     <= "00";
        pass_2     <= "00";
        wait for clk_period * 2;
        reset_n    <= '1';
        wait for clk_period * 2;

        report "--- START SCENARIO 3: Multiple Cars Waiting (STOP) ---";

        -- 1. Car 1 arrives at front_sensor -> enters WAIT_PASSWORD
        front_sens <= '1';
        back_sens  <= '0';
        wait for clk_period;

        -- Clear password at the start of WAIT_PASSWORD
        pass_1 <= "00";
        pass_2 <= "00";

        -- Car 1 enters the correct password while in WAIT_PASSWORD
        wait for clk_period * 4;
        pass_1 <= "01";
        pass_2 <= "10";
        wait for clk_period * 7;

        -- 2. Verify RIGHT_PASS ("GO") for Car 1
        assert (hex1_s = SEG_G and hex2_s = SEG_O)
            report "Error: Car 1 did not transition to RIGHT_PASS (GO)" severity error;

        -- Car 1 begins driving through the gate
        wait for clk_period * 3;

        -- 3. Car 1 reaches back_sensor WHILE Car 2 is already at front_sensor
        front_sens <= '1';
        back_sens  <= '1';
        wait for clk_period * 2;

        -- 4. Verify STOP state ("SP")
        assert (hex1_s = SEG_S and hex2_s = SEG_P)
            report "Error: System did not enter STOP state (SP)" severity error;

        -- Keep STOP visible while Car 1 finishes clearing the gate
        wait for clk_period * 4;

        -- 5. Car 1 clears back_sensor (Car 2 remains waiting at front_sensor)
        back_sens <= '0';
        wait for clk_period;

        -- Clear previous password as soon as WAIT_PASSWORD starts for Car 2
        pass_1 <= "00";
        pass_2 <= "00";

        assert (hex1_s = SEG_E and hex2_s = SEG_N)
            report "Error: System did not enter WAIT_PASSWORD (EN) for Car 2" severity error;

        -- 6. Car 2 enters the correct password while in WAIT_PASSWORD
        wait for clk_period * 4;
        pass_1 <= "01";
        pass_2 <= "10";
        wait for clk_period * 7;

        -- 7. Verify RIGHT_PASS ("GO") for Car 2
        assert (hex1_s = SEG_G and hex2_s = SEG_O)
            report "Error: Car 2 did not transition to RIGHT_PASS (GO)" severity error;

        -- 8. Car 2 passes through and clears both sensors -> returns to IDLE
        wait for clk_period * 3;
        front_sens <= '0';
        wait for clk_period * 2;
        back_sens  <= '1';
        wait for clk_period * 2;
        back_sens  <= '0';
        pass_1     <= "00";
        pass_2     <= "00";
        wait for clk_period * 3;

        assert (hex1_s = SEG_OFF and hex2_s = SEG_OFF)
            report "Error: System did not return to IDLE" severity error;

        report "--- SCENARIO 3 COMPLETED ---";
        wait;
    end process;

end architecture sim;