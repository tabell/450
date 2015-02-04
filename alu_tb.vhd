--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:22:43 02/02/2015
-- Design Name:   
-- Module Name:   /home/alex/450/alu/alu_tb.vhd
-- Project Name:  alu
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
library std;
USE ieee.std_logic_textio.ALL;
use std.textio.all;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

ENTITY alu_tb IS
END alu_tb;
 
ARCHITECTURE behavior OF alu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         clk : IN  std_ulogic;
         rst : IN  std_ulogic;
         alu_mode : IN  std_ulogic_vector(2 downto 0);
         in_a : IN  std_ulogic_vector(7 downto 0);
         in_b : IN  std_ulogic_vector(7 downto 0);
         result : OUT  std_ulogic_vector(7 downto 0);
         n : OUT  std_ulogic;
         z : OUT  std_ulogic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_ulogic := '0';
   signal rst : std_ulogic := '0';
   signal alu_mode : std_ulogic_vector(2 downto 0) := (others => '0');
   signal in_a : std_ulogic_vector(7 downto 0) := (others => '0');
   signal in_b : std_ulogic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal result : std_ulogic_vector(7 downto 0);
   signal n : std_ulogic;
   signal z : std_ulogic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          clk => clk,
          rst => rst,
          alu_mode => alu_mode,
          in_a => in_a,
          in_b => in_b,
          result => result,
          n => n,
          z => z
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
    -- test vector stim process
    process is
    file vec_file : text is in "testvectors2.dat";
    variable vec_line : line;
    variable good : boolean;
    variable vec_var : std_ulogic_vector(29 downto 0);
    variable previous_result : std_ulogic_vector(10 downto 0);
    begin
      wait for 105 ns; 
      while not endfile(VEC_FILE) loop
        readline (VEC_FILE, VEC_LINE);
        read (VEC_LINE, VEC_VAR);
        alu_mode <= VEC_VAR(29 downto 27);
        in_a <= VEC_VAR(26 downto 19);
        in_b <= VEC_VAR(18 downto 11);
        wait for clk_period;
        report(integer'image(to_integer(signed(in_a))) & " ? " & integer'image(to_integer(signed(in_b))) & " = " & integer'image(to_integer(signed(result))));
        if (result /= VEC_VAR(10 downto 3)) then
          report("Problem! Expected " & integer'image(to_integer(signed(previous_result(10 downto 3)))) & " but got " & integer'image(to_integer(signed(result))));
        end if;
        previous_result := VEC_VAR(10 downto 0);
      end loop;
      wait;
    end process;
   
   
   ---- Stimulus process
   --stim_proc: process
   --begin		
   --   -- hold reset state for 100 ns.
   --   wait for 100 ns;	

   --   wait for clk_period*10;
      
   --   in_a <= "00001111";
   --   in_b <= "00000001";
   --   alu_mode <= "100";
   --   wait for clk_period;
   --   in_a <= "00011111";
   --   in_b <= "00000001";
   --   alu_mode <= "100";
   --   wait for clk_period;
   --   in_a <= "00111111";
   --   in_b <= "00000001";
   --   alu_mode <= "100";
   --   wait for clk_period;
   --   -- insert stimulus here 

   --   wait;
   --end process;

END;
