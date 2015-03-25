library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
-- signals for components

-- ram signals
signal ram_addr_r : std_ulogic_vector(6 downto 0) := (others => 'Z');
signal ram_data_r : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal ram_addr_w : std_ulogic_vector(6 downto 0) := (others => 'Z');
signal ram_data_w : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal ram_wr_en  : std_ulogic := '0';

-- regfile signals
signal regfile_addr_a : std_ulogic_vector(1 downto 0) := (others => 'Z');
signal regfile_addr_b : std_ulogic_vector(1 downto 0) := (others => 'Z');
signal regfile_data_a : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal regfile_data_b : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal regfile_addr_w : std_ulogic_vector(1 downto 0) := (others => 'Z');
signal regfile_data_w : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal regfile_wr_en  : std_ulogic := '0';

-- alu signals
signal alu_mode     : std_ulogic_vector(2 downto 0) := (others => 'Z');
signal alu_in_a     : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal alu_in_b     : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal alu_result   : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal alu_n        : std_ulogic := '0';
signal alu_z        : std_ulogic := '0';

-- rom signals
signal pc                    : std_ulogic_vector(6 downto 0) := (others => 'Z');
signal rom_out          : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal in_port_data   : std_ulogic_vector(7 downto 0) := (others => 'Z');

-- architectural signals
-- issue/decode registers
signal is_dec_instr             : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal is_dec_in_port_data      : std_ulogic_vector(7 downto 0) := (others => 'Z');

-- decode/execute registers
signal de_ex_instr              : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal de_ex_reg_write_data     : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal de_ex_reg_write_addr     : std_ulogic_vector(1 downto 0) := (others => 'Z');
signal de_ex_regfile_addr_a     : std_ulogic_vector(1 downto 0) := (others => 'Z');

signal de_ex_reg_write_en       : std_ulogic := '0';
signal de_ex_alu_mode           : std_ulogic_vector(2 downto 0) := (others => 'Z');
-- decode/exec control signals
signal de_ex_reg_data_in_sel              : std_ulogic_vector(3 downto 0) := (others => '0');
signal de_ex_out_flag            : std_ulogic := '0';
-- decode/exec load immediate
signal de_ex_load_imm            : std_ulogic := '0';
signal de_ex_load_addr            : std_ulogic_vector(1 downto 0) := (others => '0');

-- decode/exec branching
signal de_ex_branch            : std_ulogic := '0';

-- execute/memory registers
signal ex_mem_instr              : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal ex_mem_reg_write_addr     : std_ulogic_vector(1 downto 0) := (others => 'Z');
signal ex_mem_reg_write_data     : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal ex_mem_reg_write_en       : std_ulogic := '0';
-- exec/mem control signals
signal ex_mem_reg_data_in_sel              : std_ulogic_vector(3 downto 0) := (others => '0');
signal ex_mem_out_flag            : std_ulogic := '0';

-- memory/writeback registers
signal mem_wb_instr              : std_ulogic_vector(7 downto 0) := (others => 'Z');

-- control signals
signal issue_stalled       : std_ulogic := '0';
signal decode_stalled       : std_ulogic := '0';
signal execute_stalled       : std_ulogic := '0';
signal memory_stalled       : std_ulogic := '0';
signal writeback_stalled       : std_ulogic := '0';

signal branch_pending       : std_ulogic := '0';

signal is_dec_alu_z : std_ulogic := '0';
signal is_dec_alu_n : std_ulogic := '0';


begin

    -- entity declarations for instantiations
    rom : entity work.imem port map(clk, rst, pc, rom_out);
    regfile : entity work.register_file port map(clk, rst, regfile_addr_a, regfile_addr_b, 
     regfile_data_a, regfile_data_b, 
     regfile_addr_w, regfile_data_w, 
     regfile_wr_en);
    fakeram : entity work.fake_ram port map(clk, rst, ram_addr_r, ram_data_r, 
        ram_addr_w, ram_data_w, ram_wr_en);
    alu1 : entity work.alu port map(clk, rst, alu_mode, alu_in_a, alu_in_b, alu_result, alu_n, alu_z);

    cpu: process(clk)
    begin
        if rising_edge(clk) then
            out_port <= "ZZZZZZZZ";
            if rst = '1' then
                pc <= "0000000";
            else
-- issue stage
                if rom_out(7 downto 4) = "1001" then
                    issue_stalled <= '1';
                end if;
                if issue_stalled = '0' 
                and decode_stalled = '0' 
                and execute_stalled ='0' 
                and memory_stalled = '0' 
                and writeback_stalled = '0' then
                    in_port_data <= in_port;
                    if branch_pending = '0' then
                        pc <= std_ulogic_vector(unsigned(pc) + to_unsigned(1,7));
                    else
                        pc <= regfile_data_a(6 downto 0);
                        branch_pending <= '0';
                    end if;
                    is_dec_instr <= rom_out; -- instruction register
                    is_dec_in_port_data <= in_port_data;
                    is_dec_alu_z <= alu_z;
                    is_dec_alu_n <= alu_n;
                    regfile_addr_a <= rom_out(3 downto 2);
                    regfile_addr_b <= rom_out(1 downto 0);
                end if;
