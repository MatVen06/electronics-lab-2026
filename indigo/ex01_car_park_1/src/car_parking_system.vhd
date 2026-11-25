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

  constant TRUE_PASSWORD : std_logic_vector(3 downto 0) := "0110"; -- password_1 & password_2

  -- tick counter: counts clock cycles spent in the current state
  signal tick : natural range 0 to 255;
  -- Blink signal toggles on every clock edge; drives the blinking LEDs
  signal blink : std_logic;

  signal stable : boolean := true; -- true if password is stable (not changing) for 1 clock cycle

  -- password stability: previous password and number of clock cycles it has
  -- not changed (saturating)
  constant STABLE_CYCLES : natural := 10;
  signal password_prev   : std_logic_vector(3 downto 0);
  signal pw_stable_cnt   : natural range 0 to 15;

  signal state_code      : std_logic_vector(2 downto 0);
  signal next_state_code : std_logic_vector(2 downto 0);

  function encode(s : state_type) return std_logic_vector is
  begin
    case s is
      when IDLE => return "000";
      when WAIT_PASSWORD => return "001";
      when WRONG_PASSWORD => return "010";
      when RIGHT_PASSWORD => return "011";
      when STOP => return "100";
    end case;
  end function;

  -- DISPLAY CONSTANTS
  constant HEX_OFF : std_logic_vector(6 downto 0) := "1111111";
  constant HEX_E   : std_logic_vector(6 downto 0) := "0000110";
  constant HEX_n   : std_logic_vector(6 downto 0) := "0101011";
  constant HEX_G   : std_logic_vector(6 downto 0) := "0000010"; -- Shape of '6'
  constant HEX_O   : std_logic_vector(6 downto 0) := "1000000"; -- Shape of '0'
  constant HEX_S   : std_logic_vector(6 downto 0) := "0100100";
  constant HEX_P   : std_logic_vector(6 downto 0) := "0001100";

begin

  -- debug mirrors of the FSM state (see STATE TABLE above); unused by the
  -- logic, so synthesis removes them
  state_code      <= encode(current_state);
  next_state_code <= encode(next_state);

  -- Clocked data path: state register + tick counter (asynchronous reset)
  DATA_PATH: process (clk, reset_n)
  begin
    if reset_n = '0' then
      current_state <= IDLE;
      tick <= 0;
      blink <= '0';
      password_prev <= (others => '0');
      pw_stable_cnt <= 0;
    elsif rising_edge(clk) then
      current_state <= next_state;
      blink <= not blink; -- toggles on every clock edge

      -- count how long the password has been unchanged
      password_prev <= password_1 & password_2;
      if (password_1 & password_2) /= password_prev then
        pw_stable_cnt <= 0; -- password changed: restart counting
      elsif pw_stable_cnt < 15 then
        pw_stable_cnt <= pw_stable_cnt + 1;
      end if;

      if next_state /= current_state then
        tick <= 0; -- restart counting on every state change
      elsif tick < 255 then
        tick <= tick + 1;
      end if;

    end if;
  end process;

  -- Combinational FSM: next-state logic
  FSM: process (current_state, front_sensor, back_sensor, password_1, password_2, tick, pw_stable_cnt)
  begin
    next_state <= current_state; -- default: stay in the same state
    case current_state is
      when IDLE =>
        if front_sensor = '1' then
          next_state <= WAIT_PASSWORD;
          stable <= true; -- password is stable at the beginning of WAIT_PASSWORD
        end if;

      when WAIT_PASSWORD =>
        if password_1'event or password_2'event then
          stable <= false; -- password is changing
        else
          if tick >= 10 then
            if stable = true and (password_1 & password_2) = TRUE_PASSWORD then
              next_state <= RIGHT_PASSWORD;
            else
              next_state <= WRONG_PASSWORD;
            end if;
          end if;
        end if;
        if front_sensor = '0' then
          next_state <= IDLE;
        end if;
      when WRONG_PASSWORD =>
        -- correct password entered and held stable for 10 clock cycles
        -- (password = password_prev: the count belongs to the current password)
        if (password_1 & password_2) = TRUE_PASSWORD and password_prev = TRUE_PASSWORD
           and pw_stable_cnt >= STABLE_CYCLES then
          next_state <= RIGHT_PASSWORD;
        end if;
        if front_sensor = '0' then
          next_state <= IDLE;
        end if;
      when RIGHT_PASSWORD =>
        if back_sensor = '1' and front_sensor = '1' then
          next_state <= STOP;
        else
          if back_sensor = '1' then
            next_state <= IDLE; -- car has passed the gate
          end if;
        end if;

      when STOP =>
        if back_sensor = '0' then
          next_state <= IDLE;
        end if;
    end case;
  end process;

  -----------------------------------------------------------------------------
  -- Combinational output logic
  -----------------------------------------------------------------------------
  OUTPUTS: process (current_state, tick, blink)
  begin
    -- defaults: LEDs off, displays off
    GREEN_LED <= '0';
    RED_LED <= '0';
    HEX_1 <= HEX_OFF;
    HEX_2 <= HEX_OFF;

    case current_state is
      when IDLE =>
        null;

      when WAIT_PASSWORD =>
        RED_LED <= '1';
        HEX_1 <= HEX_E;
        HEX_2 <= HEX_n;
      when WRONG_PASSWORD =>
        RED_LED <= blink;
        HEX_1 <= HEX_E;
        HEX_2 <= HEX_E;
      when RIGHT_PASSWORD =>
        GREEN_LED <= blink;
        HEX_1 <= HEX_G;
        HEX_2 <= HEX_O;
      when STOP =>
        GREEN_LED <= blink;
        HEX_1 <= HEX_S;
        HEX_2 <= HEX_P;

    end case;
  end process;

end architecture;
