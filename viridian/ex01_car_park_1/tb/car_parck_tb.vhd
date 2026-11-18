library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CPS_tb is
end CPS_tb;

architecture first of CPS_tb is

    constant clk_hz : integer := 100;
    constant time   : time    := 1000 ms/clk_hz;

    signal clk          : in std_logic := '0';
    signal reset_n      : in std_logic := '1';
    signal front_sensor : in std_logic; 
    signal back_sensor  : in std_logic;
    signal password_1   : in std_logic;
    signal password_2   : in std_logic;
    signal GREEN_LED    : out std_logic;
    signal RED_LED      : out std_logic;
    signal HEX_1        : out std_logic;
    signal HEX_2        : out std_logic;

begin

    DUT: entity work.Car_Parking_System_VHDL()
    port map(
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

    clk <= not clk after clk_period / 2;

    SEQUENCER_PROC : process is
    begin
      
        

    end process;
end architecture;