-- decode stage
                if decode_stalled = '0' 
                and execute_stalled ='0' 
                and memory_stalled = '0' 
                and writeback_stalled = '0' then
                    de_ex_instr <= is_dec_instr; -- instruction register
                    de_ex_alu_mode <= "XXX";
                    de_ex_reg_write_en <= '0';
                    de_ex_reg_write_addr <= "XX";
                    alu_in_a <= "XXXXXXXX";
                    alu_in_b <= "XXXXXXXX";
                    de_ex_reg_data_in_sel <= "XXXX"; -- register data will  be written from alu result
                    de_ex_out_flag <= '0';

                    if de_ex_load_imm = '1' then -- this is an immediate value, not an instruction
                        de_ex_load_imm <= '0';
                        de_ex_reg_write_data <= is_dec_instr;
                        de_ex_reg_write_addr <= de_ex_load_addr;
                        de_ex_reg_write_en <= '1';
                        de_ex_reg_data_in_sel <= x"1"; -- register data will  be written from in port

                    else

                        case is_dec_instr(7 downto 4) is -- opcode
                        when x"3" => -- LOADIMM (2 byte instruction)
                            de_ex_load_imm <= '1';
                            de_ex_load_addr <= is_dec_instr(3 downto 2);

                         ----- ADD ----- SUB --- NAND --- SHR ---- SHL ----------
                        --when "0100" | "0101" | "0110" | "0111" | "1000" => -- any ALU operation
                        when x"4" | x"5" | x"6" | x"7" | x"8" => -- any ALU operation
                            de_ex_reg_write_en <= '1';
                            de_ex_reg_write_addr <= is_dec_instr(3 downto 2);
                            alu_mode <= is_dec_instr(7) & is_dec_instr(5 downto 4);
                            alu_in_a <= regfile_data_a;
                            alu_in_b <= regfile_data_b;
                            regfile_addr_a <= is_dec_instr(3 downto 2);
                            regfile_addr_b <= is_dec_instr(1 downto 0);
                            de_ex_reg_data_in_sel <= x"0"; -- register data will  be written from alu result

                        when x"9" => -- BRANCH
                            issue_stalled <= '0';
                            if is_dec_instr(3 downto 2) = "00" or 
                            (is_dec_instr(3 downto 2) = "01" and is_dec_alu_z = '1') or
                            (is_dec_instr(3 downto 2) = "10" and is_dec_alu_n = '1') then
                                regfile_addr_a <= is_dec_instr(1 downto 0);
                                branch_pending <= '1';
                            end if;

                        when x"b" => -- IN (read from input port)
                            de_ex_reg_write_data <= is_dec_in_port_data;
                            de_ex_reg_write_addr <= is_dec_instr(3 downto 2);
                            de_ex_reg_write_en <= '1';
                            de_ex_reg_data_in_sel <= x"1"; -- register data will  be written from in port

                        when x"c" => -- OUT
                            de_ex_regfile_addr_a <= is_dec_instr(3 downto 2);
                            de_ex_out_flag <= '1';

                        when x"d" => -- MOV
                            de_ex_reg_write_addr <= is_dec_instr(3 downto 2);
                            de_ex_reg_write_en <= '1';
                            de_ex_reg_data_in_sel <= x"2"; -- register data will be written from register file out
                            de_ex_regfile_addr_a <= is_dec_instr(1 downto 0);

                        when others =>
                            de_ex_reg_write_data <= "XXXXXXXX";
                            alu_mode <= "XXX";
                            de_ex_reg_write_en <= '0';
                        end case;
                    end if;
                end if;
-- execute stage
                if execute_stalled ='0' 
                and memory_stalled = '0' 
                and writeback_stalled = '0' then
                    ex_mem_out_flag <= '0';
                    ex_mem_instr <= de_ex_instr; -- instruction register
                    ex_mem_reg_write_data <= de_ex_reg_write_data;
                    ex_mem_reg_write_addr <= de_ex_reg_write_addr;
                    ex_mem_reg_write_en <= de_ex_reg_write_en;
                    ex_mem_reg_data_in_sel <= de_ex_reg_data_in_sel;
                    if de_ex_out_flag = '1' then
                        regfile_addr_a <= de_ex_regfile_addr_a;
                        ex_mem_out_flag <= '1';
                    end if;

                end if; -- not stalled

-- memory stage
                if memory_stalled = '0' 
                and writeback_stalled = '0' then
                    mem_wb_instr <= ex_mem_instr; -- instruction register
                    regfile_wr_en <= ex_mem_reg_write_en;
                    case ex_mem_reg_data_in_sel is
                    when x"0" =>
                        regfile_data_w <= alu_result;
                    when x"1" =>
                        regfile_data_w <= ex_mem_reg_write_data;
                    when x"2" =>
                        regfile_data_w <= regfile_data_a;
                    when others =>
                        regfile_data_w <= alu_result;
                    end case;
                    regfile_addr_w <= ex_mem_reg_write_addr;
                    if ex_mem_out_flag = '1' then
                        out_port <= regfile_data_a;
                    end if;
                end if; -- not stalled
-- writeback stage

            end if;
        end if;
    end process;
end Behavioral;

