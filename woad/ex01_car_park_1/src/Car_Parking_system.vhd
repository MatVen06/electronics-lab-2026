library ieee;
use ieee.std_logic_1164.all;

entity Car_Parking_System_VHDL is
    port(
        clk : in std_logic;
        reset_n : in std_logic := '1'; -- active low, asynchronous
        front_sensor: in std_logic;
        back_sensor : in std_logic;
        password_1 : in std_logic_vector(1 downto 0);
        password_2 : in std_logic_vector(1 downto 0);
        GREEN_LED : out std_logic;
        RED_LED : out std_logic;
        HEX_1 : out std_logic_vector(6 downto 0); -- segments gfedcba
        HEX_2 : out std_logic_vector(6 downto 0)
    );
end Car_Parking_System_VHDL;

architecture FSM of Car_Parking_System_VHDL is 
  type state_t is (S_IDLE, S_WAIT_PASS, S_WRONG_PASS, S_RIGHT_PASS, S_STOP);
  signal state, next_state : state_t;
  signal counter : integer range 0 to 10 := 0;
  signal tmr : std_logic := '0';

begin

  -- State register process
  reg : process (reset_n, clk)
  begin
    if reset_n = '0' then
      state <= S_IDLE;
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process reg;

  -- Clock/Counter process
  timer : process(clk, reset_n)
  begin
    if reset_n = '0' then
        counter <= 0;
    elsif rising_edge(clk) then
        if state /= next_state then
            counter <= 0;
        elsif tmr = '1' then
            if counter < 10 then
                counter <= counter + 1;
            else
                counter <= 0;
            end if;
        else
            counter <= 0;
        end if;
    end if;
  end process timer;

  -- Combined Next-State and Output Logic (Single Driver for LEDs)
  FSM_logic : process(state, reset_n, front_sensor, back_sensor, password_1, password_2, counter, clk)
  begin
        -- Default assignments
        RED_LED   <= '0';
        GREEN_LED <= '0';
        HEX_1     <= "1111111";
        HEX_2     <= "1111111";
        tmr       <= '0';
        next_state <= state;

        case state is
        when S_IDLE => 
            if front_sensor = '1' then
                next_state <= S_WAIT_PASS;
            else
                next_state <= S_IDLE;
            end if;

        when S_WAIT_PASS =>
            tmr <= '1';
            RED_LED <= '1'; -- Solid Red
            HEX_1 <= "0000110";
            HEX_2 <= "0101011";
            if reset_n = '0' then 
                next_state <= S_IDLE;
            elsif counter = 10 and (password_1 = "10" and password_2 = "01") then
                next_state <= S_RIGHT_PASS;
            elsif counter = 10 and not (password_1 = "10" and password_2 = "01") then 
                next_state <= S_WRONG_PASS;
            elsif front_sensor = '1' and counter < 10 then
                next_state <= S_WAIT_PASS;
            end if;

        when S_WRONG_PASS =>
            tmr <= '1';
            RED_LED <= clk; -- Blinking Red
            HEX_1 <= "0000110";
            HEX_2 <= "0000110";
            if reset_n = '0' then 
                next_state <= S_IDLE;
            elsif counter > 5 then
                next_state <= S_WAIT_PASS;
            else 
                next_state <= S_WRONG_PASS;
            end if;

        when S_RIGHT_PASS =>
            tmr <= '1';
            GREEN_LED <= clk; -- Blinking Green
            HEX_1 <= "0000010";
            HEX_2 <= "1000000";
            if reset_n = '0' then 
                next_state <= S_IDLE;
            elsif front_sensor = '0' and back_sensor = '0' and counter > 5 then 
                next_state <= S_IDLE;
            elsif front_sensor = '1' and back_sensor = '1' and counter < 5 then
                next_state <= S_STOP;
            else
                next_state <= S_RIGHT_PASS;
            end if;

        when S_STOP =>
            RED_LED <= clk; -- Blinking Red
            HEX_1 <= "0100100";
            HEX_2 <= "0001100";
            if reset_n = '0' then 
                next_state <= S_IDLE;
            elsif back_sensor = '0' then
                next_state <= S_WAIT_PASS;
            else
                next_state <= S_STOP;
            end if;        
        end case;
  end process FSM_logic;

end FSM;