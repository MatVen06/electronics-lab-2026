library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Car_Parking_System_tb_1 is
end Car_Parking_System_tb_1;

architecture sim of Car_Parking_System_tb_1 is
    constant CLK_PERIOD : time := 10 ns;

    signal clk          : std_logic := '0';
    signal reset_n      : std_logic := '1';
    signal front_sensor : std_logic := '0';
    signal back_sensor  : std_logic := '0';
    signal password_1   : std_logic_vector(1 downto 0) := (others => '0');
    signal password_2   : std_logic_vector(1 downto 0) := (others => '0');
    signal GREEN_LED    : std_logic;
    signal RED_LED      : std_logic;
    signal HEX_1        : std_logic_vector(6 downto 0);
    signal HEX_2        : std_logic_vector(6 downto 0);
    signal done         : boolean := false;
begin
    -- Device under test
        dut : entity work.Car_Parking_System_VHDL
        port map (
            clk          => clk,
            reset_n      => reset_n,
            front_sensor => front_sensor,
            back_sensor  => back_sensor,
            password_1   => password_1,
            password_2   => password_2,
            GREEN_LED    => GREEN_LED,
            RED_LED      => RED_LED,
            HEX_1        => HEX_1,
            HEX_2        => HEX_2
        );

    -- Clock
    clk <= not clk after CLK_PERIOD/2 when not done else clk;

    stim : process
        function slv_str(v : std_logic_vector) return string is
            variable r : string(1 to v'length);
            variable j : integer := 1;
        begin
            for i in v'range loop
                r(j) := std_logic'image(v(i))(2);
                j := j + 1;
            end loop;
            return r;
        end function;

        procedure gap(n : natural := 10) is
        begin
            for i in 1 to n loop
                wait until falling_edge(clk);
            end loop;
        end procedure;

        -- check bit (duh)
        procedure check_bit(signal s : in std_logic;
                            expected : std_logic;
                            msg      : string) is
        begin
            assert s = expected
                report "FAIL: " & msg &
                       " expected " & std_logic'image(expected) &
                       " got "      & std_logic'image(s)
                severity error;
        end procedure;
 
        -- blink check
        procedure check_blinking(signal s : in std_logic;
                                 msg      : string;
                                 max_cycles : natural := 5000) is
            variable seen0, seen1 : boolean := false;
        begin
            for i in 1 to max_cycles loop
                wait until falling_edge(clk);
                if    s = '0' then seen0 := true;
                elsif s = '1' then seen1 := true;
                end if;
                exit when seen0 and seen1;
            end loop;
            assert seen0 and seen1
                report "FAIL: " & msg & " (signal did not toggle in " &
                       integer'image(max_cycles) & " cycles)"
                severity error;
        end procedure;
 
        -- 7-segment check
        procedure check_hex(signal s : in std_logic_vector;
                            expected : std_logic_vector;
                            msg      : string) is
        begin
            assert s = expected
                report "FAIL: " & msg &
                       " expected " & slv_str(expected) &
                       " got "      & slv_str(s)
                severity error;
        end procedure;
    begin
        -- Reset the system (I also forgor to turn on reset_n once)
        reset_n <= '0';
        gap(5);
        reset_n <= '1';
        gap(5);

        front_sensor <= '1'; -- when i pull up
        gap(1);
        check_bit(RED_LED, '1', "Red LED is not on"); -- not checking for hex because it was never mentioned
        gap(9);
        password_1 <= "01"; password_2 <= "10";
        check_blinking(GREEN_LED, "Green LED is not blinking", 10);
        check_hex(HEX_1,"0000010", "Hex 1 is not correct"); -- G
        check_hex(HEX_2, "1000000", "Hex 2 is not correct"); -- O

        back_sensor <= '1';
        front_sensor <= '0';
        gap(1);

        -- check that state is IDLE
        check_bit(RED_LED, '0', "Red LED is on during IDLE");
        check_bit(GREEN_LED, '0', "Green LED is on during IDLE");
        check_hex(HEX_1, "1111111", "display 1 is on during IDLE");
        check_hex(HEX_2, "1111111", "display 2 is on during IDLE");

        report "Testbench finished" severity note;
        done <= true;
        wait;
    end process;
end sim;