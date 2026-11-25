-- =================================================================================
-- UNIVERSITY OF TRENTO - DISI Department
-- Digital Electronics Laboratory Practice
-- 
-- Parking Lot Controller in VHDL
-- 
-- Specifications derived from testbenches:
-- - Parking capacity: 7 cars
-- - 2 input gates (Gin1, Gin2) with 2 sensors each (front/back)
-- - 2 exit gates (Gout1, Gout2) with 2 sensors each (front/back)
-- - Payment terminal at exit gates
-- - Green/Red lights for availability indication
-- - Optional 7-segment display for car count
-- =================================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Parking_Controller is
    generic (
        PARKING_CAPACITY : integer := 7  -- Maximum number of cars
    );
    port (
        -- General inputs
        clk                     : in  std_logic;  --! Clock signal
        nrst                    : in  std_logic;  --! Active-low reset
        
        -- Payment terminal inputs
        
        payment_done            : in  std_logic;  --! '1' = done
        
        -- Input gate Gin1 sensors
        sensor_A_Gin1           : in  std_logic;  --! Front sensor (before barrier)
        sensor_B_Gin1           : in  std_logic;  --! Back sensor (after barrier)
        
        -- Input gate Gin2 sensors
        sensor_A_Gin2           : in  std_logic;  --! Front sensor (before barrier)
        sensor_B_Gin2           : in  std_logic;  --! Back sensor (after barrier)
        
        -- Exit gate Gout1 sensors
        sensor_A_Gout1          : in  std_logic;  --! Front sensor (before barrier)
        sensor_B_Gout1          : in  std_logic;  --! Back sensor (after barrier)
        
        -- Exit gate Gout2 sensors
        sensor_A_Gout2          : in  std_logic;  --! Front sensor (before barrier)
        sensor_B_Gout2          : in  std_logic;  --! Back sensor (after barrier)
        
        -- Outputs
        payment_accepted        : out std_logic;  --! '1' = accepted, '0' = not yet accepted
        payment_request         : out  std_logic;  --! '1' = requested (light on), '0' = no request (light off)
        barrier_Gin1            : out std_logic;  --! '1' = open, '0' = closed
        barrier_Gin2            : out std_logic;  --! '1' = open, '0' = closed
        barrier_Gout1           : out std_logic;  --! '1' = open, '0' = closed
        barrier_Gout2           : out std_logic;  --! '1' = open, '0' = closed
        Green_Light             : out std_logic;  --! Available spots
        Red_Light               : out std_logic;  --! Parking full
        display                 : out std_logic_vector(6 downto 0)  --! 7-segment display
    );
end Parking_Controller;

architecture Behavioral of Parking_Controller is
    -- FSM states for each gate
    type gate_state_type is (IDLE, CAR_DETECTED, CAR_ENTERING, CAR_ENTERED);
    type exit_state_type is (IDLE, WAIT_PAYMENT, PAYMENT_OK, CAR_EXITING, CAR_EXITED);
    -- State signals for each gate
    signal state_Gin1, next_state_Gin1   : gate_state_type; --! state of the input gate Gin1
    signal state_Gin2, next_state_Gin2   : gate_state_type; --! state of the input gate Gin2
    signal state_Gout1, next_state_Gout1 : exit_state_type; --! state of the output gate Gout1
    signal state_Gout2, next_state_Gout2 : exit_state_type; --! state of the output gate Gout2
    -- Car counter
    signal car_count : integer range 0 to PARKING_CAPACITY := 0; --! Counter of the car park 
    signal sensor_A_Gin1_prev, sensor_B_Gin1_prev : std_logic := '0'; --! Previous sensor states for edge detection
    signal sensor_A_Gin2_prev, sensor_B_Gin2_prev : std_logic := '0'; --! Previous sensor states for edge detection
    signal sensor_A_Gout1_prev, sensor_B_Gout1_prev : std_logic := '0'; --! Previous sensor states for edge detection
    signal sensor_A_Gout2_prev, sensor_B_Gout2_prev : std_logic := '0'; --! Previous sensor states for edge detection
    signal inc_Gin1, inc_Gin2 : std_logic := '0'; --! Flags to increment car count
    signal dec_Gout1, dec_Gout2 : std_logic := '0'; --! Flags to decrement car count
    
    -- Payment flags
    signal payment_accepted_Gout1, payment_accepted_Gout2 : std_logic := '0'; --! Signal that is 1 when the payment is accepted
    
    -- Function to convert integer to 7-segment display
    function int_to_7seg(value : integer) return std_logic_vector is
        variable result : std_logic_vector(6 downto 0);
    begin
        case value is
            when 0 => result := "1000000";  --! 0
            when 1 => result := "1111001";  --! 1
            when 2 => result := "0100100";  --! 2
            when 3 => result := "0110000";  --! 3
            when 4 => result := "0011001";  --! 4
            when 5 => result := "0010010";  --! 5
            when 6 => result := "0000010";  --! 6
            when 7 => result := "1111000";  --! 7
            when others => result := "1111111";  -- off
        end case;
        return result;
    end function;

