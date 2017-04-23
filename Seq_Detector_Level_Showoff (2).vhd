----------------------------------------------------------------------------------
-- Company: Advanced Hardware Design
-- Designer: Vinayaka Jyothi
-- 
-- Create Date:    18:42:44 11/28/2016 
-- Design Name: Sequence Detector: Level - SHOWOFF
-- Module Name:  Seq_Detector_Level_Showoff - Structural 
-- Project Name: Hardware Solution Design
-- Target Devices: ANY FPGAs
-- Tool versions: ISE, Vivado
-- Description: 4-bit Sequence detector design using Non-deterministic Automata (NFA). Asynchrounous reset
--					 This can be used to match any sequence without any modifications (overlapping and non-overlapping).
--              In NFA, multiple states are active at the same time. (It takes time to understand how it works - test the design yourself and learn)
--					 On a match, the detected is raised high for one clock cycle and the count is incremented.  
--
-- Dependencies: NONE 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: VVVV IMPORTANT: Always Include the vhd files containing the components description in the project. 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all; --(REMEMBER THIS LINE -- MEMORIZE IT -- YOU NEED IT FOR YOUR DESIGN WHEN YOU WANT TO "+" or "-" OPERATIONS.

entity Seq_Detector_Level_Showoff is
port(InBit,CLK,RST:in std_logic;
		targetSeq:in std_logic_vector(3 downto 0);
		detectedCount:out std_logic_vector(3 downto 0);
		detected: out std_logic
     );		
end Seq_Detector_Level_Showoff;

architecture Behavioral of Seq_Detector_Level_Showoff is
signal detectedFlag: std_logic;
signal count: std_logic_vector(3 downto 0);

component Comparator1Bit is
	PORT(
		A : IN std_logic;
		B : IN std_logic;          
		OUTP : OUT std_logic
		);
end component;

component D_FlipFlop is
	PORT(
		RST: IN std_logic;
		Clk : IN std_logic;
		Din : IN std_logic;  
		Dout: OUT std_logic
		);
end component;
signal compRes,and_out: std_logic_vector(3 downto 0);
signal s0,s1,s2,s3: std_logic; 

begin

---------------- Comparators Instantiation -------------------------------
CompareTargetBit3 : Comparator1Bit PORT MAP(A => InBit,B => targetSeq(3) , OUTP => compRes(3));
CompareTargetBit2 : Comparator1Bit PORT MAP(A => InBit,B => targetSeq(2), OUTP => compRes(2));
CompareTargetBit1 : Comparator1Bit PORT MAP(A => InBit,B => targetSeq(1), OUTP => compRes(1));
CompareTargetBit0 : Comparator1Bit PORT MAP(A => InBit,B => targetSeq(0), OUTP => compRes(0));

------------------ Flip Flop Instantiaion and Connecting the and Gates (Refer the RTL Model)-----
FFBit3  : D_FlipFlop PORT MAP (RST => RST, Clk => Clk, Din => '1', Dout=> s0); -- Output of the Flip flop is a state - This is state0; Unlike in FSM, all the states can be active at the same time.
ANDBit3 : and_out(3) <= s0 and compRes(3);  -- The result of and gate is fed to the next flip, until the clock edge comes this output will not be transferred to next state.

FFBit2  : D_FlipFlop PORT MAP (RST => RST, Clk => Clk, Din => and_out(3), Dout=> s1); -- Output of the Flip flop is a state - This is state1
ANDBit2 : and_out(2) <= s1 and compRes(2); 

FFBit1  : D_FlipFlop PORT MAP (RST => RST, Clk => Clk, Din => and_out(2), Dout=> s2); -- Output of the Flip flop is a state - This is state2
ANDBit1 : and_out(1) <= s2 and compRes(1); 

FFBit0  : D_FlipFlop PORT MAP (RST => RST, Clk => Clk, Din => and_out(1), Dout=> s3); -- Output of the Flip flop is a state - This is state3
ANDBit0 : and_out(0) <= s3 and compRes(0); 

FFBitEnd  : D_FlipFlop PORT MAP (RST => RST, Clk => Clk, Din =>and_out(0), Dout=> s4); -- Output of the Flip flop is a state - This is state3
 
-----------------------------------------------------------------------------				
-- This increments the count when detect is high, works for any sequence.	
process(clk,rst)
	begin
		if rst='1' then
				detectedFlag<='0'; 
				count<=(OTHERS=>'0'); -- Reset count on active high reset 
			elsif rising_edge(clk) then
				if and_out(0)='1' then -- The last And gate output tells if the sequence is detected. 
						detectedFlag <= '1';        -- Raise detected flag high 
						count<=count+'1'; -- When detectedFlag is high, increment the count
					else 
						detectedFlag <= '0';		  -- Need to reset the detected flag to 0 when there is no match, else after single detection it will be always high 
						count <= count;	-- When detectedFlag is not high, do not increment the count	  
				end if;		
		end if;			
end process;	



-- Connect the necessary signals to output (Remember, your output ports cannot be used for comparsions or cannot appear in Right hand side of the equation
detected<= detectedFlag;
detectedCount<=count; 

end Behavioral;

------ That's all.. That's all Folks...

----- COMPONENT'S HARDWARE DESCRIPTION/DEFINITIONS ---

-------- THis file contains both D Flip Flop and Comparator hardware in 1 file ------

-----------------------------------------
---------- COMPARATOR -------------------
-----------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity Comparator1Bit is
	PORT(
		A : IN std_logic;
		B : IN std_logic;          
		OUTP : OUT std_logic
		);
end Comparator1Bit;

architecture Behavioral of Comparator1Bit is
Begin
	process(A,B)
		begin  
			if (A = B ) then  
					OUTP <= '1';
				else  
					OUTP <= '0';
			end if;
	end process;
END Behavioral;

-----------------------------------------
----- D FLIP FLOP -----------------------
-----------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity D_FlipFlop is
	PORT(
		RST: IN std_logic;
		Clk : IN std_logic;
		Din : IN std_logic;  
		Dout: OUT std_logic
		);
end D_FlipFlop;

architecture Behavioral of D_FlipFlop is
	Begin
		process(Clk,RST)
			begin  
				if RST='1' then
						Dout <= '0';
					elsif (rising_edge(Clk)) then  
						Dout <= Din;
				end if;
	end process;
END Behavioral;
