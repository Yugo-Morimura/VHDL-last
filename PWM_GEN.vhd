library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PWM_GEN is
    Port ( RST 		: in  STD_LOGIC;
           CLK100MHZ : in  STD_LOGIC;
           THRESHOLD : in  integer;
           PWM_OUT 	: out	STD_LOGIC);
end PWM_GEN;

architecture RTL of PWM_GEN is

signal sawtooth : integer; --for counting 49999

begin

--Generation of 2kHz Sawtooth Wave
process (CLK100MHZ) begin
	if rising_edge(CLK100MHZ) then
		if RST = '1' then
			sawtooth <= 0;
		else
			if sawtooth > 50000 then
				sawtooth <= 0;
			else
				sawtooth <= sawtooth + 1;
			end if;
		end if;
	end if;
end process;

--Generation of PWM Signal
process (CLK100MHZ) begin
	if rising_edge(CLK100MHZ) then
		if sawtooth < THRESHOLD then
			PWM_OUT <= '1';
		else
			PWM_OUT <= '0';
		end if;
	end if;
end process;

end RTL;