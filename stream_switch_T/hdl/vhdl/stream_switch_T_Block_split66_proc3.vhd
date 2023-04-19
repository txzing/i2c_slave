-- ==============================================================
-- RTL generated by Vitis HLS - High-Level Synthesis from C, C++ and OpenCL
-- Version: 2020.1
-- Copyright (C) 1986-2020 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity stream_switch_T_Block_split66_proc3 is
port (
    ap_clk : IN STD_LOGIC;
    ap_rst : IN STD_LOGIC;
    ap_start : IN STD_LOGIC;
    ap_done : OUT STD_LOGIC;
    ap_continue : IN STD_LOGIC;
    ap_idle : OUT STD_LOGIC;
    ap_ready : OUT STD_LOGIC;
    s_axis_video_TDATA : IN STD_LOGIC_VECTOR (15 downto 0);
    s_axis_video_TVALID : IN STD_LOGIC;
    s_axis_video_TREADY : OUT STD_LOGIC;
    s_axis_video_TKEEP : IN STD_LOGIC_VECTOR (1 downto 0);
    s_axis_video_TSTRB : IN STD_LOGIC_VECTOR (1 downto 0);
    s_axis_video_TUSER : IN STD_LOGIC_VECTOR (0 downto 0);
    s_axis_video_TLAST : IN STD_LOGIC_VECTOR (0 downto 0);
    s_axis_video_TID : IN STD_LOGIC_VECTOR (0 downto 0);
    s_axis_video_TDEST : IN STD_LOGIC_VECTOR (9 downto 0);
    m0_axis_video_TDATA : OUT STD_LOGIC_VECTOR (15 downto 0);
    m0_axis_video_TVALID : OUT STD_LOGIC;
    m0_axis_video_TREADY : IN STD_LOGIC;
    m0_axis_video_TKEEP : OUT STD_LOGIC_VECTOR (1 downto 0);
    m0_axis_video_TSTRB : OUT STD_LOGIC_VECTOR (1 downto 0);
    m0_axis_video_TUSER : OUT STD_LOGIC_VECTOR (0 downto 0);
    m0_axis_video_TLAST : OUT STD_LOGIC_VECTOR (0 downto 0);
    m0_axis_video_TID : OUT STD_LOGIC_VECTOR (0 downto 0);
    m0_axis_video_TDEST : OUT STD_LOGIC_VECTOR (0 downto 0);
    m1_axis_video_TDATA : OUT STD_LOGIC_VECTOR (15 downto 0);
    m1_axis_video_TVALID : OUT STD_LOGIC;
    m1_axis_video_TREADY : IN STD_LOGIC;
    m1_axis_video_TKEEP : OUT STD_LOGIC_VECTOR (1 downto 0);
    m1_axis_video_TSTRB : OUT STD_LOGIC_VECTOR (1 downto 0);
    m1_axis_video_TUSER : OUT STD_LOGIC_VECTOR (0 downto 0);
    m1_axis_video_TLAST : OUT STD_LOGIC_VECTOR (0 downto 0);
    m1_axis_video_TID : OUT STD_LOGIC_VECTOR (0 downto 0);
    m1_axis_video_TDEST : OUT STD_LOGIC_VECTOR (0 downto 0) );
end;


architecture behav of stream_switch_T_Block_split66_proc3 is 
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';
    constant ap_ST_fsm_state1 : STD_LOGIC_VECTOR (1 downto 0) := "01";
    constant ap_ST_fsm_state2 : STD_LOGIC_VECTOR (1 downto 0) := "10";
    constant ap_const_lv32_0 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
    constant ap_const_boolean_1 : BOOLEAN := true;
    constant ap_const_lv10_2C0 : STD_LOGIC_VECTOR (9 downto 0) := "1011000000";
    constant ap_const_lv32_1 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000001";
    constant ap_const_lv10_2C1 : STD_LOGIC_VECTOR (9 downto 0) := "1011000001";
    constant ap_const_lv2_0 : STD_LOGIC_VECTOR (1 downto 0) := "00";
    constant ap_const_lv1_0 : STD_LOGIC_VECTOR (0 downto 0) := "0";

