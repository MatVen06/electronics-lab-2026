library ieee;
use ieee.std_logic_1164.all;

entity parking_tb_case2 is
end entity;

architecture sim of parking_tb_case2 is

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

    procedure pass_car(signal a, b : out std_logic) is
    begin
        a <= '1'; b <= '0'; wait for 30 ns;
        a <= '1'; b <= '1'; wait for 30 ns;
        a <= '0'; b <= '1'; wait for 30 ns;
        a <= '0'; b <= '0'; wait for 30 ns;
    end procedure;

    procedure pass_exit(signal a, b : out std_logic; signal pay : out std_logic) is
    begin
        a <= '1'; b <= '0'; wait for 30 ns;
        pay <= '1';         wait for 30 ns;
        pay <= '0';
        a <= '1'; b <= '1'; wait for 30 ns;
        a <= '0'; b <= '1'; wait for 30 ns;
        a <= '0'; b <= '0'; wait for 30 ns;
    end procedure;

begin

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
        -- reset
        nrst <= '0'; wait for 20 ns;
        nrst <= '1'; wait for 20 ns;
        assert display = "0001111" report "after reset display should show 7" severity error;

        -- Scenario 1
        for i in 1 to 3 loop
            pass_car(sensor_A_Gin1, sensor_B_Gin1);
        end loop;
        for i in 1 to 2 loop
            pass_car(sensor_A_Gin2, sensor_B_Gin2);
        end loop;
        assert display = "0010010" report "S1: display should show 2 after 5 cars" severity error;
        assert Green_Light = '1'   report "S1: green light should be on" severity error;
        report "Scenario 1 done";

        -- Scenario 2
        sensor_A_Gin1 <= '1'; sensor_B_Gin1 <= '0'; sensor_A_Gin2 <= '1'; sensor_B_Gin2 <= '0'; wait for 30 ns;
        sensor_A_Gin1 <= '1'; sensor_B_Gin1 <= '1'; sensor_A_Gin2 <= '1'; sensor_B_Gin2 <= '1'; wait for 30 ns;
        sensor_A_Gin1 <= '0'; sensor_B_Gin1 <= '1'; sensor_A_Gin2 <= '0'; sensor_B_Gin2 <= '1'; wait for 30 ns;
        sensor_A_Gin1 <= '0'; sensor_B_Gin1 <= '0'; sensor_A_Gin2 <= '0'; sensor_B_Gin2 <= '0'; wait for 30 ns;
        assert display = "0000001" report "S2: display should show 0 (two simultaneous entries lost a car?)" severity error;
        assert Red_Light = '1'     report "S2: red light should be on" severity error;
        assert Green_Light = '0'   report "S2: green light should be off" severity error;
        report "Scenario 2 done";

        -- Scenario 3
        sensor_A_Gin1 <= '1'; sensor_A_Gin2 <= '1';
        wait for 60 ns;
        assert barrier_Gin1 = '0' report "S3: Gin1 barrier must stay closed when full" severity error;
        assert barrier_Gin2 = '0' report "S3: Gin2 barrier must stay closed when full" severity error;
        assert display = "0000001" report "S3: display must still show 0" severity error;
        sensor_A_Gin1 <= '0'; sensor_A_Gin2 <= '0';
        wait for 30 ns;
        report "Scenario 3 done";

        -- Scenario 4
        pass_exit(sensor_A_Gout1, sensor_B_Gout1, payment_done);
        assert display = "1001111" report "S4: display should show 1 after Gout1 exit" severity error;
        assert Green_Light = '1'   report "S4: green light should be on again" severity error;
        assert Red_Light = '0'     report "S4: red light should be off" severity error;
        pass_exit(sensor_A_Gout2, sensor_B_Gout2, payment_done);
        assert display = "0010010" report "S4: display should show 2 after Gout2 exit" severity error;
        report "Scenario 4 done";

        -- Scenario 5
        sensor_A_Gout1 <= '1'; sensor_B_Gout1 <= '0'; sensor_A_Gout2 <= '1'; sensor_B_Gout2 <= '0'; wait for 30 ns;
        assert payment_request = '1' report "S5: payment request should be on" severity error;
        payment_done <= '1'; wait for 30 ns;
        payment_done <= '0';
        assert barrier_Gout1 = '1' report "S5: Gout1 barrier should be open" severity error;
        assert barrier_Gout2 = '1' report "S5: Gout2 barrier should be open" severity error;
        sensor_A_Gout1 <= '1'; sensor_B_Gout1 <= '1'; sensor_A_Gout2 <= '1'; sensor_B_Gout2 <= '1'; wait for 30 ns;
        sensor_A_Gout1 <= '0'; sensor_B_Gout1 <= '1'; sensor_A_Gout2 <= '0'; sensor_B_Gout2 <= '1'; wait for 30 ns;
        sensor_A_Gout1 <= '0'; sensor_B_Gout1 <= '0'; sensor_A_Gout2 <= '0'; sensor_B_Gout2 <= '0'; wait for 30 ns;
        assert display = "1001100" report "S5: display should show 4 after two simultaneous exits" severity error;
        report "Scenario 5 done";

        -- Scenario 6
        for i in 1 to 3 loop
            pass_car(sensor_A_Gin1, sensor_B_Gin1);
        end loop;
        assert display = "1001111" report "S6: display should show 1 before the overbooking test" severity error;
        sensor_A_Gin1 <= '1'; sensor_B_Gin1 <= '0'; sensor_A_Gin2 <= '1'; sensor_B_Gin2 <= '0'; wait for 30 ns;
        sensor_A_Gin1 <= '1'; sensor_B_Gin1 <= '1'; sensor_A_Gin2 <= '1'; sensor_B_Gin2 <= '1'; wait for 30 ns;
        sensor_A_Gin1 <= '0'; sensor_B_Gin1 <= '1'; sensor_A_Gin2 <= '0'; sensor_B_Gin2 <= '1'; wait for 30 ns;
        sensor_A_Gin1 <= '0'; sensor_B_Gin1 <= '0'; sensor_A_Gin2 <= '0'; sensor_B_Gin2 <= '0'; wait for 30 ns;
        -- allowed outcomes: 6 or 7 cars (display 1 or 0), never more than the capacity
        assert display = "0000001" or display = "1001111"
            report "S6: overbooking, counter went past the capacity" severity error;
        report "Scenario 6 done";

        report "TB finished";
        wait;
    end process;

end architecture;