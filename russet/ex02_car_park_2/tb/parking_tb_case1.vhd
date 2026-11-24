library ieee;
use ieee.std_logic_1164.all;

entity parking_tb_case1 is
end entity;                      

architecture sim of parking_tb_case1 is
    signal clk  : std_logic := '0';
    signal nrst : std_logic := '0';

    signal sensor_A_Gin1,  sensor_B_Gin1  : std_logic := '0';
    signal sensor_A_Gin2,  sensor_B_Gin2  : std_logic := '0';
    signal sensor_A_Gout1, sensor_B_Gout1 : std_logic := '0';
    signal sensor_A_Gout2, sensor_B_Gout2 : std_logic := '0';
    signal payment_done : std_logic := '0';

    signal payment_accepted, payment_request : std_logic;
    signal barrier_Gin1, barrier_Gin2, barrier_Gout1, barrier_Gout2 : std_logic;
    signal Green_Light, Red_Light : std_logic;
    signal display : std_logic_vector(6 downto 0);
begin
    -- device under test
    dut: entity work.Parking_Controller
    generic map (PARKING_CAPACITY => 7)
    port map (
        clk              => clk,
        nrst             => nrst,
        sensor_A_Gin1    => sensor_A_Gin1,
        sensor_B_Gin1    => sensor_B_Gin1,
        sensor_A_Gin2    => sensor_A_Gin2,
        sensor_B_Gin2    => sensor_B_Gin2,
        sensor_A_Gout1   => sensor_A_Gout1,
        sensor_B_Gout1   => sensor_B_Gout1,
        sensor_A_Gout2   => sensor_A_Gout2,
        sensor_B_Gout2   => sensor_B_Gout2,
        payment_done     => payment_done,
        payment_accepted => payment_accepted,
        payment_request  => payment_request,
        barrier_Gin1     => barrier_Gin1,
        barrier_Gin2     => barrier_Gin2,
        barrier_Gout1    => barrier_Gout1,
        barrier_Gout2    => barrier_Gout2,
        Green_Light      => Green_Light,
        Red_Light        => Red_Light,
        display          => display
    );
    clk <= not clk after 5 ns;

    stimulus: process
    begin
        nrst <= '0';  wait for 20 ns;     -- hold reset
        nrst <= '1';  wait for 20 ns;

    sensor_A_Gin1 <= '1';  sensor_B_Gin1 <= '0';
    wait for 30 ns;

    sensor_A_Gin1 <= '1';  sensor_B_Gin1 <= '1';
    wait for 30 ns;

    sensor_A_Gin1 <= '0';  sensor_B_Gin1 <= '1';
    wait for 30 ns;

    sensor_A_Gin1 <= '0';  sensor_B_Gin1 <= '0';
    wait for 30 ns;

    assert display = "0100000" report "display should show 6 after one car entered" severity error;
    assert Green_Light = '1'   report "green light should be on" severity error;
        report "TB finished";
        wait;                            
    end process;
end architecture;