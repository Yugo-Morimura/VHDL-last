library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PmodAD1 is
  Port ( RST       : in  STD_LOGIC;
         CLK100MHz : in  STD_LOGIC;
         CSB       : out STD_LOGIC;
			SCLK      : out STD_LOGIC;
         SDATA     : in  STD_LOGIC;
         DB        : out STD_LOGIC_VECTOR (11 downto 0));
end PmodAD1;

architecture RTL of PmodAD1 is

signal Count_CLK100MHz : integer;
signal Count_SCLK_R    : integer;
signal CSB_IN          : STD_LOGIC;
signal SCLK_IN         : STD_LOGIC;
signal DB_IN           : STD_LOGIC_VECTOR (11 downto 0);

begin

-- Generation of 5MHz System Clock
process (CLK100MHz) begin
  if rising_edge(CLK100MHz) then
    if RST = '1' then 
      Count_CLK100MHz <= 0;
      SCLK_IN <= '0';
    else
  	   Count_CLK100MHz <= Count_CLK100MHz + 1;
      if Count_CLK100MHz >= 9 then
	     SCLK_IN <= not SCLK_IN;
  		  Count_CLK100MHz <= 0;
	   end if;
    end if;
  end if;
end process;

-- Generation of Counters
process (SCLK_IN, CLK100MHz) begin
  if CLK100MHz='1' and RST = '1' then
    Count_SCLK_R <= 0;
    CSB_IN <= '0';
  elsif rising_edge(SCLK_IN) then
    Count_SCLK_R <= Count_SCLK_R + 1;
    if Count_SCLK_R >= 19 then
  	   Count_SCLK_R <= 0;
	 end if;
	 if Count_SCLK_R < 18 then
	   CSB_IN <= '0';
	 else 
	   CSB_IN <= '1';
	 end if;
  end if;
end process;

-- Sample of AD Data
process (SCLK_IN, CLK100MHz) begin
  if CLK100MHz='1' and RST = '1' then
    DB_IN <= "000000000000";
    DB    <= "000000000000";	 
  elsif rising_edge(SCLK_IN) then
    if    Count_SCLK_R = 4 then
      DB_IN(11) <= SDATA;
    elsif Count_SCLK_R = 5 then
      DB_IN(10) <= SDATA;
    elsif Count_SCLK_R = 6 then
      DB_IN(9) <= SDATA;
    elsif Count_SCLK_R = 7 then
      DB_IN(8) <= SDATA;
    elsif Count_SCLK_R = 8 then
      DB_IN(7) <= SDATA;
    elsif Count_SCLK_R = 9 then
      DB_IN(6) <= SDATA;
    elsif Count_SCLK_R = 10 then
      DB_IN(5) <= SDATA;
    elsif Count_SCLK_R = 11 then
      DB_IN(4) <= SDATA;
    elsif Count_SCLK_R = 12 then
      DB_IN(3) <= SDATA;
    elsif Count_SCLK_R = 13 then
      DB_IN(2) <= SDATA;
    elsif Count_SCLK_R = 14 then
      DB_IN(1) <= SDATA;
    elsif Count_SCLK_R = 15 then
      DB_IN(0) <= SDATA;
    elsif Count_SCLK_R = 16 then
      DB <= DB_IN;
	 end if;
  end if;
end process;

CSB  <= CSB_IN;
SCLK <= SCLK_IN;

end RTL;