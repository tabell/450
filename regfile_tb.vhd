--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:43:11 01/27/2015
-- Design Name:   
-- Module Name:   /home/alex/450/alu/regfile_tb.vhd
-- Project Name:  alu
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY regfile_tb IS
END regfile_tb;
 
ARCHITECTURE behavior OF regfile_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT register_file
    PORT(
         clk : IN  std_ulogic;
         rst : IN  std_ulogic;
         rd_index_a : IN  std_ulogic_vector(1 downto 0);
         rd_index_b : IN  std_ulogic_vector(1 downto 0);
         wr_index : IN  std_ulogic_vector(1 downto 0);
         wr_en : IN  std_ulogic;
         wr_data : IN  std_ulogic_vector(7 downto 0);
         rd_data_a : OUT  std_ulogic_vector(7 downto 0);
         rd_data_b : OUT  std_ulogic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_ulogic := '0';
   signal rst : std_ulogic := '0';
   signal rd_index_a : std_ulogic_vector(1 downto 0) := (others => '0');
   signal rd_index_b : std_ulogic_vector(1 downto 0) := (others => '0');
   signal wr_index : std_ulogic_vector(1 downto 0) := (others => '0');
   signal wr_en : std_ulogic := '0';
   signal wr_data : std_ulogic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal rd_data_a : std_ulogic_vector(7 downto 0);
   signal rd_data_b : std_ulogic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: register_file PORT MAP (
          clk => clk,
          rst => rst,
          rd_index_a => rd_index_a,
          rd_index_b => rd_index_b,
          wr_index => wr_index,
          wr_en => wr_en,
          wr_data => wr_data,
          rd_data_a => rd_data_a,
          rd_data_b => rd_data_b
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


      wait for clk_period*5;
      rst <= '1';
      wait for clk_period;
      rst <= '0';
      wait for clk_period*5;
    
      rd_index_a <= "00"; -- Not reading anything yet
      rd_index_b <= "00";
      wr_index <= "00";
      wr_data <= "00000001";
      wr_en <= '0';
      wait for clk_period;
      wr_index <= "01";
      wr_data <= "00000010";
      wr_en <= '1';
      wait for clk_period;
      wr_en <= '0';
      wait for clk_period;
      wr_index <= "10";
      wr_data <= "00000100";
      wr_en <= '1';
      wait for clk_period;
      wr_en <= '0';
      wait for clk_period;
      wr_index <= "11";
      wr_data <= "00001000";
      wr_en <= '1';
      wait for clk_period;
      wr_en <= '0';
      wait for clk_period;
      rd_index_a <= "01";
      wait for clk_period;
      rd_index_a <= "10";
      wait for clk_period;
      rd_index_a <= "11";
      wait for clk_period;
      rd_index_b <= "01";
      wait for clk_period;
      rd_index_b <= "10";
      wait for clk_period;
      rd_index_b <= "11";
      wait for clk_period;

      wait for clk_period*10;

      wait;
   end process;

END;
