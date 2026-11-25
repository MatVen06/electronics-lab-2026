library ieee;
use ieee.std_logic_1164.all;
entity Car_Parking_System_VHDL is
  port(
    clk          : in std_logic;
    reset_n      : in std_logic;       -- active low, asynchronous
    front_sensor : in std_logic;
    back_sensor  : in std_logic;
    password_1   : in std_logic_vector(1 downto 0);
    password_2   : in std_logic_vector(1 downto 0);
    GREEN_LED    : out std_logic;
    RED_LED      : out std_logic;
    HEX_1        : out std_logic_vector(6 downto 0); -- segments gfedcba
    HEX_2        : out std_logic_vector(6 downto 0)
  );
  end Car_Parking_System_VHDL;


  architecture rtl of Car_Parking_System_VHDL is
    -- definition of internal (state and control) signals
    
    -- status signals
    signal clock_10, clock_3, check_pswd : std_logic; -- status signal from the datapath = 1 if 10 clock cycles have elapsed.
    signal count_to_3, count_to_10, enable_green, enable_red : std_logic; -- control signals
    signal hex1_display, hex2_display : std_logic_vector(2 downto 0);
    

  begin
  -- instantiation of datapath and FSM + connection of status and control signals

    FSM : entity work.FSM
    port map(
        clk => clk,
        reset_n => reset_n,
        front_sensor => front_sensor,
        back_sensor => back_sensor,
        clock_10 => clock_10,
        clock_3 => clock_3,
        check_pswd => check_pswd,
        count_to_3 => count_to_3,
        count_to_10 => count_to_10,
        enable_green => enable_green,
        enable_red => enable_red,

        hex1_display => hex1_display,
        hex2_display => hex2_display
      );

    datapath : entity work.datapath
    port map(
        clk => clk,
        reset_n => reset_n,
        GREEN_LED => GREEN_LED,
        RED_LED => RED_LED,
        HEX_1 => HEX_1,
        HEX_2 => HEX_2,

        password_1 => password_1,
        password_2 => password_2,
        clock_10 => clock_10,
        clock_3 => clock_3,
        check_pswd => check_pswd,
        count_to_3 => count_to_3,
        count_to_10 => count_to_10,
        enable_green => enable_green,
        enable_red => enable_red,

        hex1_display => hex1_display,
        hex2_display => hex2_display
      );
      
  end architecture rtl;
    
