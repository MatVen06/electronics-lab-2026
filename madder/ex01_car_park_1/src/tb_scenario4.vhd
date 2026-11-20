library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_scenario4 is
end tb_scenario4;

architecture sim of tb_scenario4 is

    -- DUT signals
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

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

    -- Segment constants (from handout)
    constant SEG_OFF : std_logic_vector(6 downto 0) := "1111111";
    constant SEG_E   : std_logic_vector(6 downto 0) := "0000110";
    constant SEG_N   : std_logic_vector(6 downto 0) := "0101011";
    constant SEG_G   : std_logic_vector(6 downto 0) := "0000010";
    constant SEG_O   : std_logic_vector(6 downto 0) := "1000000";

begin

    -- Clock generation
    clk <= not clk after CLK_PERIOD / 2;

    -- DUT instantiation
    DUT : entity work.Car_Parking_System_VHDL
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

    -- Stimulus process
    stim_proc : process

        -- Helper procedure (VHDL-93 safe: no signal parameters)
        procedure check_idle(constant tag : in string) is
        begin
            assert GREEN_LED = '0'     report tag & ": GREEN_LED should be 0" severity error;
            assert RED_LED   = '0'     report tag & ": RED_LED should be 0"   severity error;
            assert HEX_1     = SEG_OFF report tag & ": HEX_1 should be OFF"   severity error;
            assert HEX_2     = SEG_OFF report tag & ": HEX_2 should be OFF"   severity error;
        end procedure;

    begin
        -- ------------------------------------------------------------
        -- Initial reset (reset_n = '0' -> IDLE)
        -- ------------------------------------------------------------
        reset_n      <= '0';
        front_sensor <= '0';
        back_sensor  <= '0';
        password_1   <= "00";
        password_2   <= "00";
        wait for 3 * CLK_PERIOD;

        reset_n <= '1';
        wait for 2 * CLK_PERIOD;
        check_idle("Initial IDLE");

        -- ============================================================
        -- Test A: Reset from WAIT_PASSWORD
        -- ============================================================
        report "=== Test A: reset from WAIT_PASSWORD ===" severity note;

        front_sensor <= '1';
        wait for 2 * CLK_PERIOD;

        assert RED_LED = '1' report "Test A: expected WAIT_PASSWORD (RED ON)" severity error;
        assert HEX_1 = SEG_E report "Test A: expected 'E' on HEX_1" severity error;
        assert HEX_2 = SEG_N report "Test A: expected 'n' on HEX_2" severity error;

        wait until falling_edge(clk);
        wait for CLK_PERIOD / 4;
        reset_n <= '0';
        wait for 1 ns; -- allow delta cycles to settle
        check_idle("Test A async reset");

        wait until rising_edge(clk);
        wait for CLK_PERIOD / 2;
        reset_n <= '1';
        front_sensor <= '0';
        wait for 2 * CLK_PERIOD;
        check_idle("Test A after release");

        -- ============================================================
        -- Test B: Reset from WRONG_PASS
        -- ============================================================
        report "=== Test B: reset from WRONG_PASS ===" severity note;

        front_sensor <= '1';
        -- Keep passwords wrong during the 10-cycle window
        password_1 <= "00";
        password_2 <= "00";
        wait for 12 * CLK_PERIOD;     
        assert HEX_1 = SEG_E and HEX_2 = SEG_E
            report "Test B: expected WRONG_PASS ('EE')" severity error;

        wait until falling_edge(clk);
        wait for CLK_PERIOD / 4;
        reset_n <= '0';
        wait for 1 ns;
        check_idle("Test B async reset");

        wait until rising_edge(clk);
        wait for CLK_PERIOD / 2;
        reset_n <= '1';
        front_sensor <= '0';
        wait for 2 * CLK_PERIOD;
        check_idle("Test B after release");

        -- ============================================================
        -- Test C: Reset from RIGHT_PASS
        -- ============================================================
        report "=== Test C: reset from RIGHT_PASS ===" severity note;

        front_sensor <= '1';
        password_1 <= "01";
        password_2 <= "10";
        wait for 12 * CLK_PERIOD;

        assert HEX_1 = SEG_G and HEX_2 = SEG_O
            report "Test C: expected RIGHT_PASS ('GO')" severity error;

        wait until falling_edge(clk);
        wait for CLK_PERIOD / 4;
        reset_n <= '0';
        wait for 1 ns;
        check_idle("Test C async reset");

        wait until rising_edge(clk);
        wait for CLK_PERIOD / 2;
        reset_n <= '1';
        front_sensor <= '0';
        password_1 <= "00";
        password_2 <= "00";
        wait for 2 * CLK_PERIOD;
        check_idle("Test C after release");

        -- ============================================================
        -- Test D: Reset from STOP
        -- ============================================================
        report "=== Test D: reset from STOP ===" severity note;

        front_sensor <= '1';
        password_1 <= "01";
        password_2 <= "10";
        wait for 12 * CLK_PERIOD;
        assert HEX_1 = SEG_G and HEX_2 = SEG_O
            report "Test D: expected RIGHT_PASS before STOP" severity error;

        back_sensor <= '1';
        wait for 2 * CLK_PERIOD;
        assert HEX_1 = "0100100" and HEX_2 = "0001100"
            report "Test D: expected STOP ('SP')" severity error;

        wait until falling_edge(clk);
        wait for CLK_PERIOD / 4;
        reset_n <= '0';
        wait for 1 ns;
        check_idle("Test D async reset");

        wait until rising_edge(clk);
        wait for CLK_PERIOD / 2;
        reset_n <= '1';
        front_sensor <= '0';
        back_sensor  <= '0';
        password_1 <= "00";
        password_2 <= "00";
        wait for 2 * CLK_PERIOD;
        check_idle("Test D after release");

        -- ------------------------------------------------------------
        -- End simulation
        -- ------------------------------------------------------------
        report "Scenario 4 testbench completed successfully." severity note;
        assert false report "Simulation finished" severity failure;
        wait;
    end process;

end sim;
