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

signal regfile_addr_a : std_ulogic_vector(1 downto 0) := (others => '0'); -- 
signal regfile_addr_b : std_ulogic_vector(1 downto 0) := (others => '0'); -- 
signal regfile_addr_w : std_ulogic_vector(1 downto 0) := (others => '0'); -- 
signal regfile_data_a : std_ulogic_vector(7 downto 0) := (others => '0'); -- 

signal regfile_data_b : std_ulogic_vector(7 downto 0) := (others => '0'); -- 
signal regfile_data_w : std_ulogic_vector(7 downto 0) := (others => '0'); -- 
signal regfile_wr_en : std_ulogic := '0';

signal alu_mode : std_ulogic_VECTOR (2 downto 0);
signal alu_in_a : std_ulogic_VECTOR (7 downto 0);
signal alu_in_b : std_ulogic_VECTOR (7 downto 0);
signal alu_result : std_ulogic_VECTOR (7 downto 0);
signal alu_n : std_ulogic;
signal alu_z : std_ulogic;

signal decode_instr : std_ulogic_vector(7 downto 0) := (others => '0');
signal decode_in_port : std_ulogic_vector(7 downto 0) := (others => '0');

signal exec0_reg_wr_src_mux : std_ulogic := '0';

signal exec0_reg_wr_en : std_ulogic := '0';
signal exec0_reg_addr_w : std_ulogic_vector(1 downto 0) := (others => '0'); -- 
-- type A instruction
signal exec0_reg_addr_a : std_ulogic_vector(1 downto 0) := (others => '0'); -- 
signal exec0_reg_addr_b : std_ulogic_vector(1 downto 0) := (others => '0'); -- 
signal exec0_alu_mode : std_ulogic_vector(2 downto 0) := (others => '0');
-- IN instruction
signal exec0_in_port : std_ulogic_vector(7 downto 0) := (others => '0');


signal exec1_reg_wr_src_mux : std_ulogic := '0';
signal exec1_in_data : std_ulogic_vector(7 downto 0) := (others => '0');
signal exec1_reg_wr_en : std_ulogic := '0';
signal exec1_reg_addr_w : std_ulogic_vector(1 downto 0) := (others => '0'); -- 

--------------------------------------------------------------------
------------------ REFACTORED ABOVE THIS LINE ----------------------
--------------------------------------------------------------------
signal exec1_in_port : std_ulogic_vector(7 downto 0) := (others => '0'); -- destination register index

signal alu_n_flag : std_ulogic := '0';
signal alu_z_flag : std_ulogic := '0';

begin

-- entity declarations for instantiations
rom : entity work.imem port map(clk, rst, pc, decode_instr);
regfile : entity work.register_file port map(clk, rst, regfile_addr_a, regfile_addr_b, 
                                                       regfile_data_a, regfile_data_b, 
                                                       regfile_addr_w, regfile_data_w, 
                                                       regfile_wr_en);
alu1 : entity work.alu port map(clk, rst, alu_mode, alu_in_a, alu_in_b, alu_result, alu_n, alu_z);

ctrlpath: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pc <= "0000000";
        --decode_rs_id_a <= "00";
        --decode_rs_id_b <= "00";
        --exec0_alu_mode <= "000";
        --exec0_rd_id <= "00";
        --exec0_reg_wr_en <= '0';
        --exec0_in_port <= "00000000";
        --exec0_opcode <= "0000";
        --exec1_alu_mode <= "000";
        --exec1_rd_id <= "00";
        --exec1_regfile_write_en <= '0';
        --exec1_in_port <= "00000000";
        --exec1_opcode <= "0000";
        --wb_rd_id <= "00";
        --wb_regfile_write_en <= '0';
        --wb_regfile_write_data <= "00000000";
        --in_port_data <= "00000000";

      else
-------------------------------------------------------------------
-- fetch
-------------------------------------------------------------------
        pc <= std_ulogic_vector(unsigned(pc) + 1);
        --decode_opcode := decode_instr(7 downto 4);
                  decode_in_port   <= in_port;

-----------------------------------------------------------------
-- decode (type A)
-----------------------------------------------------------------
        case decode_instr(7 downto 4) is -- opcode
        when "0100" => -- add
          exec0_alu_mode <= "000";
          exec0_reg_wr_en <= '1'; -- will be writing back to reg file
          regfile_addr_a   <= decode_instr(3 downto 2);
          regfile_addr_b   <= decode_instr(1 downto 0);
          exec0_reg_wr_src_mux <= '1';
        when "0101" => -- sub 
          exec0_alu_mode <= "001";
          exec0_reg_wr_en <= '1'; -- will be writing back to reg file
          regfile_addr_a   <= decode_instr(3 downto 2);
          regfile_addr_b   <= decode_instr(1 downto 0);
          exec0_reg_wr_src_mux <= '1';
        when "0110" => -- shl
          exec0_alu_mode <= "010";
          exec0_reg_wr_en <= '1'; -- will be writing back to reg file
          regfile_addr_a   <= decode_instr(3 downto 2);
          regfile_addr_b   <= decode_instr(1 downto 0);
          exec0_reg_wr_src_mux <= '1';
        when "0111" => -- shr
          exec0_alu_mode <= "011";
          exec0_reg_wr_en <= '1'; -- will be writing back to reg file
          regfile_addr_a   <= decode_instr(3 downto 2);
          regfile_addr_b   <= decode_instr(1 downto 0);
          exec0_reg_wr_src_mux <= '1';
        when "1000" => -- nand
          exec0_alu_mode <= "100";
          exec0_reg_wr_en <= '1'; -- will be writing back to reg file
          regfile_addr_a   <= decode_instr(3 downto 2);
          regfile_addr_b   <= decode_instr(1 downto 0);
          exec0_reg_wr_src_mux <= '1';
        when "1011" => -- IN (read from input port)
          exec0_alu_mode <= "111"; -- reserved for NOT AN ALU OP
          exec0_reg_wr_en <= '1';
          exec0_reg_wr_src_mux <= '0';
          exec0_in_port <= decode_in_port;
        when others =>
          exec0_alu_mode <= "ZZZ";
          exec0_reg_wr_en <= '0';
        end case;

        exec0_reg_addr_w   <= decode_instr(3 downto 2);
      -----------------------------------------------------------------
      -- execute 1
      -----------------------------------------------------------------
        exec1_reg_wr_src_mux <= exec0_reg_wr_src_mux;
      -- TYPE A INSTRUCTION
        alu_mode        <= exec0_alu_mode;
        alu_in_a        <= regfile_data_a;
        alu_in_b        <= regfile_data_b;
        exec1_reg_addr_w <= exec0_reg_addr_w;
        exec1_reg_wr_en        <= exec0_reg_wr_en;
      -- IN instruction
        exec1_in_port <= exec0_in_port;
      -----------------------------------------------------------------
      -- execute 2 / AKA writeback
      -----------------------------------------------------------------
        regfile_addr_w <= exec1_reg_addr_w;
        regfile_wr_en <= exec1_reg_wr_en;
        if exec1_reg_wr_src_mux = '0' then
          regfile_data_w <= exec1_in_port;
        else
          regfile_data_w <= alu_result;
        end if;
      end if;
    end if;
  end process;
--  out_port <= decode_instr;
end Behavioral;

