library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Car_Parking_System_VHDL is 
generic(ClockFrequencyHz : integer);
port( clk : in std_logic;
        reset_n : in std_logic; -- Active low
        front_sensor: in std_logic;
        back_sensor : in std_logic;
        password_1 : in std_logic_vector(1 downto 0);
        password_2 : in std_logic_vector(1 downto 0);
        GREEN_LED : out std_logic;
        RED_LED : out std_logic;
        HEX_1 : out std_logic_vector(6 downto 0); 
        HEX_2 : out std_logic_vector(6 downto 0);
        car_count: out integer:=0
        );
end Car_Parking_System_VHDL;

architecture arch of Car_Parking_System_VHDL is

    component led_block is
        port (
            clock : in std_logic;
            en : in std_logic;
            led_out : out std_logic
        );
    end component;

    component prescaler is
    generic(
        divider : integer := 10 
    );
    port(
        clk_in  : in  std_logic;
        reset   : in  std_logic;
        clk_out : out std_logic
    );
end component;
    --State declarations

    type FSM_States is (IDLE, WAIT_PASSWORD, WRONG_PASS, RIGHT_PASS, STOP, TIMEOUT);
    signal current_state : FSM_States;
    --Counter
    signal counter_wait : std_logic_vector(7 downto 0):= "00000000";
    signal prescaled_clock: std_logic:='0';
    signal en_green_led : std_logic:='0';
    signal en_red_led : std_logic:='0';
    signal count : integer := 0;


    function is_pass_correct(pw1 : std_logic_vector(1 downto 0); pw2 : std_logic_vector(1 downto 0)) return boolean is
    begin
        if(pw1="01" and pw2="10") then
            return = false;
        else
            return true;
        end if;
    end function;
end arch ;