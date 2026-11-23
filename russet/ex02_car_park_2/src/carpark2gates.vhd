library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Parking_Controller is
    generic (
        PARKING_CAPACITY : integer := 7
    );
    port (
        -- Clock and reset
        clk              : in  std_logic;
        nrst             : in  std_logic;

        -- Entry gate sensors
        sensor_A_Gin1    : in  std_logic;
        sensor_B_Gin1    : in  std_logic;
        sensor_A_Gin2    : in  std_logic;
        sensor_B_Gin2    : in  std_logic;

        -- Exit gate sensors
        sensor_A_Gout1   : in  std_logic;
        sensor_B_Gout1   : in  std_logic;
        sensor_A_Gout2   : in  std_logic;
        sensor_B_Gout2   : in  std_logic;

        -- Payment interface
        payment_done     : in  std_logic;
        payment_accepted : out std_logic;
        payment_request  : out std_logic;

        -- Barriers ('1' = open)
        barrier_Gin1     : out std_logic;
        barrier_Gin2     : out std_logic;
        barrier_Gout1    : out std_logic;
        barrier_Gout2    : out std_logic;

        -- Visual indicators
        Green_Light      : out std_logic;
        Red_Light        : out std_logic;
        display          : out std_logic_vector(6 downto 0)
    );
end entity;

architecture Behavioral of Parking_Controller is
begin
end architecture;