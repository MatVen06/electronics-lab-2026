library ieee;
use ieee.std_logic_1164.all;

entity CarParkingSystem_tb is
end entity CarParkingSystem_tb;

architecture test of CarParkingSystem_tb is
    -- Componente da testare
    component CarParkingSystem is
        port(
            clk          : in  std_logic;
            reset_n      : in  std_logic; -- active low, asynchronous
            front_sensor : in  std_logic;
            back_sensor  : in  std_logic;
            password_1   : in  std_logic_vector(1 downto 0);
            password_2   : in  std_logic_vector(1 downto 0);
            GREEN_LED    : out std_logic;
            RED_LED      : out std_logic;
            HEX_1        : out std_logic_vector(6 downto 0); -- segments gfedcba
            HEX_2        : out std_logic_vector(6 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;

    -- Input signals
    signal s_clk          : std_logic := '0';
    signal s_reset_n      : std_logic;
    signal s_front_sensor : std_logic;
    signal s_back_sensor  : std_logic;
    signal s_password_1   : std_logic_vector(1 downto 0);
    signal s_password_2   : std_logic_vector(1 downto 0);

    -- Output signals
    signal s_GREEN_LED : std_logic;
    signal s_RED_LED   : std_logic;
    signal s_HEX_1     : std_logic_vector(6 downto 0);
    signal s_HEX_2     : std_logic_vector(6 downto 0);
begin
    UUT : CarParkingSystem
        port map(
            clk          => s_clk,
            reset_n      => s_reset_n,
            front_sensor => s_front_sensor,
            back_sensor  => s_back_sensor,
            password_1   => s_password_1,
            password_2   => s_password_2,
            GREEN_LED    => s_GREEN_LED,
            RED_LED      => s_RED_LED,
            HEX_1        => s_HEX_1,
            HEX_2        => s_HEX_2
        );

    -- Generate clock signal
    Clk_Process : process
    begin
        s_clk <= '0';
        wait for CLK_PERIOD / 2;
        s_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;
end architecture;
