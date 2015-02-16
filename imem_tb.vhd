--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:40:01 02/06/2015
-- Design Name:   
-- Module Name:   /home/alex/450/alu/imem_tb.vhd
-- Project Name:  alu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: imem
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY imem_tb IS
END imem_tb;
 
ARCHITECTURE behavior OF imem_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT imem
    PORT(
         clk : IN  std_ulogic;
         addr : IN  std_ulogic_vector(6 downto 0);
         data : OUT  std_ulogic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_ulogic := '0';
   signal addr : std_ulogic_vector(6 downto 0) := (others => '0');

 	--Outputs
   signal data : std_ulogic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: imem PORT MAP (
          clk => clk,
          addr => addr,
          data => data
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

      for i in 0 to 127 loop
        addr <= std_ulogic_vector(to_unsigned(i,7));
        wait for clk_period*5;
      end loop;
      
      wait for clk_period*10;
      
      

      -- insert stimulus here 


      wait;
   end process;

END;
