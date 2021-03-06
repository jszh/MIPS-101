--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.7
--  \   \         Application : xaw2vhdl
--  /   /         Filename : dcm.vhd
-- /___/   /\     Timestamp : 11/28/2016 20:42:54
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: xaw2vhdl-st D:\Junior\ComputerOrganization\CPU\jiyuan\cpu\ipcore_dir\.\dcm.xaw D:\Junior\ComputerOrganization\CPU\jiyuan\cpu\ipcore_dir\.\dcm
--Design Name: dcm
--Device: xc3s1200e-4fg320
--
-- Module dcm
-- Generated by Xilinx Architecture Wizard
-- Written for synthesis tool: XST
-- Period Jitter (unit interval) for block DCM_SP_INST = 0.05 UI
-- Period Jitter (Peak-to-Peak) for block DCM_SP_INST = 0.82 ns

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity dcm is
   port ( CLKIN_IN   : in    std_logic; 
          RST_IN     : in    std_logic; 
          CLKFX_OUT  : out   std_logic; 
          CLK0_OUT   : out   std_logic; 
          CLK2X_OUT  : out   std_logic; 
          LOCKED_OUT : out   std_logic);
end dcm;

architecture BEHAVIORAL of dcm is
   signal CLKFB_IN   : std_logic;
   signal CLKFX_BUF  : std_logic;
   signal CLK0_BUF   : std_logic;
   signal CLK2X_BUF  : std_logic;
   signal GND_BIT    : std_logic;
begin
   GND_BIT <= '0';
   CLK2X_OUT <= CLKFB_IN;
   CLKFX_BUFG_INST : BUFG
      port map (I=>CLKFX_BUF,
                O=>CLKFX_OUT);
   
   CLK0_BUFG_INST : BUFG
      port map (I=>CLK0_BUF,
                O=>CLK0_OUT);
   
   CLK2X_BUFG_INST : BUFG
      port map (I=>CLK2X_BUF,
                O=>CLKFB_IN);
   
   DCM_SP_INST : DCM_SP
   generic map( CLK_FEEDBACK => "2X",
            CLKDV_DIVIDE => 2.0,
            CLKFX_DIVIDE => 4,
            CLKFX_MULTIPLY => 5,
            CLKIN_DIVIDE_BY_2 => FALSE,
            CLKIN_PERIOD => 20.000,
            CLKOUT_PHASE_SHIFT => "NONE",
            DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
            DFS_FREQUENCY_MODE => "LOW",
            DLL_FREQUENCY_MODE => "LOW",
            DUTY_CYCLE_CORRECTION => TRUE,
            FACTORY_JF => x"C080",
            PHASE_SHIFT => 0,
            STARTUP_WAIT => FALSE)
      port map (CLKFB=>CLKFB_IN,
                CLKIN=>CLKIN_IN,
                DSSEN=>GND_BIT,
                PSCLK=>GND_BIT,
                PSEN=>GND_BIT,
                PSINCDEC=>GND_BIT,
                RST=>RST_IN,
                CLKDV=>open,
                CLKFX=>CLKFX_BUF,
                CLKFX180=>open,
                CLK0=>CLK0_BUF,
                CLK2X=>CLK2X_BUF,
                CLK2X180=>open,
                CLK90=>open,
                CLK180=>open,
                CLK270=>open,
                LOCKED=>LOCKED_OUT,
                PSDONE=>open,
                STATUS=>open);
   
end BEHAVIORAL;


