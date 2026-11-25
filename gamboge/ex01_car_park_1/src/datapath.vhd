library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity datapath is
port(
    clk         : in std_logic;
    reset_n     : in std_logic; -- active low

    -- display signals
    hex1_display : in std_logic_vector(2 downto 0);
    hex2_display : in std_logic_vector(2 downto 0);
    HEX_1        : out std_logic_vector(6 downto 0); -- segments gfedcba
    HEX_2        : out std_logic_vector(6 downto 0);

    -- counter signals
    count_to_3  : in std_logic;
    count_to_10 : in std_logic;
    clock_3     : out std_logic; 
    clock_10    : out std_logic;
    count       : buffer unsigned(3 downto 0); -- single 4-bit counter

    
    -- led signals
    enable_green : in std_logic; -- control signal to enable green led
    enable_red : in std_logic; -- control signal to enable red led
    GREEN_LED    : out std_logic;
    RED_LED      : out std_logic;
     
    -- comparator signals
    password_1   : in std_logic_vector(1 downto 0);
    password_2   : in std_logic_vector(1 downto 0);
    check_pswd : out std_logic -- 1 if correct password, 0 if incorrect.
);
end datapath;

architecture rtl of datapath is

begin
    counter : process (reset_n, clk) is 
    begin
        if (reset_n = '0') then
            count <= (others => '0'); -- set every bit to 0
        elsif (rising_edge(clk)) then
            if (count_to_10 = '1' or count_to_3 = '1') then
                count <= count + 1;
            elsif (count_to_3 = '0' and count_to_10 = '0') then
                count <= (others => '0');
            end if;
        end if;
    end process counter;

    clock_10 <= '1' when count = "1001" else '0';
    clock_3  <= '1' when count = "0010" else '0'; -- This will be generated while counting to 10 too, but we don't care since it is ignored by the FSM.

    with hex1_display select
            HEX_1 <= "0000110" when "001", -- E
                    "0000010" when "011", -- G
                    "0100100" when "010", -- S
                    "1111111" when others;

    with hex2_display select
        HEX_2 <= "0101011" when "001", -- n
                "1000000" when "101", -- O
                "0000110" when "011", -- E
                "0001100" when "100", -- P
                "1111111" when others;

        GREEN_LED      <= enable_green;
        RED_LED        <= enable_red;

        --check of the password.
		check_pswd <= '1' when (password_1 = '01' and password_2 = '10') else '0';
	
end architecture rtl;


			
