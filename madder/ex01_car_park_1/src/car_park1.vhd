library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Car_Parking_System_VHDL is
port(
    clk : in std_logic;
    reset_n : in std_logic; -- active low, asynchronous
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

architecture cp of Car_Parking_System_VHDL is
    type state_t is (IDLE, WAIT_PASSWORD, WRONG_PASS, RIGHT_PASS, STOP);
    signal state, next_state : state_t;
    signal counter : unsigned(3 downto 0) := "0000"; -- to make it a mathamatical number we use unsogned instead of std_logic_vector--
    signal blink_phase : std_logic := '0';
    
    constant pass1_ok : std_logic_vector(1 downto 0) := "01";
    constant pass2_0k : std_logic_vector(1 downto 0) := "10";

    constant SEG_OFF : std_logic_vector(6 downto 0) := "1111111";
    constant SEG_E : std_logic_vector(6 downto 0) := "0000110";
    constant SEG_N : std_logic_vector(6 downto 0) := "0101011";
    constant SEG_G : std_logic_vector(6 downto 0) := "0000010";
    constant SEG_O : std_logic_vector(6 downto 0) := "1000000";
    constant SEG_S : std_logic_vector(6 downto 0) := "0100100";
    constant SEG_P : std_logic_vector(6 downto 0) := "0001100";

    begin

        process(clk, reset_n)
        begin 
            if reset_n = '0' then
                state       <= IDLE;
                counter     <= (others => '0');
                blink_phase <= '0';
            elsif rising_edge(clk) then 
                state       <= next_state;
                blink_phase <= not blink_phase;

                if state /= next_state then
                    counter <= (others => '0');
                elsif state = WAIT_PASSWORD then 
                    if counter < 10 then
                        counter <= counter + 1;
                    end if;
                elsif state = WRONG_PASS then
                    if counter < 12 then
                        counter <= counter + 1;
                    end if;
                else 
                    counter <= (others => '0');
                end if;
            end if;
        end process;

        process(state,front_sensor,back_sensor,password_1,password_2,counter)
        variable pw_ok : boolean;

        begin
            next_state <= state;
            pw_ok := (password_1 = pass1_ok) and (password_2 = pass2_0k);

            case state is
                when IDLE => 
                    if front_sensor = '1' then
                        next_state <= WAIT_PASSWORD;
                    end if;
                    
                when WAIT_PASSWORD =>
                    if counter = 10 then
                        if pw_ok then 
                            next_state <= RIGHT_PASS;
                        else 
                            next_state <= WRONG_PASS;
                        end if;
                    end if;

                when WRONG_PASS =>
                    if counter = 12 then
                        next_state <= WAIT_PASSWORD;
                    end if;
                
                when RIGHT_PASS =>
                    if front_sensor = '1' and back_sensor = '1' then
                        next_state <= STOP;
                    elsif back_sensor = '1' then 
                        next_state <= IDLE;
                    end if;

                when STOP => 
                    if back_sensor = '0' then 
                        next_state <= WAIT_PASSWORD;
                    end if;
            end case;
        end process;

        process(state,blink_phase)
        begin
            GREEN_LED <= '0';
            RED_LED <= '0';
            HEX_1 <= SEG_OFF;
            HEX_2 <= SEG_OFF;

            case state is 
                when IDLE =>


                when WAIT_PASSWORD =>
                    RED_LED <= '1';    
                    HEX_1   <= SEG_E;
                    HEX_2   <= SEG_N;

                when WRONG_PASS =>
                    RED_LED <= blink_phase;         
                    HEX_1   <= SEG_E;
                    HEX_2   <= SEG_E;

                when RIGHT_PASS =>
                    GREEN_LED <= blink_phase;       
                    HEX_1     <= SEG_G;
                    HEX_2     <= SEG_O;

                when STOP =>
                    RED_LED <= blink_phase;        
                    HEX_1   <= SEG_S;
                    HEX_2   <= SEG_P;
            end case;
        end process;

    end cp;


