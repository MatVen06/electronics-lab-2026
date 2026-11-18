-------------------------------------------------------------------------------
-- Logic Networks 2026 - Exercise:
-- Car Parking System
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

entity Car_Parking_System_VHDL is
  port (
    clk          : in  std_logic;
    reset_n      : in  std_logic;                    -- active low, asynchronous
    front_sensor : in  std_logic;
    back_sensor  : in  std_logic;
    password_1   : in  std_logic_vector(1 downto 0);
    password_2   : in  std_logic_vector(1 downto 0);
    GREEN_LED    : out std_logic;
    RED_LED      : out std_logic;
    HEX_1        : out std_logic_vector(6 downto 0); -- segments gfedcba
    HEX_2        : out std_logic_vector(6 downto 0)
  );
end entity;

architecture rtl of Car_Parking_System_VHDL is

  type state_type is (IDLE, WAIT_PASSWORD, WRONG_PASSWORD, RIGHT_PASSWORD, STOP);
  signal current_state : state_type;
  signal next_state    : state_type;

  constant TRUE_PASSWORD : std_logic_vector(3 downto 0) := "1010"; -- password_1 & password_2

  -- tick counter: counts clock cycles spent in the current state
  signal tick : natural range 0 to 255;

  signal stable       : boolean := true;        -- true if password is stable (not changing) for 1 clock cycle
  signal counter_tick : natural range 0 to 255; -- counts clock cycles spent in stable state

  -- DISPLAY CONSTANTS
  constant HEX_OFF : std_logic_vector(6 downto 0) := "1111111";
  constant HEX_E   : std_logic_vector(6 downto 0) := "0000110";
  constant HEX_n   : std_logic_vector(6 downto 0) := "0101011";
  constant HEX_G   : std_logic_vector(6 downto 0) := "0000010"; -- Shape of '6'
  constant HEX_O   : std_logic_vector(6 downto 0) := "1000000"; -- Shape of '0'
  constant HEX_S   : std_logic_vector(6 downto 0) := "0100100";
  constant HEX_P   : std_logic_vector(6 downto 0) := "0001100";

begin

  -- Clocked data path: state register + tick counter (asynchronous reset)
  DATA_PATH: process (clk, reset_n)
  begin
    if reset_n = '0' then
      current_state <= IDLE;
      tick <= 0;
    elsif rising_edge(clk) then
      current_state <= next_state;

      if current_state = WAIT_PASSWORD then
        if stable = true then
          counter_tick <= counter_tick + 1;
        else
          counter_tick <= 0; -- reset stable_tick counter if password is changing
        end if;
      else
        counter_tick <= 0; -- reset stable_tick counter in other states
      end if;

      if next_state /= current_state then
        tick <= 0; -- restart counting on every state change
      elsif tick < tick'high then
        tick <= tick + 1;
      end if;

    end if;
  end process;

  -- Combinational FSM: next-state logic
  FSM: process (current_state, front_sensor, back_sensor, password_1, password_2, tick)
  begin
    next_state <= current_state; -- default: stay in the same state
    case current_state is
      when IDLE =>
        if front_sensor = '1' then
          next_state <= WAIT_PASSWORD;
          stable <= true; -- password is stable at the beginning of WAIT_PASSWORD
          counter_tick <= 0; -- reset stable_tick counter
        end if;

      when WAIT_PASSWORD =>
        if password_1'event or password_2'event then
          stable <= false; -- password is changing
        else
          if stable = true and counter_tick >= 10 then
            if (password_1 and password_2) = TRUE_PASSWORD then
              next_state <= RIGHT_PASSWORD;
              counter_tick <= 0; -- reset counter
            else
              next_state <= WRONG_PASSWORD;
              counter_tick <= 0; -- reset counter
            end if;
          end if;
        end if;
        if front_sensor = '0' then
          next_state <= IDLE;
          counter_tick <= 0; -- reset counter
        end if;
      when WRONG_PASSWORD =>
        if tick >= 20 then
          next_state <= WAIT_PASSWORD;
          stable <= true; -- password is stable at the beginning of WAIT_PASSWORD
          counter_tick <= 0; -- reset stable_tick counter
        end if;
        if front_sensor = '0' then
          next_state <= IDLE;
          counter_tick <= 0; -- reset counter
        end if;

      when RIGHT_PASSWORD =>
      -- TODO
      when STOP =>
      -- TODO
    end case;
  end process;

  -----------------------------------------------------------------------------
  -- Combinational output logic
  -----------------------------------------------------------------------------
  OUTPUTS: process (current_state)
  begin
    -- defaults: LEDs off, displays off
    GREEN_LED <= '0';
    RED_LED <= '0';
    HEX_1 <= "1111111";
    HEX_2 <= "1111111";

    case current_state is
      when IDLE =>
        null;

      when WAIT_PASSWORD =>
        RED_LED <= '1';
        HEX_1 <= HEX_E;
        HEX_2 <= HEX_n;
      when WRONG_PASSWORD =>
        if (tick mod 2) = 0 then
          RED_LED <= '1';
        else
          RED_LED <= '0';
        end if;
        HEX_1 <= HEX_E;
        HEX_2 <= HEX_E;
      when RIGHT_PASSWORD =>
        if (tick mod 2) = 0 then
          GREEN_LED <= '1';
        else
          GREEN_LED <= '0';
        end if;
        HEX_1 <= HEX_G;
        HEX_2 <= HEX_O;
      when STOP =>
        if (tick mod 2) = 0 then
          RED_LED <= '1';
        else
          RED_LED <= '0';
        end if;
        HEX_1 <= HEX_S;
        HEX_2 <= HEX_P;

    end case;
  end process;

end architecture;
