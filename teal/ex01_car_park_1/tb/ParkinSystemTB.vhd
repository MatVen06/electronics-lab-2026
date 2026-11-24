--inputs 
    signal clk_tb          : std_logic := '0';
    signal reset_n_tb      : std_logic := '0';
    signal front_sensor_tb : std_logic := '0';
    signal back_sensor_tb  : std_logic := '0';
    signal password_1_tb   : std_logic_vector(1 downto 0) := (others => '0');
    signal password_2_tb   : std_logic_vector(1 downto 0) := (others => '0');
--outputs 
    signal GREEN_LED_tb : std_logic;
    signal RED_LED_tb   : std_logic;
    signal HEX_1_tb     : std_logic_vector(6 downto 0);
    signal HEX_2_tb     : std_logic_vector(6 downto 0);
    signal car_count_tb : integer := 0;
    
-- 2. Added clock period constant
    constant clk_period : time := 20 ns;

begin

    DUT: Car_Parking_System_VHDL
        port map (
            clk          => clk_tb,
            reset_n      => reset_n_tb,
            front_sensor => front_sensor_tb,
            back_sensor  => back_sensor_tb,
            password_1   => password_1_tb,
            password_2   => password_2_tb,
            GREEN_LED    => GREEN_LED_tb,
            RED_LED      => RED_LED_tb,
            HEX_1        => HEX_1_tb,
            HEX_2        => HEX_2_tb,
            car_count    => car_count_tb
        );


    clk_tb <= not clk_tb after clk_period / 2;

    stimulus: process
    begin
        -- reset asserted 
        report "Starting Testbench - Applying Reset";
                reset_n_tb <= '0';
                front_sensor_tb <= '0';
                back_sensor_tb  <= '0';
                password_1_tb   <= "00";
                password_2_tb   <= "00";
                wait for 100 ns;   
        -- de asset reset 
        reset_n_tb <= '1';
        report "reset released; System should go in IDLE state";
        wait for clk_period; 
    -- scenario: normal entry
        report "Starting Scenario : normal entry";     
            -- 1. Car arrives at front sensor
            front_sensor_tb <= '1';
            wait for clk_period;
            -- System should move to WAIT_PASSWORD
            report "  Car at front sensor. State should be WAIT_PASSWORD.";
            
            -- 2. Wait 10 clock cycles 
            report "  Waiting 10 cycles for password delay...";
            wait for 10 * clk_period;

            -- 3. Input correct password 
            report "  Entering correct password (0110).";
            password_1_tb <= "01";
            password_2_tb <= "10";
            wait for clk_period;
            -- System should transition to RIGHT_PASS

            -- 4. Verify: GREEN LED blinks and display "GO"
            report "  Password entered. State should be RIGHT_PASS (Green LED, 'GO').";
            wait for 20 * clk_period; -- Wait for car to move
            
            -- 5. Car moves off front sensor and onto back sensor
            report "  Car moving through. Front sensor '0', Back sensor '1'.";
            front_sensor_tb <= '0';
            back_sensor_tb  <= '1';
            wait for clk_period;

            -- 6. Car passes back sensor. System returns to IDLE.
            report "  Car passed. Back sensor '0'.";
            back_sensor_tb  <= '0'; 
            password_1_tb   <= "00"; -- Reset password inputs
            password_2_tb   <= "00";
            wait for clk_period;
            report "  Scenario 1 Complete. System should be IDLE.";
            wait for 10 * clk_period; -- Wait for signals to settle