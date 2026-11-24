library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Car_Parking_System_VHDL is
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;       -- active low, asynchronous
        front_sensor : in  std_logic;
        back_sensor  : in  std_logic;
        password_1   : in  std_logic_vector(1 downto 0);
        password_2   : in  std_logic_vector(1 downto 0);
        GREEN_LED    : out std_logic;
        RED_LED      : out std_logic;
        HEX_1        : out std_logic_vector(6 downto 0); -- segments gfedcba
        HEX_2        : out std_logic_vector(6 downto 0)  
    );
end Car_Parking_System_VHDL;

architecture Behavioral of Car_Parking_System_VHDL is

    type state_type is (IDLE, WAIT_PASSWORD, WRONG_PASS, RIGHT_PASS, STOP);
    signal current_state, next_state : state_type;

    signal counter : unsigned(3 downto 0) := (others => '0');
    signal pass_correct : std_logic;
    
    constant DISP_OFF : std_logic_vector(6 downto 0) := "1111111";
    constant DISP_E   : std_logic_vector(6 downto 0) := "0000110";
    constant DISP_N   : std_logic_vector(6 downto 0) := "0101011";
    constant DISP_G   : std_logic_vector(6 downto 0) := "0000010";
    constant DISP_O   : std_logic_vector(6 downto 0) := "1000000";
    constant DISP_S   : std_logic_vector(6 downto 0) := "0100100";
    constant DISP_P   : std_logic_vector(6 downto 0) := "0001100";

begin

    pass_correct <= '1' when (password_1 = "01" and password_2 = "10") else '0';

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            current_state <= IDLE;
            counter <= (others => '0');
        elsif rising_edge(clk) then
            current_state <= next_state;
            
            if current_state = WAIT_PASSWORD then
                if counter < 10 then
                    counter <= counter + 1;
                end if;
            else
                counter <= (others => '0');
            end if;
        end if;
    end process;

    process(current_state, front_sensor, back_sensor, pass_correct, counter, clk)
    begin
        next_state <= current_state;
        GREEN_LED  <= '0';
        RED_LED    <= '0';
        HEX_1      <= DISP_OFF;
        HEX_2      <= DISP_OFF;

        case current_state is

            when IDLE =>
                HEX_1 <= DISP_OFF;
                HEX_2 <= DISP_OFF;
                if front_sensor = '1' then
                    next_state <= WAIT_PASSWORD;
                end if;

            when WAIT_PASSWORD =>
                RED_LED <= '1'; 
                HEX_2   <= DISP_E;
                HEX_1   <= DISP_N;
                
                if counter >= 10 then
                    if pass_correct = '1' then
                        next_state <= RIGHT_PASS;
                    else
                        next_state <= WRONG_PASS;
                    end if;
                end if;

            when WRONG_PASS =>
                RED_LED <= clk; 
                HEX_2   <= DISP_E;
                HEX_1   <= DISP_E;
                
                if pass_correct = '1' then
                    next_state <= RIGHT_PASS;
                end if;

            when RIGHT_PASS =>
                GREEN_LED <= clk; 
                HEX_2     <= DISP_G;
                HEX_1     <= DISP_O;

                if front_sensor = '1' and back_sensor = '1' then
                    next_state <= STOP;
                elsif back_sensor = '1' then
                    next_state <= IDLE;
                end if;

            when STOP =>
                RED_LED <= clk; 
                HEX_2   <= DISP_S;
                HEX_1   <= DISP_P;

                if pass_correct = '1' then
                    next_state <= RIGHT_PASS;
                end if;

        end case;
    end process;

end Behavioral;
