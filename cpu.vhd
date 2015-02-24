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

signal decode0_instr : std_ulogic_vector(7 downto 0) := (others => '0');
signal decode0_rs_id_a : std_ulogic_vector(1 downto 0) := (others => '0'); -- source register A
signal decode0_rs_id_b : std_ulogic_vector(1 downto 0) := (others => '0'); -- source register B
signal decode0_opcode : std_ulogic_vector(3 downto 0) := (others => '0'); -- CPU opcode

signal exec0_alu_mode : std_ulogic_vector(2 downto 0) := (others => '0');
signal exec0_rs_id_a : std_ulogic_vector(1 downto 0) := (others => '0'); -- source register index
signal exec0_rs_id_b : std_ulogic_vector(1 downto 0) := (others => '0'); -- source register index
signal exec0_rd_id : std_ulogic_vector(1 downto 0) := (others => '0'); -- destination register index
signal exec0_regfile_write_en : std_ulogic := '0';
signal exec0_in_port : std_ulogic_vector(7 downto 0) := (others => '0'); -- destination register index
signal exec0_opcode : std_ulogic_vector(3 downto 0) := (others => '0'); -- CPU opcode

signal exec1_alu_mode : std_ulogic_vector(2 downto 0) := (others => '0');
signal exec1_reg_data_a : std_ulogic_vector(7 downto 0) := (others => '0'); -- register data
signal exec1_reg_data_b : std_ulogic_vector(7 downto 0) := (others => '0'); -- register data
signal exec1_rd_id : std_ulogic_vector(1 downto 0) := (others => '0'); -- destination register index
signal exec1_regfile_write_en : std_ulogic := '0';
signal exec1_in_port : std_ulogic_vector(7 downto 0) := (others => '0'); -- destination register index
signal exec1_opcode : std_ulogic_vector(3 downto 0) := (others => '0'); -- CPU opcode

signal exec2_alu_result : std_ulogic_vector(7 downto 0) := (others => '0');
signal exec2_rd_id : std_ulogic_vector(1 downto 0) := (others => '0'); -- destination register index
signal exec2_regfile_write_en : std_ulogic := '0';
signal exec2_regfile_write_data : std_ulogic_vector(7 downto 0) := (others => '0');

signal alu_n_flag : std_ulogic := '0';
signal alu_z_flag : std_ulogic := '0';

signal in_port_data : std_ulogic_vector(7 downto 0) := (others => '0');

begin

  -- entity declarations for instantiations
  rom : entity work.imem port map(clk, pc, decode0_instr);
  regfile : entity work.register_file port map(clk, rst, exec0_rs_id_a, exec0_rs_id_b, 
                        exec2_rd_id, exec2_regfile_write_en, exec2_regfile_write_data, exec1_reg_data_a, exec1_reg_data_b);
  alu1 : entity work.alu port map(clk, rst, exec1_alu_mode, exec1_reg_data_a, exec1_reg_data_b, exec2_alu_result, alu_n_flag, alu_z_flag);

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
        decode0_rs_id_a <= "00";
        decode0_rs_id_b <= "00";
        decode0_opcode <= "0000";
        exec0_alu_mode <= "000";
        exec0_rs_id_a <= "00";
        exec0_rs_id_b <= "00";
        exec0_rd_id <= "00";
        exec0_regfile_write_en <= '0';
        exec0_in_port <= "00000000";
        exec0_opcode <= "0000";
        exec1_alu_mode <= "000";
        exec1_rd_id <= "00";
        exec1_regfile_write_en <= '0';
        exec1_in_port <= "00000000";
        exec1_opcode <= "0000";
        exec2_rd_id <= "00";
        exec2_regfile_write_en <= '0';
        exec2_regfile_write_data <= "00000000";
        in_port_data <= "00000000";

      else
      -- fetch
      
        pc <= std_ulogic_vector(unsigned(pc) + 1);
        decode0_opcode <= decode0_instr(7 downto 4);
        in_port_data <= in_port;

        -- decode (type A)
        case decode0_opcode is
        when "0100" => -- add
          exec0_alu_mode <= "000";
          exec0_regfile_write_en <= '1'; -- will be writing back to reg file
        when "0101" => -- sub 
          exec0_alu_mode <= "001";
          exec0_regfile_write_en <= '1'; -- will be writing back to reg file
        when "0110" => -- shl
          exec0_alu_mode <= "010";
          exec0_regfile_write_en <= '1'; -- will be writing back to reg file
        when "0111" => -- shr
          exec0_alu_mode <= "011";
          exec0_regfile_write_en <= '1'; -- will be writing back to reg file
        when "1000" => -- nand
          exec0_alu_mode <= "100";
          exec0_regfile_write_en <= '1'; -- will be writing back to reg file
        when "1011" => -- IN (read from input port)
          exec0_alu_mode <= "111"; -- reserved for NOT AN ALU OP
          exec0_in_port     <= in_port_data;
          exec0_regfile_write_en <= '1';
        when others =>
          exec0_alu_mode <= "111";
          exec0_regfile_write_en <= '0';
        end case;
        exec0_rs_id_a   <= decode0_instr(3 downto 2);
        exec0_rs_id_b   <= decode0_instr(1 downto 0);
        exec0_rd_id     <= decode0_instr(3 downto 2);
        exec0_opcode     <= decode0_opcode;

      -- execute 1
        exec1_alu_mode         <= exec0_alu_mode;
        exec1_rd_id            <= exec0_rd_id;
        exec1_regfile_write_en <= exec0_regfile_write_en;
        exec1_in_port          <= exec0_in_port;
        exec1_opcode           <= exec0_opcode;

      -- execute 2
        exec2_rd_id            <= exec1_rd_id;
        exec2_regfile_write_en <= exec1_regfile_write_en;
        if exec1_opcode = "1011" then
          exec2_regfile_write_data <= exec1_in_port;
        else
          exec2_regfile_write_data <= exec2_alu_result;
        end if;
      -- mem

      -- writeback

      end if;
    end if;
  end process;
--  out_port <= decode0_instr;
end Behavioral;

