----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.12.2025 19:49:08
-- Design Name: 
-- Module Name: tb_top_r - Behavioral
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

entity tb_top_r is
-- La entidad del testbench siempre está vacía
end tb_top_r;

architecture Behavioral of tb_top_r is

    -- 1. Declaración del Componente (Unit Under Test - UUT)
    component top_r
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        modo_f   : in  STD_LOGIC;
        modo_m   : in  STD_LOGIC;
        modo_d   : in  STD_LOGIC;
        CE       : in  STD_LOGIC;
        segments : out STD_LOGIC_VECTOR(6 downto 0);
        anodes   : out STD_LOGIC_VECTOR(7 downto 0)
    );
    end component;

    -- 2. Señales para conectar al UUT
    signal clk_tb      : STD_LOGIC := '0';
    signal rst_tb      : STD_LOGIC := '0'; -- Empezamos en Reset (0)
    signal modo_f_tb   : STD_LOGIC := '0';
    signal modo_m_tb   : STD_LOGIC := '0';
    signal modo_d_tb   : STD_LOGIC := '0';
    signal CE_tb       : STD_LOGIC := '0';

    -- Salidas observadas
    signal segments_tb : STD_LOGIC_VECTOR(6 downto 0);
    signal anodes_tb   : STD_LOGIC_VECTOR(7 downto 0);

    -- Constante del periodo de reloj (100 MHz = 10 ns)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- 3. Instanciación del UUT
    uut: top_r Port map (
        clk      => clk_tb,
        rst      => rst_tb,
        modo_f   => modo_f_tb,
        modo_m   => modo_m_tb,
        modo_d   => modo_d_tb,
        CE       => CE_tb,
        segments => segments_tb,
        anodes   => anodes_tb
    );

    -- 4. Proceso de Generación de Reloj
    clk_process :process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- 5. Proceso de Estímulos
    stim_proc: process
    begin
        -- === INICIO DE SIMULACIÓN ===
        
        -- A) Reset del sistema
        -- El reset es activo a nivel BAJO ('0'). Lo mantenemos un rato.
        rst_tb <= '0'; 
        CE_tb  <= '0';
        modo_f_tb <= '0';
        wait for 100 ns;

        -- B) Soltar Reset
        rst_tb <= '1'; 
        wait for 50 ns;

        -- C) Configurar Entradas
        CE_tb <= '1';      -- Simulamos el Switch J15 activado
        modo_f_tb <= '1';  -- Simulamos el Switch L16 activado (Modo Forward)
        
        -- Los otros modos apagados
        modo_m_tb <= '0';
        modo_d_tb <= '0';

        -- D) Dejar correr la simulación
        -- Si cambiaste la constante a 10 ciclos, aquí veremos movimiento.
        -- Esperamos el tiempo suficiente para ver varios desplazamientos de carretera.
        wait for 2000 ns; 

        -- E) Prueba de pausa (Opcional: bajar CE)
        CE_tb <= '0';
        wait for 500 ns;
        
        -- F) Reanudar
        CE_tb <= '1';
        wait for 1000 ns;

        -- Finalizar simulación
        assert false report "Simulación terminada correctamente" severity failure;
    end process;

end Behavioral;