attribute shreg_extract : string;
    signal ap_done_reg : STD_LOGIC := '0';
    signal ap_CS_fsm : STD_LOGIC_VECTOR (1 downto 0) := "01";
    attribute fsm_encoding : string;
    attribute fsm_encoding of ap_CS_fsm : signal is "none";
    signal ap_CS_fsm_state1 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state1 : signal is "none";
    signal s_axis_video_TDATA_blk_n : STD_LOGIC;
    signal m0_axis_video_TDATA_blk_n : STD_LOGIC;
    signal ap_CS_fsm_state2 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state2 : signal is "none";
    signal tmp_dest_V_reg_182 : STD_LOGIC_VECTOR (9 downto 0);
    signal m1_axis_video_TDATA_blk_n : STD_LOGIC;
    signal ap_block_state1 : BOOLEAN;
    signal ap_block_state1_io : BOOLEAN;
    signal regslice_both_m0_axis_video_V_data_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_data_V_U_apdone_blk : STD_LOGIC;
    signal ap_block_state2 : BOOLEAN;
    signal ap_block_state2_io : BOOLEAN;
    signal ap_NS_fsm : STD_LOGIC_VECTOR (1 downto 0);
    signal regslice_both_s_axis_video_V_data_V_U_apdone_blk : STD_LOGIC;
    signal s_axis_video_TDATA_int_regslice : STD_LOGIC_VECTOR (15 downto 0);
    signal s_axis_video_TVALID_int_regslice : STD_LOGIC;
    signal s_axis_video_TREADY_int_regslice : STD_LOGIC;
    signal regslice_both_s_axis_video_V_data_V_U_ack_in : STD_LOGIC;
    signal regslice_both_s_axis_video_V_keep_V_U_apdone_blk : STD_LOGIC;
    signal s_axis_video_TKEEP_int_regslice : STD_LOGIC_VECTOR (1 downto 0);
    signal regslice_both_s_axis_video_V_keep_V_U_vld_out : STD_LOGIC;
    signal regslice_both_s_axis_video_V_keep_V_U_ack_in : STD_LOGIC;
    signal regslice_both_s_axis_video_V_strb_V_U_apdone_blk : STD_LOGIC;
    signal s_axis_video_TSTRB_int_regslice : STD_LOGIC_VECTOR (1 downto 0);
    signal regslice_both_s_axis_video_V_strb_V_U_vld_out : STD_LOGIC;
    signal regslice_both_s_axis_video_V_strb_V_U_ack_in : STD_LOGIC;
    signal regslice_both_s_axis_video_V_user_V_U_apdone_blk : STD_LOGIC;
    signal s_axis_video_TUSER_int_regslice : STD_LOGIC_VECTOR (0 downto 0);
    signal regslice_both_s_axis_video_V_user_V_U_vld_out : STD_LOGIC;
    signal regslice_both_s_axis_video_V_user_V_U_ack_in : STD_LOGIC;
    signal regslice_both_s_axis_video_V_last_V_U_apdone_blk : STD_LOGIC;
    signal s_axis_video_TLAST_int_regslice : STD_LOGIC_VECTOR (0 downto 0);
    signal regslice_both_s_axis_video_V_last_V_U_vld_out : STD_LOGIC;
    signal regslice_both_s_axis_video_V_last_V_U_ack_in : STD_LOGIC;
    signal regslice_both_s_axis_video_V_id_V_U_apdone_blk : STD_LOGIC;
    signal s_axis_video_TID_int_regslice : STD_LOGIC_VECTOR (0 downto 0);
    signal regslice_both_s_axis_video_V_id_V_U_vld_out : STD_LOGIC;
    signal regslice_both_s_axis_video_V_id_V_U_ack_in : STD_LOGIC;
    signal regslice_both_s_axis_video_V_dest_V_U_apdone_blk : STD_LOGIC;
    signal s_axis_video_TDEST_int_regslice : STD_LOGIC_VECTOR (9 downto 0);
    signal regslice_both_s_axis_video_V_dest_V_U_vld_out : STD_LOGIC;
    signal regslice_both_s_axis_video_V_dest_V_U_ack_in : STD_LOGIC;
    signal m0_axis_video_TVALID_int_regslice : STD_LOGIC;
    signal m0_axis_video_TREADY_int_regslice : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_data_V_U_vld_out : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_keep_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_keep_V_U_ack_in_dummy : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_keep_V_U_vld_out : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_strb_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_strb_V_U_ack_in_dummy : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_strb_V_U_vld_out : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_user_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_user_V_U_ack_in_dummy : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_user_V_U_vld_out : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_last_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_last_V_U_ack_in_dummy : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_last_V_U_vld_out : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_id_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_id_V_U_ack_in_dummy : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_id_V_U_vld_out : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_dest_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_dest_V_U_ack_in_dummy : STD_LOGIC;
    signal regslice_both_m0_axis_video_V_dest_V_U_vld_out : STD_LOGIC;
    signal m1_axis_video_TVALID_int_regslice : STD_LOGIC;
    signal m1_axis_video_TREADY_int_regslice : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_data_V_U_vld_out : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_keep_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_keep_V_U_ack_in_dummy : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_keep_V_U_vld_out : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_strb_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_strb_V_U_ack_in_dummy : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_strb_V_U_vld_out : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_user_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_user_V_U_ack_in_dummy : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_user_V_U_vld_out : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_last_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_last_V_U_ack_in_dummy : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_last_V_U_vld_out : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_id_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_id_V_U_ack_in_dummy : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_id_V_U_vld_out : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_dest_V_U_apdone_blk : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_dest_V_U_ack_in_dummy : STD_LOGIC;
    signal regslice_both_m1_axis_video_V_dest_V_U_vld_out : STD_LOGIC;

    component regslice_both IS
    generic (
        DataWidth : INTEGER );
    port (
        ap_clk : IN STD_LOGIC;
        ap_rst : IN STD_LOGIC;
        data_in : IN STD_LOGIC_VECTOR (DataWidth-1 downto 0);
        vld_in : IN STD_LOGIC;
        ack_in : OUT STD_LOGIC;
        data_out : OUT STD_LOGIC_VECTOR (DataWidth-1 downto 0);
        vld_out : OUT STD_LOGIC;
        ack_out : IN STD_LOGIC;
        apdone_blk : OUT STD_LOGIC );
    end component;



