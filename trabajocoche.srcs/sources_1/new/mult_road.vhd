----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.12.2025 23:15:48
-- Design Name: 
-- Module Name: mult_road - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

entity mult_road is
    Port (
        CLK             : in  STD_LOGIC;                               
        RST             : in  STD_LOGIC;
        -- ENTRADA: Vector de 56 bits
        ROAD_ARRAY_IN   : in  STD_LOGIC_VECTOR(55 downto 0); 
        
        -- SALIDAS FÍSICAS
        SEGMENTS_OUT    : out STD_LOGIC_VECTOR(6 downto 0);             
        ANODES_OUT      : out STD_LOGIC_VECTOR(7 downto 0)              
    );
end mult_road;
architecture Behavioral of mult_road is
    constant C_MUX_FREQ_DIV : natural := 100000; -- Aprox 1ms por display
    signal s_mux_counter    : natural range 0 to C_MUX_FREQ_DIV - 1 := 0;
    signal s_display_select : unsigned(2 downto 0) := "000"; 
    signal s_current_pattern : STD_LOGIC_VECTOR(6 downto 0);
begin

    -- 1. Divisor para el refresco de los displays
    process(CLK, RST)
    begin
        if RST = '0' then
            s_mux_counter <= 0;
            s_display_select <= "000";
        elsif rising_edge(CLK) then
            if s_mux_counter = C_MUX_FREQ_DIV - 1 then
                s_mux_counter <= 0;
                s_display_select <= s_display_select + 1;
            else
                s_mux_counter <= s_mux_counter + 1;
            end if;
        end if;
    end process;

    -- 2. Selección del patrón (Mux de datos)
    -- Extraemos los 7 bits correspondientes al display activo
    process(s_display_select, ROAD_ARRAY_IN)
        variable idx : integer;
    begin
        idx := to_integer(s_display_select);
        s_current_pattern <= ROAD_ARRAY_IN((idx * 7) + 6 downto idx * 7);
    end process;

    -- 3. Salidas Físicas (Lógica Negativa para Nexys A7)
    SEGMENTS_OUT <= not s_current_pattern; 

    -- Decodificador de Ánodos: Solo un '0' a la vez
    process(s_display_select)
    begin
        ANODES_OUT <= (others => '1'); -- Todos apagados por defecto
        ANODES_OUT(to_integer(s_display_select)) <= '0'; -- Encender solo uno
    end process;
                   
end Behavioral;