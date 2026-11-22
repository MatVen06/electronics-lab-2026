library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_scenario4 is
end entity tb_scenario4;

architecture sim of tb_scenario4 is

    -- Component declaration (matches cp1testbench and tb_scenario1 for consistent VaporView hierarchy)
    component Car_Parking_System_VHDL
        port (
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
    signal clk          : std_logic := '0';
    signal reset_n      : std_logic := '0';
    signal front_sensor : std_logic := '0';
    signal back_sensor  : std_logic := '0';
    signal password_1   : std_logic_vector(1 downto 0) := "00";
    signal password_2   : std_logic_vector(1 downto 0) := "00";

    -- Output monitoring signals
    signal GREEN_LED    : std_logic;
    signal RED_LED      : std_logic;
    signal HEX_1        : std_logic_vector(6 downto 0);
    signal HEX_2        : std_logic_vector(6 downto 0);

    -- Clock period and clean simulation stop flag
    constant CLK_PERIOD : time := 10 ns;
    signal sim_done     : boolean := false;

    -- Expected 7-segment display constants (active low)
    constant SEG_OFF : std_logic_vector(6 downto 0) := "1111111";
    constant SEG_E   : std_logic_vector(6 downto 0) := "0000110";
    constant SEG_N   : std_logic_vector(6 downto 0) := "0101011";
    constant SEG_G   : std_logic_vector(6 downto 0) := "0000010";
    constant SEG_O   : std_logic_vector(6 downto 0) := "1000000";
    constant SEG_S   : std_logic_vector(6 downto 0) := "0100100";
    constant SEG_P   : std_logic_vector(6 downto 0) := "0001100";

begin

    -- Unit Under Test (UUT) instantiation
    UUT : Car_Parking_System_VHDL
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

    -- Clock generation process (stops cleanly when sim_done is true)
    clk_process : process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc : process

        -- Helper procedure to verify IDLE state outputs
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
        -- Test A: Asynchronous reset from WAIT_PASSWORD
        -- ============================================================
        report "=== Test A: reset from WAIT_PASSWORD ===" severity note;

        front_sensor <= '1';
        wait for 2 * CLK_PERIOD;

        assert RED_LED   = '1'   report "Test A: expected WAIT_PASSWORD (RED ON)"  severity error;
        assert GREEN_LED = '0'   report "Test A: expected WAIT_PASSWORD (GREEN OFF)" severity error;
        assert HEX_1     = SEG_E report "Test A: expected 'E' on HEX_1"            severity error;
        assert HEX_2     = SEG_N report "Test A: expected 'n' on HEX_2"            severity error;

        -- Assert reset asynchronously away from rising_edge(clk)
        wait until falling_edge(clk);
        wait for CLK_PERIOD / 4;
        reset_n <= '0';
        wait for 1 ns; -- allow delta cycles to settle
        check_idle("Test A async reset");

        -- Clear inputs while reset is still active, then release reset on falling edge
        front_sensor <= '0';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        reset_n <= '1';
        wait for 2 * CLK_PERIOD;
        check_idle("Test A after release");

        -- ============================================================
        -- Test B: Asynchronous reset from WRONG_PASS
        -- ============================================================
        report "=== Test B: reset from WRONG_PASS ===" severity note;

        front_sensor <= '1';
        password_1   <= "00";
        password_2   <= "00";
        -- Wait 13 cycles: 1 (IDLE->WAIT_PASSWORD) + 10 (counter 0..10) + 1 (transition) + 1 margin
        wait for 13 * CLK_PERIOD;

        assert HEX_1 = SEG_E and HEX_2 = SEG_E
            report "Test B: expected WRONG_PASS ('EE')" severity error;
        assert GREEN_LED = '0'
            report "Test B: expected GREEN_LED OFF in WRONG_PASS" severity error;

        -- Assert reset asynchronously
        wait until falling_edge(clk);
        wait for CLK_PERIOD / 4;
        reset_n <= '0';
        wait for 1 ns;
        check_idle("Test B async reset");

        -- Clear inputs while reset is still active, then release reset
        front_sensor <= '0';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        reset_n <= '1';
        wait for 2 * CLK_PERIOD;
        check_idle("Test B after release");

        -- ============================================================
        -- Test C: Asynchronous reset from RIGHT_PASS
        -- ============================================================
        report "=== Test C: reset from RIGHT_PASS ===" severity note;

        front_sensor <= '1';
        password_1   <= "01";
        password_2   <= "10";
        wait for 13 * CLK_PERIOD;

        assert HEX_1 = SEG_G and HEX_2 = SEG_O
            report "Test C: expected RIGHT_PASS ('GO')" severity error;
        assert RED_LED = '0'
            report "Test C: expected RED_LED OFF in RIGHT_PASS" severity error;

        -- Assert reset asynchronously
        wait until falling_edge(clk);
        wait for CLK_PERIOD / 4;
        reset_n <= '0';
        wait for 1 ns;
        check_idle("Test C async reset");

        -- Clear inputs while reset is still active, then release reset
        front_sensor <= '0';
        password_1   <= "00";
        password_2   <= "00";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        reset_n <= '1';
        wait for 2 * CLK_PERIOD;
        check_idle("Test C after release");

        -- ============================================================
        -- Test D: Asynchronous reset from STOP
        -- ============================================================
        report "=== Test D: reset from STOP ===" severity note;

        front_sensor <= '1';
        password_1   <= "01";
        password_2   <= "10";
        wait for 13 * CLK_PERIOD;

        assert HEX_1 = SEG_G and HEX_2 = SEG_O
            report "Test D: expected RIGHT_PASS before STOP" severity error;

        -- Trigger STOP state (both front_sensor and back_sensor active)
        back_sensor <= '1';
        wait for 2 * CLK_PERIOD;

        assert HEX_1 = SEG_S and HEX_2 = SEG_P
            report "Test D: expected STOP ('SP')" severity error;
        assert GREEN_LED = '0'
            report "Test D: expected GREEN_LED OFF in STOP" severity error;

        -- Assert reset asynchronously
        wait until falling_edge(clk);
        wait for CLK_PERIOD / 4;
        reset_n <= '0';
        wait for 1 ns;
        check_idle("Test D async reset");

        -- Clear inputs while reset is still active, then release reset
        front_sensor <= '0';
        back_sensor  <= '0';
        password_1   <= "00";
        password_2   <= "00";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        reset_n <= '1';
        wait for 2 * CLK_PERIOD;
        check_idle("Test D after release");

        -- ------------------------------------------------------------
        -- End simulation cleanly
        -- ------------------------------------------------------------
        report "Scenario 4 testbench completed successfully." severity note;
        sim_done <= true;
        wait;
    end process;

end architecture sim;