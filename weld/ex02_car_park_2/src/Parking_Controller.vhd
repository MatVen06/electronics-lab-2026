library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Parking_Controller is
    generic (
        PARKING_CAPACITY : integer := 7
        );
    port (
        clk : in std_logic;
        nrst : in std_logic;

        sensor_A_Gin1 : in std_logic;
        sensor_B_Gin1 : in std_logic;

        sensor_A_Gin2 : in std_logic;
        sensor_B_Gin2 : in std_logic;

        sensor_A_Gout1 : in std_logic;
        sensor_B_Gout1 : in std_logic;

        sensor_A_Gout2 : in std_logic;
        sensor_B_Gout2 : in std_logic;

        payment_done : in std_logic;
        payment_accepted : out std_logic;
        payment_request : out std_logic;

        barrier_Gin1 : out std_logic;
        barrier_Gin2 : out std_logic;
        barrier_Gout1 : out std_logic;
        barrier_Gout2 : out std_logic;

        Green_Light : out std_logic;
        Red_Light : out std_logic;
        display : out std_logic_vector(6 downto 0);
    );
end entity;

architecture rtl of Parking_Controller is
    type gate_state_type is (IDLE, CAR_DETECTED, CAR_ENTERING, CAR_ENTERED);
    type exit_state_type is (IDLE, WAIT_PAYMENT, PAYMENT_OK, CAR_EXITING, CAR_EXITED);

    signal state_Gin1, next_state_Gin1 : gate_state_type;
    signal state_Gin2, next_state_Gin2 : gate_state_type;
    signal state_Gout1, next_state_Gout1 : exit_state_type;
    signal state_Gout2, next_state_Gout2 : exit_state_type;

    signal car_count : integer range 0 to PARKING_CAPACITY := 0;

    signal sensor_A_Gin1_prev, sensor_B_Gin1_prev : std_logic;
    signal sensor_A_Gin2_prev, sensor_B_Gin2_prev : std_logic;
    signal sensor_A_Gout1_prev, sensor_B_Gout1_prev : std_logic;
    signal sensor_A_Gout2_prev, sensor_B_Gout2_prev : std_logic;

    signal inc_Gin1, inc_Gin2 : std_logic;
    signal dec_Gout1, dec_Gout2 : std_logic;

    signal payment_accepted_Gout1, payment_accepted_Gout2 : std_logic;

    function int_to_7_seg(value : integer) return std_logic_vector is
        variable result : std_logic_vector(6 downto 0);
    begin
        case value is
        when 0 => result := "0000001"; -- 0
        when 1 => result := "1001111"; -- 1
        when 2 => result := "0010010"; -- 2
        when 3 => result := "0000110"; -- 3
        when 4 => result := "1001100"; -- 4
        when 5 => result := "0100100"; -- 5
        when 6 => result := "0100000"; -- 6
        when 7 => result := "0001111"; -- 7
        when 8 => result := "0000000"; -- 8
        when 9 => result := "0000100"; -- 9
        when others => result := "1111111"; -- error
        end case;
        return result;
    end function;
