library vunit_lib;
context vunit_lib.vunit_context;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

library osvvm;
use osvvm.RandomPkg.all;

entity countzero_tb is
    generic (runner_cfg : string := runner_cfg_default);
end countzero_tb;

architecture behave of countzero_tb is
    constant clk_period: time := 10 ns;
    signal rs: std_ulogic_vector(63 downto 0);
    signal is_32bit, count_right: std_ulogic := '0';
    signal result: std_ulogic_vector(63 downto 0);
    signal randno: std_ulogic_vector(63 downto 0);
    signal clk: std_ulogic;

begin
    zerocounter_0: entity work.zero_counter
        port map (
            clk => clk,
            rs => rs,
            result => result,
            count_right => count_right,
            is_32bit => is_32bit
        );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_process: process
        variable r: std_ulogic_vector(63 downto 0);
        variable rnd : RandomPType;
    begin
        rnd.InitSeed(stim_process'path_name);

        test_runner_setup(runner, runner_cfg);

        while test_suite loop
            if run("Test with input = 0") then
                rs <= (others => '0');
                is_32bit <= '0';
                count_right <= '0';
                wait for clk_period;
                assert result = x"0000000000000040"
                    report "bad cntlzd 0 = " & to_hstring(result);
                count_right <= '1';
                wait for clk_period;
                assert result = x"0000000000000040"
                    report "bad cnttzd 0 = " & to_hstring(result);
                is_32bit <= '1';
                count_right <= '0';
                wait for clk_period;
                assert result = x"0000000000000020"
                    report "bad cntlzw 0 = " & to_hstring(result);
                count_right <= '1';
                wait for clk_period;
                assert result = x"0000000000000020"
                    report "bad cnttzw 0 = " & to_hstring(result);

            elsif run("Test cntlzd/w") then
                count_right <= '0';
                for j in 0 to 100 loop
                    r := rnd.RandSlv(64);
                    r(63) := '1';
                    for i in 0 to 63 loop
                        rs <= r;
                        is_32bit <= '0';
                        wait for clk_period;
                        assert to_integer(unsigned(result)) = i
                            report "bad cntlzd " & to_hstring(rs) & " -> " & to_hstring(result);
                        rs <= r(31 downto 0) & r(63 downto 32);
                        is_32bit <= '1';
                        wait for clk_period;
                        if i < 32 then
                            assert to_integer(unsigned(result)) = i
                                report "bad cntlzw " & to_hstring(rs) & " -> " & to_hstring(result);
                        else
                            assert to_integer(unsigned(result)) = 32
                                report "bad cntlzw " & to_hstring(rs) & " -> " & to_hstring(result);
                        end if;
                        r := '0' & r(63 downto 1);
                    end loop;
                end loop;

            elsif run("Test cnttzd/w") then
                count_right <= '1';
                for j in 0 to 100 loop
                    r := rnd.RandSlv(64);
                    r(0) := '1';
                    for i in 0 to 63 loop
                        rs <= r;
                        is_32bit <= '0';
                        wait for clk_period;
                        assert to_integer(unsigned(result)) = i
                            report "bad cnttzd " & to_hstring(rs) & " -> " & to_hstring(result);
                        is_32bit <= '1';
                        wait for clk_period;
                        if i < 32 then
                            assert to_integer(unsigned(result)) = i
                                report "bad cnttzw " & to_hstring(rs) & " -> " & to_hstring(result);
                        else
                            assert to_integer(unsigned(result)) = 32
                                report "bad cnttzw " & to_hstring(rs) & " -> " & to_hstring(result);
                        end if;
                        r := r(62 downto 0) & '0';
                    end loop;
                end loop;
            end if;
        end loop;

        test_runner_cleanup(runner);
    end process;
end behave;
