library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_car_parking is
end entity tb_car_parking;

architecture sim of tb_car_parking is

    -- Component declaration
    component Car_Parking_System_VHDL
    port(
        clk         : in std_logic;
        reset_n     : in std_logic;
        front_sensor: in std_logic;
        back_sensor : in std_logic;
        password_1  : in std_logic_vector(1 downto 0);
        password_2  : in std_logic_vector(1 downto 0);
        GREEN_LED   : out std_logic;
        RED_LED     : out std_logic;
        HEX_1       : out std_logic_vector(6 downto 0);
        HEX_2       : out std_logic_vector(6 downto 0)
    );
    end component;

    -- Signals for stimulus
    signal clk         : std_logic := '0';
    signal reset_n     : std_logic := '0';
    signal front_sens  : std_logic := '0';
    signal back_sens   : std_logic := '0';
    signal pass_1      : std_logic_vector(1 downto 0) := "00";
    signal pass_2      : std_logic_vector(1 downto 0) := "00";
    
    -- Signals for monitoring outputs
    signal green_led_s : std_logic;
    signal red_led_s   : std_logic;
    signal hex1_s      : std_logic_vector(6 downto 0);
    signal hex2_s      : std_logic_vector(6 downto 0);

    -- Clock period constant
    constant clk_period : time := 10 ns;

    -- Constants for Display Verification
    constant SEG_E : std_logic_vector(6 downto 0) := "0000110";
    constant SEG_G : std_logic_vector(6 downto 0) := "0000010";
    constant SEG_O : std_logic_vector(6 downto 0) := "1000000";
    constant SEG_S : std_logic_vector(6 downto 0) := "0100100";
    constant SEG_P : std_logic_vector(6 downto 0) := "0001100";

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: Car_Parking_System_VHDL
    port map (
        clk          => clk,
        reset_n      => reset_n,
        front_sensor => front_sens,
        back_sensor  => back_sens,
        password_1   => pass_1,
        password_2   => pass_2,
        GREEN_LED    => green_led_s,
        RED_LED      => red_led_s,
        HEX_1        => hex1_s,
        HEX_2        => hex2_s
    );

    -- Clock generation process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Inizializzazione e Reset
        reset_n <= '0';
        front_sens <= '0';
        back_sens <= '0';
        pass_1 <= "00";
        pass_2 <= "00";
        wait for clk_period * 2;
        reset_n <= '1';
        wait for clk_period * 2;

        -----------------------------------------------------------
        -- Scenario 2: Wrong Password
        -----------------------------------------------------------
        report "--- Inizio Scenario 2: Wrong Password ---";
        
        -- 1. Assert front_sensor = '1'
        front_sens <= '1';
        
        -- 2. Wait 10+ clock cycles
        wait for clk_period * 12; 
        
        -- 3. Input wrong password
        pass_1 <= "00"; 
        pass_2 <= "00";
        wait for clk_period * 2; 

        -- 4. Verify: RED LED blinks, display shows "EE"
        -- Verifichiamo che il display mostri 'E' (0000110) su entrambi i segmenti
        assert (hex1_s = SEG_E and hex2_s = SEG_E) 
            report "Errore Scenario 2: Il display non mostra 'EE'" severity error;
        
        -- 5. Input correct password ("01" & "10")
        pass_1 <= "01";
        pass_2 <= "10";
        wait for clk_period * 2;

        -- 6. Verify: System transitions to RIGHT_PASS
        -- In RIGHT_PASS il display mostra 'GO' (G=0000010, O=1000000)
        assert (hex1_s = SEG_G and hex2_s = SEG_O) 
            report "Errore Scenario 2: Il sistema non e' passato a RIGHT_PASS" severity error;

        -----------------------------------------------------------
        -- Scenario 3: Multiple Cars
        -----------------------------------------------------------
        report "--- Inizio Scenario 3: Multiple Cars ---";
        
        -- 1. Car 1 enters with correct password -> RIGHT_PASS 
        -- (Il sistema si trova gia' in RIGHT_PASS grazie allo step precedente)
        
        -- 2. Before back_sensor = '1', assert front_sensor = '1' again
        -- Per simulare la condizione in cui un'auto è sul retro e un'altra sul fronte:
        front_sens <= '1';
        back_sens <= '1';
        wait for clk_period * 2;

        -- 3. Verify: System enters STOP state
        -- In STOP il display mostra 'SP' (S=0100100, P=0001100)
        assert (hex1_s = SEG_S and hex2_s = SEG_P) 
            report "Errore Scenario 3: Il sistema non e' passato allo stato STOP" severity error;

        -- Il comportamento descritto nel codice per elaborare la seconda auto richiede 
        -- prima che il sensore posteriore si liberi (auto 1 completamente uscita)
        back_sens <= '0';
        wait for clk_period * 2;
        -- Adesso il sistema ritorna automaticamente in WAIT_PASSWORD per l'auto 2
        
        -- Attendiamo i 10 clock cycle necessari per lo stato WAIT_PASSWORD
        wait for clk_period * 12;

        -- 4. Input correct password for car 2
        pass_1 <= "01";
        pass_2 <= "10";
        wait for clk_period * 2;

        -- 5. Verify: Both cars processed correctly
        -- Verifichiamo che l'auto 2 sia stata autorizzata e mostri "GO"
        assert (hex1_s = SEG_G and hex2_s = SEG_O) 
            report "Errore Scenario 3: L'auto 2 non e' passata in RIGHT_PASS" severity error;

        -- Chiudiamo lo scenario liberando il varco per permettere al sistema di tornare IDLE
        front_sens <= '0';
        back_sens <= '1'; -- La seconda auto esce
        wait for clk_period * 2;
        back_sens <= '0';
        
        report "--- Simulazione Completata ---";
        wait;
    end process;

end architecture sim;