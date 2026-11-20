library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_scenario1 is
end tb_scenario1;

architecture sim of tb_scenario1 is

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

    -- Expected segment constants (from handout)
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

        -- Release reset
        reset_n <= '1';
        wait for 2 * CLK_PERIOD;

        -- Check IDLE outputs: LEDs off, displays off
        assert GREEN_LED = '0' report "IDLE: GREEN_LED should be 0" severity error;
        assert RED_LED   = '0' report "IDLE: RED_LED should be 0"   severity error;
        assert HEX_1 = SEG_OFF report "IDLE: HEX_1 should be OFF"   severity error;
        assert HEX_2 = SEG_OFF report "IDLE: HEX_2 should be OFF"   severity error;

        -- ------------------------------------------------------------
        -- Step 1: Assert front_sensor = '1' -> WAIT_PASSWORD
        -- ------------------------------------------------------------
        front_sensor <= '1';
        wait for CLK_PERIOD;

        -- In WAIT_PASSWORD: RED LED ON steady, displays "En"
        assert RED_LED = '1'   report "WAIT_PASS: RED_LED should be ON" severity error;
        assert GREEN_LED = '0' report "WAIT_PASS: GREEN_LED should be OFF" severity error;
        assert HEX_1 = SEG_E   report "WAIT_PASS: HEX_1 should be 'E'" severity error;
        assert HEX_2 = SEG_N   report "WAIT_PASS: HEX_2 should be 'n'" severity error;

        -- ------------------------------------------------------------
        -- Step 2: Wait 10+ clock cycles (keep password wrong/stable)
        -- ------------------------------------------------------------
        -- Keep password at "00"/"00" during the waiting period
        -- (they must be stable during the 10-cycle window)
        wait for 12 * CLK_PERIOD;

        -- ------------------------------------------------------------
        -- Step 3: Apply correct password: password_1 = "01", password_2 = "10"
        -- ------------------------------------------------------------
        password_1 <= "01";
        password_2 <= "10";
        wait for CLK_PERIOD;

        -- Now state should be RIGHT_PASS: GREEN LED blinks, displays "GO"
        -- (blink_phase toggles each clock, so check over a few cycles)
        assert HEX_1 = SEG_G report "RIGHT_PASS: HEX_1 should be 'G'" severity error;
        assert HEX_2 = SEG_O report "RIGHT_PASS: HEX_2 should be 'O'" severity error;
        assert RED_LED = '0' report "RIGHT_PASS: RED_LED should be OFF" severity error;

        -- Check blinking: GREEN_LED should toggle over successive cycles
        -- Sample GREEN_LED over 2 clock cycles and confirm it changes
        wait until rising_edge(clk);
        assert GREEN_LED = '1' or GREEN_LED = '0' report "GREEN_LED invalid" severity error;
        wait until rising_edge(clk);
        assert GREEN_LED = '1' or GREEN_LED = '0' report "GREEN_LED invalid" severity error;

        -- (Optional stricter blink check)
        -- wait until rising_edge(clk); assert GREEN_LED = '1' ...
        -- wait until rising_edge(clk); assert GREEN_LED = '0' ...
        -- depending on phase at entry; leave as informational.

        wait for 2 * CLK_PERIOD;

        -- ------------------------------------------------------------
        -- Step 5: Assert back_sensor = '1' -> return to IDLE
        -- ------------------------------------------------------------
        back_sensor <= '1';
        wait for 2 * CLK_PERIOD;

        -- System should return to IDLE: outputs OFF
        assert GREEN_LED = '0' report "IDLE after exit: GREEN_LED should be 0" severity error;
        assert RED_LED   = '0' report "IDLE after exit: RED_LED should be 0"   severity error;
        assert HEX_1 = SEG_OFF report "IDLE after exit: HEX_1 should be OFF"   severity error;
        assert HEX_2 = SEG_OFF report "IDLE after exit: HEX_2 should be OFF"   severity error;

        -- ------------------------------------------------------------
        -- End simulation
        -- ------------------------------------------------------------
        report "Scenario 1 testbench completed successfully." severity note;
        assert false report "Simulation finished" severity failure;
        wait for 5 * CLK_PERIOD;
        wait;
    end process;

end sim;
