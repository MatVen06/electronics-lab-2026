library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity Car_Parking_System_VHDL_TB is
end Car_Parking_System_VHDL_TB;

architecture rtl of Car_Parking_System_VHDL_TB is  

constant clk_period : time := 20 ns; --> clk freq = 50Mhz

component Car_Parking_System_VHDL is 
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

    -- input: by default, reset_n = 0, state idle.
  signal tb_clk          : std_logic                    := '0';
  signal tb_reset_n      : std_logic                    := '0';
  signal tb_front_sensor : std_logic                    := '0';
  signal tb_back_sensor  : std_logic                    := '0';
  signal tb_password_1   : std_logic_vector(1 downto 0) := "00";
  signal tb_password_2   : std_logic_vector(1 downto 0) := "00";

  -- Output signals
  signal tb_GREEN_LED : std_logic;
  signal tb_RED_LED   : std_logic;
  signal tb_HEX_1     : std_logic_vector(6 downto 0);
  signal tb_HEX_2     : std_logic_vector(6 downto 0);

begin
-- DUT = Device Under Test
DUT : Car_Parking_System_VHDL
    -- we map the input signals we want to send and the output
    -- signals we want to check to the inputs and outputs of the actual device.
    -- Those in the right are the testbench signals.
    port map (
    clk          => tb_clk,
    reset_n      => tb_reset_n,
    front_sensor => tb_front_sensor,
    back_sensor  => tb_back_sensor,
    password_1   => tb_password_1,
    password_2   => tb_password_2,
    GREEN_LED    => tb_GREEN_LED,
    RED_LED      => tb_RED_LED,
    HEX_1        => tb_HEX_1,
    HEX_2        => tb_HEX_2
    );


    -- We generate the clock

    clock : process 
    begin
        tb_clk <= '0';
        wait for clk_period / 2;
        tb_clk <= '1';
        wait for clk_period / 2;
    end process clock;

    dut_process : process
    begin
        -- scenario 1.
        wait for clk_period;
        -- remove reset
        tb_reset_n <= '1';
        wait for clk_period;


        -- scenario 1: normal entry
        tb_front_sensor <= '1';

        wait for clk_period; -- wait 1 cycle so the FSM enters WAIT_PASSWORD

        tb_password_1 <= "01";
        wait for clk_period; -- realistically, the driver will put first pswd1 then pswd2.
        tb_password_2 <= "10";

        wait for clk_period * 9; -- wait for the 10-cycle count to finish and move to RIGHT_PASS


        assert (tb_HEX_1 = "0000010" and tb_HEX_2 = "1000000")
        report "Scenario 1 failed: the display did not show 'GO'"
        severity error;

        -- check that GREEN_LED is blinking by checking if it follows the clock.
        wait for clk_period / 4;
        assert (tb_GREEN_LED = '0')
        report "Scenario 1 failed: GREEN_LED did not follow clk low"
        severity error;

        wait for clk_period / 2;
        assert (tb_GREEN_LED = '1')
        report "Scenario 1 failed: GREEN_LED did not follow clk high"
        severity error;

        wait for clk_period / 4; -- one clock cycle in total.


        tb_front_sensor <= '0'; -- the car passes, we assume the sensors change istantaneously.
        tb_back_sensor <= '1';
        wait for clk_period;
        tb_back_sensor <= '0';
        wait for clk_period;

        -- We need to verify that the system goes back to IDLE.
        -- We need a state register and a state codiing to do it?
        -- no need for a state register: IDLE is the only state with both displays off and both LEDs = '0'
        assert (tb_HEX_1 = "1111111" and tb_HEX_2 = "1111111" and tb_GREEN_LED = '0' and tb_RED_LED = '0')
        report "Scenario 1 failed: the system did not go back to IDLE"
        severity error;

        report "Scenario 1 succeeded"
        severity note;

        -- TODO Scenario 2: wrong password. Remember to reset before starting new scenario.


        -- TODO Scenario 3: Multiple cars. 

        -- TODO Scenario 4: Reset.


        wait;

    end process dut_process;
end architecture;
