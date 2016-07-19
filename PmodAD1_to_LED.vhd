library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PmodAD1_to_LED is
    Port ( RST 		: in  STD_LOGIC;							--RESET
           CLK100MHZ : in  STD_LOGIC;							--On Board 100MHz CLK
           CSB_OUT 	: out STD_LOGIC;							--ADC Module
           SCLK_OUT 	: out STD_LOGIC;							--ADC Module
           SDATA_INP : in  STD_LOGIC;							--ADC Module
           LED 		: out STD_LOGIC_VECTOR(7 downto 0);	--LED
			  KP_INP		: in 	STD_LOGIC_VECTOR(7 downto 0);
			  DIR_R		: out STD_LOGIC;
			  PWM_R		: out STD_LOGIC;
			  DIR_L		: out STD_LOGIC;
			  PWM_L		: out STD_LOGIC;
			  BOTTON		: in	STD_LOGIC
			  );
end PmodAD1_to_LED;

architecture RTL of PmodAD1_to_LED is

component PmodAD1
	Port ( RST			: in 	STD_LOGIC;
			 CLK100MHZ	: in	STD_LOGIC;
			 CSB			: out STD_LOGIC;
			 SCLK			: out STD_LOGIC;
			 SDATA		: in	STD_LOGIC;
			 DB			: out STD_LOGIC_VECTOR(11 downto 0)
			);
end component;

component PWM_GEN
	Port ( RST			: in STD_LOGIC;
			 CLK100MHZ	: in STD_LOGIC;
			 THRESHOLD	: in integer;
			 PWM_OUT		: out STD_LOGIC
			);
end component;

--Signals for 1kHz CLK
signal count_clk100mhz_1k	: integer;
signal clk1khz					: STD_LOGIC;

--Signals for PID FeedBack Signal
signal db_in 			: STD_LOGIC_VECTOR(11 downto 0);
signal angle_in		: integer;
signal angle_ref		: integer;
signal error			: integer;
signal integ_error	: integer;
signal error_old		: integer;
signal diff_error		: integer;
signal kp_in			: integer;
signal freq				: integer;
signal Fu				: integer;
signal u					: integer;

--Signals for PWM & Direction Signals
signal threshold_in	: integer;
signal pwm_in			: std_logic;
signal dir_in			: std_logic;

begin

--Generation of 1kHz CLK
process (CLK100MHZ) begin
	if rising_edge(CLK100MHZ) then
		if rst = '1' then
			count_clk100mhz_1k <= 0;
			clk1khz <= '0';
		else
			count_clk100mhz_1k <= count_clk100mhz_1k + 1;
			if count_clk100mhz_1k = 49999 then
				clk1khz <= not clk1khz;
				count_clk100mhz_1k <= 0;
			end if;
		end if;
	end if;
end process;

--Angle from ADC
Subunit1 : PmodAD1
port map(RST, CLK100MHZ, CSB_OUT, SCLK_OUT, SDATA_INP, db_in);
angle_in	<= to_integer(unsigned(db_in));

--Sample of Reference angle
process (CLK100MHZ) begin
	if rising_edge(CLK100MHZ) then
		if botton = '1' then
			angle_ref <= angle_in;
		end if;
	end if;
end process;

--PID Feedback Signal
error		<= angle_in - angle_ref;
kp_in		<=	to_integer(unsigned(KP_INP)) * 64;	--Proportional Gain
freq		<= 1000;											--Frequency of PID Process
Fu			<= 5;												--Oscillation Frequency at Critical point

process (clk1khz, CLK100MHZ) begin
	if (CLK100MHZ = '1') and ((rst = '1') or (botton = '1')) then
		integ_error <= 0;
		error_old	<= 0;
	elsif rising_edge(clk1khz) then
		integ_error	<= integ_error + error;
		diff_error	<= error - error_old;
		error_old	<= error;
		--PID Signal based on Ziegler-Nichols
		u <= kp_in * error;
	end if;
end process;

--PWM Signal
threshold_in <= abs(u);
Subunit2 : PWM_GEN
port map(RST, CLK100MHZ, threshold_in, pwm_in);

--direction Signal
process (CLK100MHZ) begin
	if rising_edge(CLK100MHZ) then
		if u < 0 then
			dir_in <= '1';
		else
			dir_in <= '0';
		end if;
	end if;
end process;

LED <= std_logic_vector(to_unsigned(threshold_in/512,LED'length));
PWM_R <= pwm_in;
DIR_R <= dir_in;
PWM_L <= pwm_in;
DIR_L <= not dir_in;

end RTL;