begin
    stateregister: process(clk, nrst) 
    begin
        if nrst = '0' then
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

    gin1 process(state_Gin1, sensor_A_Gin1, sensor_B_Gin1, sensor_A_Gin1_prev, sensor_B_Gin1_prev, car_count)
    begin
        next_state_Gin1 <= state_Gin1;
        barrier_Gin1 <= '0';
        inc_Gin1 <= '0';

        case state_Gin1 is
        when IDLE =>
            if sensor_A_Gin1 = '1' and car_count < PARKING_CAPACITY then
                next_state_Gin1 <= CAR_DETECTED;
            end if;
        when CAR_DETECTED =>
            if sensor_B_Gin1 = '1' then
                next_state_Gin1 <= CAR_ENTERING;
            else if sensor_A_Gin1 = '0' then
                next_state_Gin1 <= IDLE;
            end if;
        when CAR_ENTERING =>
            if sensor_A_Gin1 = '0' and sensor_B_Gin1 = '1' then
                next_state_Gin1 <= CAR_ENTERED;
            elsif sensor_A_Gin1 = '1' and sensor_B_Gin1 = '0' then
                next_state_Gin1 <= CAR_DETECTED;
            end if;
        when CAR_ENTERED =>
            if sensor_B_Gin1 = '0' then
                next_state_Gin1 <= IDLE;
            end if;
        end case;
    end process;

    gin2 process(state_Gin2, sensor_A_Gin2, sensor_B_Gin2, sensor_A_Gin2_prev, sensor_B_Gin2_prev, car_count)
    begin
        next_state_Gin2 <= state_Gin2;
        barrier_Gin2 <= '0';
        inc_Gin2 <= '0';

        case state_Gin2 is
        when IDLE =>
            if sensor_A_Gin2 = '1' and car_count < PARKING_CAPACITY then
                next_state_Gin2 <= CAR_DETECTED;
            end if;
        when CAR_DETECTED =>
            if sensor_B_Gin2 = '1' then
                next_state_Gin2 <= CAR_ENTERING;
            else if sensor_A_Gin2 = '0' then
                next_state_Gin2 <= IDLE;
            end if;
        when CAR_ENTERING =>
            if sensor_A_Gin2 = '0' and sensor_B_Gin2 = '1' then
                next_state_Gin2 <= CAR_ENTERED;
            elsif sensor_A_Gin2 = '1' and sensor_B_Gin2 = '0' then
                next_state_Gin2 <= CAR_DETECTED;
            end if;
        when CAR_ENTERED =>
            if sensor_B_Gin2 = '0' then
                next_state_Gin2 <= IDLE;
            end if;
        end case;
    end process;

    gout1 process(state_Gout1, sensor_A_Gout1, sensor_B_Gout1, payment_done, car_count)
    begin
        next_state_Gout1 <= state_Gout1;
        barrier_Gout1 <= '0';
        payment_request <= '0';
        payment_accepted_Gout1 <= '0';
        dec_Gout1 <= '0';

        case state_Gout1 is
        when IDLE =>
            if sensor_A_Gout1 = '1' and car_count > 0 then
                next_state_Gout1 <= WAIT_PAYMENT;
            end if;
        when WAIT_PAYMENT =>
            payment_request <= '1';
            if payment_done = '1' then
                next_state_Gout1 <= PAYMENT_OK;
            end if;
        when PAYMENT_OK =>
            payment_accepted_Gout1 <= '1';
            if sensor_B_Gout1 = '1' then
                next_state_Gout1 <= CAR_EXITING;
            end if;
        when CAR_EXITING =>
            barrier_Gout1 <= '1';
            if sensor_A_Gout1 = '0' and sensor_B_Gout1 = '1' then
                next_state_Gout1 <= CAR_EXITED;
            end if;
        when CAR_EXITED => 
            barrier_Gout1 <= '1';
            if sensor_B_Gout1 = '0' then
                next_state_Gout1 <= IDLE;
            end if;
        end case;
    end process;

    gout2 process(state_Gout2, sensor_A_Gout2, sensor_B_Gout2, payment_done, car_count)
    begin
        next_state_Gout2 <= state_Gout2;
        barrier_Gout2 <= '0';
        payment_request <= '0';
        payment_accepted_Gout2 <= '0';
        dec_Gout2 <= '0';

        case state_Gout2 is
        when IDLE =>
            if sensor_A_Gout2 = '1' and car_count > 0 then
                next_state_Gout2 <= WAIT_PAYMENT;
            end if;
        when WAIT_PAYMENT =>
            payment_request <= '1';
            if payment_done = '1' then
                next_state_Gout2 <= PAYMENT_OK;
            end if;
        when PAYMENT_OK =>
            payment_accepted_Gout2 <= '1';
            if sensor_B_Gout2 = '1' then
                next_state_Gout2 <= CAR_EXITING;
            end if;
        when CAR_EXITING =>
            barrier_Gout2 <= '1';
            if sensor_A_Gout2 = '0' and sensor_B_Gout2 = '1' then
                next_state_Gout2 <= CAR_EXITED;
            end if;
        when CAR_EXITED => 
            barrier_Gout2 <= '1';
            if sensor_B_Gout2 = '0' then
                next_state_Gout2 <= IDLE;
            end if;
        end case;
    end process;

    countermgt: process(clk, nrst)
    begin
        if nrst = '0' then
            car_count <= 0;
        elsif rising_edge(clk) then
            if inc_Gin1 = '1' then
                car_count <= car_count + 1;
            elsif inc_Gin2 = '1' then
                car_count <= car_count + 1;
            elsif dec_Gout1 = '1' then
                car_count <= car_count - 1;
            elsif dec_Gout2 = '1' then
                car_count <= car_count - 1;
            end if;
        end if;
    end process;

    indicators: process(car_count, payment_accepted_Gout1, payment_accepted_Gout2)
    begin
        display <= int_to_7_seg(PARKING_CAPACITY - car_count);

        Green_Light <= '1' when car_count < PARKING_CAPACITY else '0';
        Red_Light <= not Green_Light;

        payment_accepted <= payment_accepted_Gout1 or payment_accepted_Gout2;
    end process;
end architecture rtl;