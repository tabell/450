--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:09:18 02/07/2015
-- Design Name:   
-- Module Name:   C:/Users/alexlaj/test/test/alu_test.vhd
-- Project Name:  test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_ulogic and
-- std_ulogic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY alu_test IS
END alu_test;
 
ARCHITECTURE behavior OF alu_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         in_a : 		IN  std_ulogic_vector(7 downto 0);
         in_b : 		IN  std_ulogic_vector(7 downto 0);
         alu_mode : 	IN  std_ulogic_vector(2 downto 0);
         clk : 		IN  std_ulogic;
         rst : 		IN  std_ulogic;
         result : 	OUT std_ulogic_vector(7 downto 0);
         z : 	OUT std_ulogic;
         n : 	OUT std_ulogic
        );
    END COMPONENT;
    

   --Inputs
   signal in_a : 		std_ulogic_vector(7 downto 0) := (others => '0');
   signal in_b : 		std_ulogic_vector(7 downto 0) := (others => '0');
   signal alu_mode : std_ulogic_vector(2 downto 0) := (others => '0');
   signal clk : 		std_ulogic := '0';
   signal rst : 		std_ulogic := '0';

 	--Outputs
   signal result : std_ulogic_vector(7 downto 0);
   signal z : std_ulogic;
   signal n : std_ulogic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          in_a => in_a,
          in_b => in_b,
          alu_mode => alu_mode,
          clk => clk,
          rst => rst,
          result => result,
          z => z,
          n => n
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here
		-- add two +
		--pass
		in_a <= "00000001";
		in_b <= "00000001";
		alu_mode <= "100";
		wait for 100 ns;	
		-- add two -
		--pass
		in_a <= std_ulogic_vector(to_signed(-3,8));
		in_b <= std_ulogic_vector(to_signed(-2,8));
		alu_mode <= "100";
		wait for 100 ns;
		-- add - and +, result -
		--pass
		in_a <= std_ulogic_vector(to_signed(-3,8));
		in_b <= std_ulogic_vector(to_signed(2,8));
		alu_mode <= "100";
		wait for 100 ns;		
		-- add - and +, result +
		--pass
		in_a <= std_ulogic_vector(to_signed(3,8));
		in_b <= std_ulogic_vector(to_signed(-2,8));
		alu_mode <= "100";
		wait for 100 ns;		
		-- add - and +, result 0
		--pass
		in_a <= std_ulogic_vector(to_signed(-3,8));
		in_b <= std_ulogic_vector(to_signed(3,8));
		alu_mode <= "100";
		wait for 100 ns;		
		-- sub + and +
		--pass
		alu_mode <= "101";
		in_a <= std_ulogic_vector(to_signed(4,8));
		in_b <= std_ulogic_vector(to_signed(1,8));
		alu_mode <= "101";
		wait for 100 ns;
		-- sub - and +
		--pass
		in_a <= std_ulogic_vector(to_signed(-3,8));
		in_b <= std_ulogic_vector(to_signed(2,8));
		alu_mode <= "101";
		wait for 100 ns;
		-- sub + and -
		-- pass
		in_a <= std_ulogic_vector(to_signed(3,8));
		in_b <= std_ulogic_vector(to_signed(-2,8));
		alu_mode <= "101";
		wait for 100 ns;
		-- sub - and -, result +
		--pass
		in_a <= std_ulogic_vector(to_signed(-1,8));
		in_b <= std_ulogic_vector(to_signed(-2,8));
		alu_mode <= "101";
		wait for 100 ns;
		-- sub - and -, result -
		--pass
		in_a <= std_ulogic_vector(to_signed(-3,8));
		in_b <= std_ulogic_vector(to_signed(-2,8));
		alu_mode <= "101";
		wait for 100 ns;
		-- nand
		--pass
		in_a <= std_ulogic_vector(to_signed(1,8));
		in_b <= std_ulogic_vector(to_signed(2,8));
		alu_mode <= "110";
		wait for 100 ns;
		-- shift left
		--pass
		in_a <= std_ulogic_vector(to_signed(2,8));
		in_b <= std_ulogic_vector(to_signed(2,8));
		alu_mode <= "111";
		wait for 100 ns;
		-- shift right
		--pass
		in_a <= std_ulogic_vector(to_signed(4,8));
		in_b <= std_ulogic_vector(to_signed(2,8));
		alu_mode <= "000";
		wait for 100 ns;
      wait;
   end process;

END;
