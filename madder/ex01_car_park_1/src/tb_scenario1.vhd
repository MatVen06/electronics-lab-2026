library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_scenario1 is
end entity tb_scenario1;

architecture sim of tb_scenario1 is

    -- Component declaration (matches cp1testbench for consistent VCD hierarchy in VaporView)
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
        variable led_sample_1 : std_logic;
        variable led_sample_2 : std_logic;
    begin
        -- ------------------------------------------------------------
        -- Step 0: Initial asynchronous reset -> IDLE
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

        -- Verify IDLE outputs: LEDs OFF, displays OFF
        assert GREEN_LED = '0' report "IDLE: GREEN_LED should be 0" severity error;
        assert RED_LED   = '0' report "IDLE: RED_LED should be 0"   severity error;
        assert HEX_1 = SEG_OFF report "IDLE: HEX_1 should be OFF"   severity error;
        assert HEX_2 = SEG_OFF report "IDLE: HEX_2 should be OFF"   severity error;

        -- ------------------------------------------------------------
        -- Step 1: Car arrives at front sensor -> WAIT_PASSWORD
        -- ------------------------------------------------------------
        front_sensor <= '1';
        wait for CLK_PERIOD;

        -- Verify WAIT_PASSWORD outputs: RED_LED steady ON, displays "En"
        assert RED_LED   = '1' report "WAIT_PASSWORD: RED_LED should be ON"  severity error;
        assert GREEN_LED = '0' report "WAIT_PASSWORD: GREEN_LED should be OFF" severity error;
        assert HEX_1 = SEG_E   report "WAIT_PASSWORD: HEX_1 should be 'E'"   severity error;
        assert HEX_2 = SEG_N   report "WAIT_PASSWORD: HEX_2 should be 'n'"   severity error;

        -- ------------------------------------------------------------
        -- Step 2: Enter correct password ("01", "10") and wait 10+ cycles
        -- ------------------------------------------------------------
        password_1 <= "01";
        password_2 <= "10";
        wait for 12 * CLK_PERIOD;

        -- ------------------------------------------------------------
        -- Step 3: Verify RIGHT_PASS state ("GO", RED_LED OFF)
        -- ------------------------------------------------------------
        assert HEX_1 = SEG_G report "RIGHT_PASS: HEX_1 should be 'G'" severity error;
        assert HEX_2 = SEG_O report "RIGHT_PASS: HEX_2 should be 'O'" severity error;
        assert RED_LED = '0' report "RIGHT_PASS: RED_LED should be OFF" severity error;

        -- ------------------------------------------------------------
        -- Step 4: Verify GREEN_LED is actively blinking
        -- ------------------------------------------------------------
        wait until rising_edge(clk);
        wait for 1 ns;
        led_sample_1 := GREEN_LED;

        wait until rising_edge(clk);
        wait for 1 ns;
        led_sample_2 := GREEN_LED;

        assert (led_sample_1 /= led_sample_2)
            report "RIGHT_PASS: GREEN_LED is not blinking" severity error;

        wait for 2 * CLK_PERIOD;

        -- ------------------------------------------------------------
        -- Step 5: Car clears front sensor and triggers back sensor -> IDLE
        -- ------------------------------------------------------------
        front_sensor <= '0';
        back_sensor  <= '1';
        wait for 2 * CLK_PERIOD;

        -- Verify return to IDLE: all outputs OFF
        assert GREEN_LED = '0' report "IDLE after exit: GREEN_LED should be 0" severity error;
        assert RED_LED   = '0' report "IDLE after exit: RED_LED should be 0"   severity error;
        assert HEX_1 = SEG_OFF report "IDLE after exit: HEX_1 should be OFF"   severity error;
        assert HEX_2 = SEG_OFF report "IDLE after exit: HEX_2 should be OFF"   severity error;

        -- Clear back sensor after car exits
        back_sensor <= '0';
        wait for 2 * CLK_PERIOD;

        -- ------------------------------------------------------------
        -- End simulation cleanly
        -- ------------------------------------------------------------
        report "Scenario 1 testbench completed successfully." severity note;
        sim_done <= true;
        wait;
    end process;

end architecture sim;