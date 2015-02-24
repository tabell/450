----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:50:52 02/06/2015 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
Port (
	clk : in std_ulogic;
	rst : in std_ulogic;
	int : in std_ulogic; -- interrupt
	in_port : in std_ulogic_vector(7 downto 0);
	out_port : out std_ulogic_vector(7 downto 0)
	);
end cpu;

architecture Behavioral of cpu is
-- common nonarchitectural registers
signal pc : std_ulogic_vector(6 downto 0) := (others => '0');
signal reg_r_index_a : std_ulogic_vector(1 downto 0) := (others => '0');
signal reg_r_index_b : std_ulogic_vector(1 downto 0) := (others => '0');
signal reg_wr_index : std_ulogic_vector(1 downto 0) := (others => '0');
signal reg_w_en : std_ulogic;

signal reg_r_data_a : std_ulogic_vector(7 downto 0) := (others => '0');
signal reg_r_data_b : std_ulogic_vector(7 downto 0) := (others => '0');
signal reg_w_data : std_ulogic_vector(7 downto 0) := (others => '0');

-- fetch-decode nonarchitectural registers
signal ifid_instr : std_ulogic_vector(7 downto 0);

-- decode-execute nonarchitectural registers
signal idex_opcode : std_ulogic_vector(3 downto 0);
signal idex_rega : std_ulogic_vector(1 downto 0);
signal idex_regb : std_ulogic_vector(1 downto 0);

-- execute-memory nonarchitectural registers
-- memory-writeback nonarchitectural registers
signal in_port_data : std_ulogic_vector(7 downto 0) := (others => '0');

begin

  -- entity declarations for instantiations
  rom : entity work.imem port map(clk, pc, ifid_instr);
  regfile : entity work.register_file port map(clk, rst, reg_r_index_a, reg_r_index_b, 
                        reg_wr_index, reg_w_en, reg_w_data, reg_r_data_a, reg_r_data_b);
  datapath: process(clk)
  begin
    if rising_edge(clk) then
      
    end if;
  end process;

ctrlpath: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pc <= "0000000";
      else
      -- fetch
        pc <= std_ulogic_vector(unsigned(pc) + 1);
      -- decode (type A)
        idex_opcode <= ifid_instr(7 downto 4);
        idex_rega   <= ifid_instr(3 downto 2);
        idex_regb   <= ifid_instr(1 downto 0);
      -- execute
        case idex_opcode is
        when "1011" =>
          reg_w_data <= in_port;
          reg_wr_index <= idex_rega;
          reg_w_en <= '1';
        when others =>
          reg_w_en <= '0';
        end case;
      -- mem

      -- writeback


      end if;
    end if;
  end process;
  out_port <= ifid_instr;
end Behavioral;