begin

    -- =================================================================================
    -- State registers and sensor edge detection
    -- =================================================================================
    stateregister : process(clk, nrst)
    begin
        if nrst = '0' then
            state_Gin1 <= IDLE;
            state_Gin2 <= IDLE;
            state_Gout1 <= IDLE;
            state_Gout2 <= IDLE;
            
            sensor_A_Gin1_prev  <= '0';
            sensor_B_Gin1_prev  <= '0';
            sensor_A_Gin2_prev  <= '0';
            sensor_B_Gin2_prev  <= '0';
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
    end process;

    -- =================================================================================
    -- Input Gate Gin1 FSM
    -- =================================================================================
    gin1 : process(state_Gin1, sensor_A_Gin1, sensor_B_Gin1, sensor_A_Gin1_prev, 
            sensor_B_Gin1_prev, car_count)
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
                barrier_Gin1 <= '1';  -- Open barrier
                if sensor_B_Gin1 = '1' then
                    next_state_Gin1 <= CAR_ENTERING;
                elsif sensor_A_Gin1 = '0' then
                    -- Car left without entering
                    next_state_Gin1 <= IDLE;
                end if;
                
            when CAR_ENTERING =>
                barrier_Gin1 <= '1';  -- Keep barrier open
                if sensor_A_Gin1 = '0' and sensor_B_Gin1 = '1' then
                    next_state_Gin1 <= CAR_ENTERED;
                elsif sensor_A_Gin1 = '1' and sensor_B_Gin1 = '0' then
                    -- Car reversed out
                    next_state_Gin1 <= CAR_DETECTED;
                end if;
                
            when CAR_ENTERED =>
                if sensor_B_Gin1 = '0' then
                    inc_Gin1 <= '1';  -- Increment car count
                    next_state_Gin1 <= IDLE;
                end if;
                
        end case;
    end process;

    -- =================================================================================
    -- Input Gate Gin2 FSM
    -- =================================================================================
    gin2 : process(state_Gin2, sensor_A_Gin2, sensor_B_Gin2, sensor_A_Gin2_prev, 
            sensor_B_Gin2_prev, car_count)
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
                barrier_Gin2 <= '1';  -- Open barrier
                if sensor_B_Gin2 = '1' then
                    next_state_Gin2 <= CAR_ENTERING;
                elsif sensor_A_Gin2 = '0' then
                    -- Car left without entering
                    next_state_Gin2 <= IDLE;
                end if;
                
            when CAR_ENTERING =>
                barrier_Gin2 <= '1';  -- Keep barrier open
                if sensor_A_Gin2 = '0' and sensor_B_Gin2 = '1' then
                    next_state_Gin2 <= CAR_ENTERED;
                elsif sensor_A_Gin2 = '1' and sensor_B_Gin2 = '0' then
                    -- Car reversed out
                    next_state_Gin2 <= CAR_DETECTED;
                end if;
                
            when CAR_ENTERED =>
                if sensor_B_Gin2 = '0' then
                    inc_Gin2 <= '1';  -- Increment car count
                    next_state_Gin2 <= IDLE;
                end if;
                
        end case;
    end process;

    -- =================================================================================
    -- Exit Gate Gout1 FSM
    -- =================================================================================
    gout1 : process(state_Gout1, sensor_A_Gout1, sensor_B_Gout1, payment_request, 
            payment_done, car_count)
    begin
        next_state_Gout1 <= state_Gout1;
        barrier_Gout1 <= '0';
        dec_Gout1 <= '0';
        payment_accepted_Gout1 <= '0';
        
        case state_Gout1 is
            when IDLE =>
                if sensor_A_Gout1 = '1' and car_count > 0 then
                    next_state_Gout1 <= WAIT_PAYMENT;
                end if;
                
            when WAIT_PAYMENT =>
                if payment_done = '1' then
                    payment_accepted_Gout1 <= '1';
                    next_state_Gout1 <= PAYMENT_OK;
                elsif sensor_A_Gout1 = '0' then
                    -- Car left without payment
                    next_state_Gout1 <= WAIT_PAYMENT;
                    payment_request <= '1'; --! Request payment light on
                end if;
                
            when PAYMENT_OK =>
                barrier_Gout1 <= '1';  -- Open barrier after payment
                payment_accepted_Gout1 <= '1';
                if sensor_B_Gout1 = '1' then
                    next_state_Gout1 <= CAR_EXITING;
                end if;
                
            when CAR_EXITING =>
                barrier_Gout1 <= '1';  -- Keep barrier open
                if sensor_A_Gout1 = '0' and sensor_B_Gout1 = '1' then
                    next_state_Gout1 <= CAR_EXITED;
                end if;
                
            when CAR_EXITED =>
                if sensor_B_Gout1 = '0' then
                    dec_Gout1 <= '1';  -- Decrement car count
                    next_state_Gout1 <= IDLE;
                end if;
                
        end case;
    end process;

    -- =================================================================================
    -- Exit Gate Gout2 FSM
    -- =================================================================================
    gout2 : process(state_Gout2, sensor_A_Gout2, sensor_B_Gout2, payment_done, car_count)
    begin
        next_state_Gout2 <= state_Gout2;
        barrier_Gout2 <= '0';
        dec_Gout2 <= '0';
        payment_request <= '0'; --1! Default no payment request
        payment_accepted_Gout2 <= '0';
        
        case state_Gout2 is
            when IDLE =>
                if sensor_A_Gout2 = '1' and car_count > 0 then
                    next_state_Gout2 <= WAIT_PAYMENT;
                end if;
                
            when WAIT_PAYMENT =>
                if payment_done = '1' then
                    payment_accepted_Gout2 <= '1';
                    next_state_Gout2 <= PAYMENT_OK;
                elsif sensor_A_Gout2 = '0' then
                    -- Car left without payment
                    payment_request <= '1'; --! Request payment light on
                    next_state_Gout2 <= WAIT_PAYMENT;
                end if;
                
            when PAYMENT_OK =>
                barrier_Gout2 <= '1';  -- Open barrier after payment
                payment_accepted_Gout2 <= '1';
                if sensor_B_Gout2 = '1' then
                    next_state_Gout2 <= CAR_EXITING;
                end if;
                
            when CAR_EXITING =>
                barrier_Gout2 <= '1';  -- Keep barrier open
                if sensor_A_Gout2 = '0' and sensor_B_Gout2 = '1' then
                    next_state_Gout2 <= CAR_EXITED;
                end if;
                
            when CAR_EXITED =>
                if sensor_B_Gout2 = '0' then
                    dec_Gout2 <= '1';  -- Decrement car count
                    next_state_Gout2 <= IDLE;
                end if;
                
        end case;
    end process;

    -- =================================================================================
    -- Car counter management
    -- =================================================================================
    countermgt : process(clk, nrst)
    begin
        if nrst = '0' then
            car_count <= 0;
        elsif rising_edge(clk) then
            -- Handle simultaneous entry/exit
            if (inc_Gin1 = '1' or inc_Gin2 = '1') and (dec_Gout1 = '1' or dec_Gout2 = '1') then
                -- Simultaneous entry and exit
                if (inc_Gin1 = '1' and inc_Gin2 = '1') and (dec_Gout1 = '1' and dec_Gout2 = '1') then
                    -- 2 entering, 2 exiting: no change
                    car_count <= car_count;
                elsif (inc_Gin1 = '1' and inc_Gin2 = '1') then
                    -- 2 entering, 1 exiting: +1
                    car_count <= car_count + 1;
                elsif (dec_Gout1 = '1' and dec_Gout2 = '1') then
                    -- 1 entering, 2 exiting: -1
                    car_count <= car_count - 1;
                else
                    -- 1 entering, 1 exiting: no change
                    car_count <= car_count;
                end if;
            elsif inc_Gin1 = '1' or inc_Gin2 = '1' then
                -- Only entries
                if inc_Gin1 = '1' and inc_Gin2 = '1' then
                    car_count <= car_count + 2;
                else
                    car_count <= car_count + 1;
                end if;
            elsif dec_Gout1 = '1' or dec_Gout2 = '1' then
                -- Only exits
                if dec_Gout1 = '1' and dec_Gout2 = '1' then
                    car_count <= car_count - 2;
                else
                    car_count <= car_count - 1;
                end if;
            end if;
        end if;
    end process;

    -- =================================================================================
    -- Output assignments
    -- =================================================================================
    
    -- Payment accepted (OR of both exit gates)
    payment_accepted <= payment_accepted_Gout1 or payment_accepted_Gout2;
    
    -- Availability lights
    Green_Light <= '1' when car_count < PARKING_CAPACITY else '0';
    Red_Light <= '1' when car_count >= PARKING_CAPACITY else '0';
    
    -- 7-segment display showing car count
    display <= int_to_7seg(car_count);

end Behavioral;