library ieee;
use ieee.std_logic_1164.all;

entity Parking_Controller is
    generic (
        PARKING_CAPACITY : integer := 7
        );
    port (
        -- Clock and Reset
        clk : in std_logic;
        nrst : in std_logic;
        -- Entry Gate 1 Sensors
        sensor_A_Gin1 : in std_logic; -- Before barrier
        sensor_B_Gin1 : in std_logic; -- After barrier
        -- Entry Gate 2 Sensors
        sensor_A_Gin2 : in std_logic;
        sensor_B_Gin2 : in std_logic;
        -- Exit Gate 1 Sensors
        sensor_A_Gout1 : in std_logic;
        sensor_B_Gout1 : in std_logic;
        -- Exit Gate 2 Sensors
        sensor_A_Gout2 : in std_logic;
        sensor_B_Gout2 : in std_logic;
        -- Payment Interface
        payment_done : in std_logic;
        payment_accepted : out std_logic;
        payment_request : out std_logic;
        -- Barrier Controls
        barrier_Gin1 : out std_logic; -- '1' = open
        barrier_Gin2 : out std_logic;
        barrier_Gout1 : out std_logic;
        barrier_Gout2 : out std_logic;
        -- Visual Indicators
        Green_Light : out std_logic;
        Red_Light : out std_logic;
        display : out std_logic_vector(6 downto 0)
        );
end entity;

architecture Behavioral of Parking_Controller is
    -- State machine types
    type gate_state_type is (IDLE, CAR_DETECTED, CAR_ENTERING, CAR_ENTERED);
    type exit_state_type is (IDLE, WAIT_PAYMENT, PAYMENT_OK,
    CAR_EXITING, CAR_EXITED);
    -- State signals for each gate
    signal state_Gin1, next_state_Gin1 : gate_state_type;
    signal state_Gin2, next_state_Gin2 : gate_state_type;
    signal state_Gout1, next_state_Gout1 : exit_state_type;
    signal state_Gout2, next_state_Gout2 : exit_state_type;
    -- Car counter
    signal car_count : integer range 0 to PARKING_CAPACITY := 0;
    -- Edge detection for sensors
    signal sensor_A_Gin1_prev, sensor_B_Gin1_prev, sensor_A_Gin2_prev, sensor_B_Gin2_prev : std_logic;
    signal sensor_A_Gout1_prev, sensor_B_Gout1_prev, sensor_A_Gout2_prev, sensor_B_Gout2_prev : std_logic;
    -- Increment/decrement flags
    signal inc_Gin1, inc_Gin2 : std_logic;
    signal dec_Gout1, dec_Gout2 : std_logic;
    -- Payment signals
    signal payment_accepted_Gout1, payment_accepted_Gout2 : std_logic;
begin

    stateregister : process (clk, nrst)
    begin
        if nrst = '0' then
            -- Reset all gate states to IDLE
            state_Gin1 <= IDLE;
            state_Gin2 <= IDLE;
            state_Gout1 <= IDLE;
            state_Gout2 <= IDLE;
            
            sensor_A_Gin1_prev <= '0';
            sensor_B_Gin1_prev <= '0';
            sensor_A_Gin2_prev <= '0';
            sensor_B_Gin2_prev <= '0';
            sensor_A_Gout1_prev <= '0';
            sensor_B_Gout1_prev <= '0';
            sensor_A_Gout2_prev <= '0';
            sensor_B_Gout2_prev <= '0';

        elsif rising_edge(clk) then
            -- Advance current states to next states
            state_Gin1 <= next_state_Gin1;
            state_Gin2 <= next_state_Gin2;
            state_Gout1 <= next_state_Gout1;
            state_Gout2 <= next_state_Gout2;

            sensor_A_Gin1_prev <= sensor_A_Gin1;
            sensor_B_Gin1_prev <= sensor_B_Gin1;
            sensor_A_Gin2_prev <= sensor_A_Gin2;
            sensor_B_Gin2_prev <= sensor_B_Gin2;
            sensor_A_Gout1_prev <= sensor_A_Gout1;
            sensor_B_Gout1_prev <= sensor_B_Gout1;
            sensor_A_Gout2_prev <= sensor_A_Gout2;
            sensor_B_Gout2_prev <= sensor_B_Gout2;
        end if;
    end process stateregister;
end architecture Behavioral;