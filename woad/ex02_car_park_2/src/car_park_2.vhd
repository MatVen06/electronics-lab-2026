library ieee;
use ieee.std_logic_1164.all;

entity carPark is 
	port(
		in parking_capacity : int = 0,
		clk : in std_logic;
		payment_done : in STD_LOGIC;
		sensor_A_Gin1 : in STD_LOGIC;
		sensor_B_Gin1 : in STD_LOGIC;
		sensor_A_Gin2 : in STD_LOGIC;
		sensor_B_Gin2 : in STD_LOGIC;
		sensor_A_Gout1 : in STD_LOGIC;
		sensor_B_Gout1 : in STD_LOGIC;
		sensor_A_Gout2 : in STD_LOGIC;
		sensor_B_Gout2 : in STD_LOGIC;
		payment_accepted : out STD_LOGIC;
		payment_request : out STD_LOGIC;
		barrier_Gin_1 : out STD_LOGIC;
		barrier_Gin_2 : out STD_LOGIC;
		barrier_Gout_1 : out STD_LOGIC;
		barrier_Gout_2 : out STD_LOGIC;
		green_light : out STD_LOGIC;
		red_light : out STD_LOGIC;
		display : out STD_LOGIC_VECTOR(6 downto 0)
	    );
end carPark;

architecture FSM of carPark is
	type enter_state_t is (IDLE,CAR_DETECTED,CAR_ENTERING,CAR_ENTERED);
	type exit_state_t is (IDLE,WAIT_PAYMENT,PAYMENT_OK,CAR_EXITING,CAR_EXITED);
	signal state_Gin1,stateGin2,next_Gin1,next_Gin2 : enter_state_t;
	signal state_Gout1,state_Gout2,next_Gin1,next_Gout2 : exit_state_t;
	signal car_count : int;
	signal A_Gin1_prev : std_logic;
	signal B_Gin1_prev : std_logic;
	signal A_Gin2_prev : std_logic;
	signal B_Gin2_prev : std_logic;
	signal A_Gout1_prev : std_logic;
	signal B_Gout2_prev : std_logic;
	signal A_Gout1_prev : std_logic;
	signal B_Gout2_prev : std_logic;


	begin 
		stateregister: process(clk, nrst)
		begin

		end process stateregister;
	end FSM;
end;