begin
    regslice_both_s_axis_video_V_data_V_U : component regslice_both
    generic map (
        DataWidth => 16)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TDATA,
        vld_in => s_axis_video_TVALID,
        ack_in => regslice_both_s_axis_video_V_data_V_U_ack_in,
        data_out => s_axis_video_TDATA_int_regslice,
        vld_out => s_axis_video_TVALID_int_regslice,
        ack_out => s_axis_video_TREADY_int_regslice,
        apdone_blk => regslice_both_s_axis_video_V_data_V_U_apdone_blk);

    regslice_both_s_axis_video_V_keep_V_U : component regslice_both
    generic map (
        DataWidth => 2)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TKEEP,
        vld_in => s_axis_video_TVALID,
        ack_in => regslice_both_s_axis_video_V_keep_V_U_ack_in,
        data_out => s_axis_video_TKEEP_int_regslice,
        vld_out => regslice_both_s_axis_video_V_keep_V_U_vld_out,
        ack_out => s_axis_video_TREADY_int_regslice,
        apdone_blk => regslice_both_s_axis_video_V_keep_V_U_apdone_blk);

    regslice_both_s_axis_video_V_strb_V_U : component regslice_both
    generic map (
        DataWidth => 2)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TSTRB,
        vld_in => s_axis_video_TVALID,
        ack_in => regslice_both_s_axis_video_V_strb_V_U_ack_in,
        data_out => s_axis_video_TSTRB_int_regslice,
        vld_out => regslice_both_s_axis_video_V_strb_V_U_vld_out,
        ack_out => s_axis_video_TREADY_int_regslice,
        apdone_blk => regslice_both_s_axis_video_V_strb_V_U_apdone_blk);

    regslice_both_s_axis_video_V_user_V_U : component regslice_both
    generic map (
        DataWidth => 1)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TUSER,
        vld_in => s_axis_video_TVALID,
        ack_in => regslice_both_s_axis_video_V_user_V_U_ack_in,
        data_out => s_axis_video_TUSER_int_regslice,
        vld_out => regslice_both_s_axis_video_V_user_V_U_vld_out,
        ack_out => s_axis_video_TREADY_int_regslice,
        apdone_blk => regslice_both_s_axis_video_V_user_V_U_apdone_blk);

    regslice_both_s_axis_video_V_last_V_U : component regslice_both
    generic map (
        DataWidth => 1)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TLAST,
        vld_in => s_axis_video_TVALID,
        ack_in => regslice_both_s_axis_video_V_last_V_U_ack_in,
        data_out => s_axis_video_TLAST_int_regslice,
        vld_out => regslice_both_s_axis_video_V_last_V_U_vld_out,
        ack_out => s_axis_video_TREADY_int_regslice,
        apdone_blk => regslice_both_s_axis_video_V_last_V_U_apdone_blk);

    regslice_both_s_axis_video_V_id_V_U : component regslice_both
    generic map (
        DataWidth => 1)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TID,
        vld_in => s_axis_video_TVALID,
        ack_in => regslice_both_s_axis_video_V_id_V_U_ack_in,
        data_out => s_axis_video_TID_int_regslice,
        vld_out => regslice_both_s_axis_video_V_id_V_U_vld_out,
        ack_out => s_axis_video_TREADY_int_regslice,
        apdone_blk => regslice_both_s_axis_video_V_id_V_U_apdone_blk);

    regslice_both_s_axis_video_V_dest_V_U : component regslice_both
    generic map (
        DataWidth => 10)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TDEST,
        vld_in => s_axis_video_TVALID,
        ack_in => regslice_both_s_axis_video_V_dest_V_U_ack_in,
        data_out => s_axis_video_TDEST_int_regslice,
        vld_out => regslice_both_s_axis_video_V_dest_V_U_vld_out,
        ack_out => s_axis_video_TREADY_int_regslice,
        apdone_blk => regslice_both_s_axis_video_V_dest_V_U_apdone_blk);

    regslice_both_m0_axis_video_V_data_V_U : component regslice_both
    generic map (
        DataWidth => 16)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TDATA_int_regslice,
        vld_in => m0_axis_video_TVALID_int_regslice,
        ack_in => m0_axis_video_TREADY_int_regslice,
        data_out => m0_axis_video_TDATA,
        vld_out => regslice_both_m0_axis_video_V_data_V_U_vld_out,
        ack_out => m0_axis_video_TREADY,
        apdone_blk => regslice_both_m0_axis_video_V_data_V_U_apdone_blk);

    regslice_both_m0_axis_video_V_keep_V_U : component regslice_both
    generic map (
        DataWidth => 2)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => ap_const_lv2_0,
        vld_in => m0_axis_video_TVALID_int_regslice,
        ack_in => regslice_both_m0_axis_video_V_keep_V_U_ack_in_dummy,
        data_out => m0_axis_video_TKEEP,
        vld_out => regslice_both_m0_axis_video_V_keep_V_U_vld_out,
        ack_out => m0_axis_video_TREADY,
        apdone_blk => regslice_both_m0_axis_video_V_keep_V_U_apdone_blk);

    regslice_both_m0_axis_video_V_strb_V_U : component regslice_both
    generic map (
        DataWidth => 2)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => ap_const_lv2_0,
        vld_in => m0_axis_video_TVALID_int_regslice,
        ack_in => regslice_both_m0_axis_video_V_strb_V_U_ack_in_dummy,
        data_out => m0_axis_video_TSTRB,
        vld_out => regslice_both_m0_axis_video_V_strb_V_U_vld_out,
        ack_out => m0_axis_video_TREADY,
        apdone_blk => regslice_both_m0_axis_video_V_strb_V_U_apdone_blk);

    regslice_both_m0_axis_video_V_user_V_U : component regslice_both
    generic map (
        DataWidth => 1)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TUSER_int_regslice,
        vld_in => m0_axis_video_TVALID_int_regslice,
        ack_in => regslice_both_m0_axis_video_V_user_V_U_ack_in_dummy,
        data_out => m0_axis_video_TUSER,
        vld_out => regslice_both_m0_axis_video_V_user_V_U_vld_out,
        ack_out => m0_axis_video_TREADY,
        apdone_blk => regslice_both_m0_axis_video_V_user_V_U_apdone_blk);

    regslice_both_m0_axis_video_V_last_V_U : component regslice_both
    generic map (
        DataWidth => 1)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TLAST_int_regslice,
        vld_in => m0_axis_video_TVALID_int_regslice,
        ack_in => regslice_both_m0_axis_video_V_last_V_U_ack_in_dummy,
        data_out => m0_axis_video_TLAST,
        vld_out => regslice_both_m0_axis_video_V_last_V_U_vld_out,
        ack_out => m0_axis_video_TREADY,
        apdone_blk => regslice_both_m0_axis_video_V_last_V_U_apdone_blk);

    regslice_both_m0_axis_video_V_id_V_U : component regslice_both
    generic map (
        DataWidth => 1)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => ap_const_lv1_0,
        vld_in => m0_axis_video_TVALID_int_regslice,
        ack_in => regslice_both_m0_axis_video_V_id_V_U_ack_in_dummy,
        data_out => m0_axis_video_TID,
        vld_out => regslice_both_m0_axis_video_V_id_V_U_vld_out,
        ack_out => m0_axis_video_TREADY,
        apdone_blk => regslice_both_m0_axis_video_V_id_V_U_apdone_blk);

    regslice_both_m0_axis_video_V_dest_V_U : component regslice_both
    generic map (
        DataWidth => 1)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => ap_const_lv1_0,
        vld_in => m0_axis_video_TVALID_int_regslice,
        ack_in => regslice_both_m0_axis_video_V_dest_V_U_ack_in_dummy,
        data_out => m0_axis_video_TDEST,
        vld_out => regslice_both_m0_axis_video_V_dest_V_U_vld_out,
        ack_out => m0_axis_video_TREADY,
        apdone_blk => regslice_both_m0_axis_video_V_dest_V_U_apdone_blk);

    regslice_both_m1_axis_video_V_data_V_U : component regslice_both
    generic map (
        DataWidth => 16)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TDATA_int_regslice,
        vld_in => m1_axis_video_TVALID_int_regslice,
        ack_in => m1_axis_video_TREADY_int_regslice,
        data_out => m1_axis_video_TDATA,
        vld_out => regslice_both_m1_axis_video_V_data_V_U_vld_out,
        ack_out => m1_axis_video_TREADY,
        apdone_blk => regslice_both_m1_axis_video_V_data_V_U_apdone_blk);

    regslice_both_m1_axis_video_V_keep_V_U : component regslice_both
    generic map (
        DataWidth => 2)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => ap_const_lv2_0,
        vld_in => m1_axis_video_TVALID_int_regslice,
        ack_in => regslice_both_m1_axis_video_V_keep_V_U_ack_in_dummy,
        data_out => m1_axis_video_TKEEP,
        vld_out => regslice_both_m1_axis_video_V_keep_V_U_vld_out,
        ack_out => m1_axis_video_TREADY,
        apdone_blk => regslice_both_m1_axis_video_V_keep_V_U_apdone_blk);

    regslice_both_m1_axis_video_V_strb_V_U : component regslice_both
    generic map (
        DataWidth => 2)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => ap_const_lv2_0,
        vld_in => m1_axis_video_TVALID_int_regslice,
        ack_in => regslice_both_m1_axis_video_V_strb_V_U_ack_in_dummy,
        data_out => m1_axis_video_TSTRB,
        vld_out => regslice_both_m1_axis_video_V_strb_V_U_vld_out,
        ack_out => m1_axis_video_TREADY,
        apdone_blk => regslice_both_m1_axis_video_V_strb_V_U_apdone_blk);

    regslice_both_m1_axis_video_V_user_V_U : component regslice_both
    generic map (
        DataWidth => 1)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TUSER_int_regslice,
        vld_in => m1_axis_video_TVALID_int_regslice,
        ack_in => regslice_both_m1_axis_video_V_user_V_U_ack_in_dummy,
        data_out => m1_axis_video_TUSER,
        vld_out => regslice_both_m1_axis_video_V_user_V_U_vld_out,
        ack_out => m1_axis_video_TREADY,
        apdone_blk => regslice_both_m1_axis_video_V_user_V_U_apdone_blk);

    regslice_both_m1_axis_video_V_last_V_U : component regslice_both
    generic map (
        DataWidth => 1)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => s_axis_video_TLAST_int_regslice,
        vld_in => m1_axis_video_TVALID_int_regslice,
        ack_in => regslice_both_m1_axis_video_V_last_V_U_ack_in_dummy,
        data_out => m1_axis_video_TLAST,
        vld_out => regslice_both_m1_axis_video_V_last_V_U_vld_out,
        ack_out => m1_axis_video_TREADY,
        apdone_blk => regslice_both_m1_axis_video_V_last_V_U_apdone_blk);

    regslice_both_m1_axis_video_V_id_V_U : component regslice_both
    generic map (
        DataWidth => 1)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => ap_const_lv1_0,
        vld_in => m1_axis_video_TVALID_int_regslice,
        ack_in => regslice_both_m1_axis_video_V_id_V_U_ack_in_dummy,
        data_out => m1_axis_video_TID,
        vld_out => regslice_both_m1_axis_video_V_id_V_U_vld_out,
        ack_out => m1_axis_video_TREADY,
        apdone_blk => regslice_both_m1_axis_video_V_id_V_U_apdone_blk);

    regslice_both_m1_axis_video_V_dest_V_U : component regslice_both
    generic map (
        DataWidth => 1)
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        data_in => ap_const_lv1_0,
        vld_in => m1_axis_video_TVALID_int_regslice,
        ack_in => regslice_both_m1_axis_video_V_dest_V_U_ack_in_dummy,
        data_out => m1_axis_video_TDEST,
        vld_out => regslice_both_m1_axis_video_V_dest_V_U_vld_out,
        ack_out => m1_axis_video_TREADY,
        apdone_blk => regslice_both_m1_axis_video_V_dest_V_U_apdone_blk);





    ap_CS_fsm_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_CS_fsm <= ap_ST_fsm_state1;
            else
                ap_CS_fsm <= ap_NS_fsm;
            end if;
        end if;
    end process;


    ap_done_reg_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_done_reg <= ap_const_logic_0;
            else
                if ((ap_continue = ap_const_logic_1)) then 
                    ap_done_reg <= ap_const_logic_0;
                elsif ((not(((ap_const_boolean_1 = ap_block_state2_io) or (regslice_both_m1_axis_video_V_data_V_U_apdone_blk = ap_const_logic_1) or (regslice_both_m0_axis_video_V_data_V_U_apdone_blk = ap_const_logic_1))) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
                    ap_done_reg <= ap_const_logic_1;
                end if; 
            end if;
        end if;
    end process;

    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((not(((ap_start = ap_const_logic_0) or (ap_const_boolean_1 = ap_block_state1_io) or (s_axis_video_TVALID_int_regslice = ap_const_logic_0) or (ap_done_reg = ap_const_logic_1))) and (ap_const_logic_1 = ap_CS_fsm_state1))) then
                tmp_dest_V_reg_182 <= s_axis_video_TDEST_int_regslice;
            end if;
        end if;
    end process;

    ap_NS_fsm_assign_proc : process (ap_start, ap_done_reg, ap_CS_fsm, ap_CS_fsm_state1, ap_CS_fsm_state2, ap_block_state1_io, regslice_both_m0_axis_video_V_data_V_U_apdone_blk, regslice_both_m1_axis_video_V_data_V_U_apdone_blk, ap_block_state2_io, s_axis_video_TVALID_int_regslice)
    begin
        case ap_CS_fsm is
            when ap_ST_fsm_state1 => 
                if ((not(((ap_start = ap_const_logic_0) or (ap_const_boolean_1 = ap_block_state1_io) or (s_axis_video_TVALID_int_regslice = ap_const_logic_0) or (ap_done_reg = ap_const_logic_1))) and (ap_const_logic_1 = ap_CS_fsm_state1))) then
                    ap_NS_fsm <= ap_ST_fsm_state2;
                else
                    ap_NS_fsm <= ap_ST_fsm_state1;
                end if;
            when ap_ST_fsm_state2 => 
                if ((not(((ap_const_boolean_1 = ap_block_state2_io) or (regslice_both_m1_axis_video_V_data_V_U_apdone_blk = ap_const_logic_1) or (regslice_both_m0_axis_video_V_data_V_U_apdone_blk = ap_const_logic_1))) and (ap_const_logic_1 = ap_CS_fsm_state2))) then
                    ap_NS_fsm <= ap_ST_fsm_state1;
                else
                    ap_NS_fsm <= ap_ST_fsm_state2;
                end if;
            when others =>  
                ap_NS_fsm <= "XX";
        end case;
    end process;
    ap_CS_fsm_state1 <= ap_CS_fsm(0);
    ap_CS_fsm_state2 <= ap_CS_fsm(1);

    ap_block_state1_assign_proc : process(ap_start, ap_done_reg, s_axis_video_TVALID_int_regslice)
    begin
                ap_block_state1 <= ((ap_start = ap_const_logic_0) or (s_axis_video_TVALID_int_regslice = ap_const_logic_0) or (ap_done_reg = ap_const_logic_1));
    end process;


    ap_block_state1_io_assign_proc : process(s_axis_video_TDEST_int_regslice, m0_axis_video_TREADY_int_regslice, m1_axis_video_TREADY_int_regslice)
    begin
                ap_block_state1_io <= (((s_axis_video_TDEST_int_regslice = ap_const_lv10_2C1) and (m1_axis_video_TREADY_int_regslice = ap_const_logic_0)) or ((s_axis_video_TDEST_int_regslice = ap_const_lv10_2C0) and (m0_axis_video_TREADY_int_regslice = ap_const_logic_0)));
    end process;


    ap_block_state2_assign_proc : process(regslice_both_m0_axis_video_V_data_V_U_apdone_blk, regslice_both_m1_axis_video_V_data_V_U_apdone_blk)
    begin
                ap_block_state2 <= ((regslice_both_m1_axis_video_V_data_V_U_apdone_blk = ap_const_logic_1) or (regslice_both_m0_axis_video_V_data_V_U_apdone_blk = ap_const_logic_1));
    end process;


    ap_block_state2_io_assign_proc : process(tmp_dest_V_reg_182, m0_axis_video_TREADY_int_regslice, m1_axis_video_TREADY_int_regslice)
    begin
                ap_block_state2_io <= (((tmp_dest_V_reg_182 = ap_const_lv10_2C1) and (m1_axis_video_TREADY_int_regslice = ap_const_logic_0)) or ((tmp_dest_V_reg_182 = ap_const_lv10_2C0) and (m0_axis_video_TREADY_int_regslice = ap_const_logic_0)));
    end process;


    ap_done_assign_proc : process(ap_done_reg, ap_CS_fsm_state2, regslice_both_m0_axis_video_V_data_V_U_apdone_blk, regslice_both_m1_axis_video_V_data_V_U_apdone_blk, ap_block_state2_io)
    begin
        if ((not(((ap_const_boolean_1 = ap_block_state2_io) or (regslice_both_m1_axis_video_V_data_V_U_apdone_blk = ap_const_logic_1) or (regslice_both_m0_axis_video_V_data_V_U_apdone_blk = ap_const_logic_1))) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
            ap_done <= ap_const_logic_1;
        else 
            ap_done <= ap_done_reg;
        end if; 
    end process;


    ap_idle_assign_proc : process(ap_start, ap_CS_fsm_state1)
    begin
        if (((ap_start = ap_const_logic_0) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
            ap_idle <= ap_const_logic_1;
        else 
            ap_idle <= ap_const_logic_0;
        end if; 
    end process;


    ap_ready_assign_proc : process(ap_CS_fsm_state2, regslice_both_m0_axis_video_V_data_V_U_apdone_blk, regslice_both_m1_axis_video_V_data_V_U_apdone_blk, ap_block_state2_io)
    begin
        if ((not(((ap_const_boolean_1 = ap_block_state2_io) or (regslice_both_m1_axis_video_V_data_V_U_apdone_blk = ap_const_logic_1) or (regslice_both_m0_axis_video_V_data_V_U_apdone_blk = ap_const_logic_1))) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
            ap_ready <= ap_const_logic_1;
        else 
            ap_ready <= ap_const_logic_0;
        end if; 
    end process;


    m0_axis_video_TDATA_blk_n_assign_proc : process(ap_start, ap_done_reg, ap_CS_fsm_state1, ap_CS_fsm_state2, tmp_dest_V_reg_182, s_axis_video_TDEST_int_regslice, m0_axis_video_TREADY_int_regslice)
    begin
        if ((((tmp_dest_V_reg_182 = ap_const_lv10_2C0) and (ap_const_logic_1 = ap_CS_fsm_state2)) or (not(((ap_start = ap_const_logic_0) or (ap_done_reg = ap_const_logic_1))) and (s_axis_video_TDEST_int_regslice = ap_const_lv10_2C0) and (ap_const_logic_1 = ap_CS_fsm_state1)))) then 
            m0_axis_video_TDATA_blk_n <= m0_axis_video_TREADY_int_regslice;
        else 
            m0_axis_video_TDATA_blk_n <= ap_const_logic_1;
        end if; 
    end process;

    m0_axis_video_TVALID <= regslice_both_m0_axis_video_V_data_V_U_vld_out;

    m0_axis_video_TVALID_int_regslice_assign_proc : process(ap_start, ap_done_reg, ap_CS_fsm_state1, ap_block_state1_io, s_axis_video_TVALID_int_regslice, s_axis_video_TDEST_int_regslice)
    begin
        if ((not(((ap_start = ap_const_logic_0) or (ap_const_boolean_1 = ap_block_state1_io) or (s_axis_video_TVALID_int_regslice = ap_const_logic_0) or (ap_done_reg = ap_const_logic_1))) and (s_axis_video_TDEST_int_regslice = ap_const_lv10_2C0) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
            m0_axis_video_TVALID_int_regslice <= ap_const_logic_1;
        else 
            m0_axis_video_TVALID_int_regslice <= ap_const_logic_0;
        end if; 
    end process;


    m1_axis_video_TDATA_blk_n_assign_proc : process(ap_start, ap_done_reg, ap_CS_fsm_state1, ap_CS_fsm_state2, tmp_dest_V_reg_182, s_axis_video_TDEST_int_regslice, m1_axis_video_TREADY_int_regslice)
    begin
        if ((((tmp_dest_V_reg_182 = ap_const_lv10_2C1) and (ap_const_logic_1 = ap_CS_fsm_state2)) or (not(((ap_start = ap_const_logic_0) or (ap_done_reg = ap_const_logic_1))) and (s_axis_video_TDEST_int_regslice = ap_const_lv10_2C1) and (ap_const_logic_1 = ap_CS_fsm_state1)))) then 
            m1_axis_video_TDATA_blk_n <= m1_axis_video_TREADY_int_regslice;
        else 
            m1_axis_video_TDATA_blk_n <= ap_const_logic_1;
        end if; 
    end process;

    m1_axis_video_TVALID <= regslice_both_m1_axis_video_V_data_V_U_vld_out;

    m1_axis_video_TVALID_int_regslice_assign_proc : process(ap_start, ap_done_reg, ap_CS_fsm_state1, ap_block_state1_io, s_axis_video_TVALID_int_regslice, s_axis_video_TDEST_int_regslice)
    begin
        if ((not(((ap_start = ap_const_logic_0) or (ap_const_boolean_1 = ap_block_state1_io) or (s_axis_video_TVALID_int_regslice = ap_const_logic_0) or (ap_done_reg = ap_const_logic_1))) and (s_axis_video_TDEST_int_regslice = ap_const_lv10_2C1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
            m1_axis_video_TVALID_int_regslice <= ap_const_logic_1;
        else 
            m1_axis_video_TVALID_int_regslice <= ap_const_logic_0;
        end if; 
    end process;


    s_axis_video_TDATA_blk_n_assign_proc : process(ap_start, ap_done_reg, ap_CS_fsm_state1, s_axis_video_TVALID_int_regslice)
    begin
        if ((not(((ap_start = ap_const_logic_0) or (ap_done_reg = ap_const_logic_1))) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
            s_axis_video_TDATA_blk_n <= s_axis_video_TVALID_int_regslice;
        else 
            s_axis_video_TDATA_blk_n <= ap_const_logic_1;
        end if; 
    end process;

    s_axis_video_TREADY <= regslice_both_s_axis_video_V_data_V_U_ack_in;

    s_axis_video_TREADY_int_regslice_assign_proc : process(ap_start, ap_done_reg, ap_CS_fsm_state1, ap_block_state1_io, s_axis_video_TVALID_int_regslice)
    begin
        if ((not(((ap_start = ap_const_logic_0) or (ap_const_boolean_1 = ap_block_state1_io) or (s_axis_video_TVALID_int_regslice = ap_const_logic_0) or (ap_done_reg = ap_const_logic_1))) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
            s_axis_video_TREADY_int_regslice <= ap_const_logic_1;
        else 
            s_axis_video_TREADY_int_regslice <= ap_const_logic_0;
        end if; 
    end process;

end behav;
