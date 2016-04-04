--IIR Filter top module, Highpass, Lowpass, Bandpass
--Author: Ovie, Tsotnep, xilinx

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter_top is
	port(
		AUDIO_OUT_L : out std_logic_vector(23 downto 0); --external output
		AUDIO_OUT_R : out std_logic_vector(23 downto 0); --external output
		FILTER_DONE : out std_logic;    --external output

		AUDIO_IN_L  : in  std_logic_vector(23 downto 0); --external input
		AUDIO_IN_R  : in  std_logic_vector(23 downto 0); --external input

		RST         : in  std_logic;    --slv_reg0(0) of AXI bus
		HP_BTN      : in  std_logic;    --slv_reg1(0) of AXI bus
		BP_BTN      : in  std_logic;    --slv_reg2(0) of AXI bus
		LP_BTN      : in  std_logic;    --slv_reg3(0) of AXI bus

		CLK_48      : in  std_logic     --external input
	);
end entity filter_top;

architecture RTL of filter_top is
	constant Sample_trig                                                                                                                        : STD_LOGIC := '1';
	signal IIR_LP_Done_R, IIR_LP_Done_L, IIR_BP_Done_R, IIR_BP_Done_L, IIR_HP_Done_R, IIR_HP_Done_L                                             : std_logic;
	signal AUDIO_OUT_TRUNC_L, AUDIO_OUT_TRUNC_R, IIR_LP_Y_Out_R, IIR_LP_Y_Out_L, IIR_BP_Y_Out_R, IIR_BP_Y_Out_L, IIR_HP_Y_Out_R, IIR_HP_Y_Out_L : std_logic_vector(15 downto 0);
	component IIR_Biquad_II is
		generic(
			Coef_b0 : std_logic_vector(31 downto 0) := B"00_00_0000_0001_0000_1100_0011_1001_1100"; -- b0		~ +0.0010232
			Coef_b1 : std_logic_vector(31 downto 0) := B"00_00_0000_0010_0001_1000_0111_0011_1001"; -- b1		~ +0.0020464
			Coef_b2 : std_logic_vector(31 downto 0) := B"00_00_0000_0001_0000_1100_0011_1001_1100"; -- b2		~ +0.0010232
			Coef_a1 : std_logic_vector(31 downto 0) := B"10_00_0101_1110_1011_0111_1110_0110_1000"; -- a1		~ -1.9075016 	
			Coef_a2 : std_logic_vector(31 downto 0) := B"00_11_1010_0101_0111_1001_0000_0111_0101"
		);
		port(
			clk         : in  STD_LOGIC;
			rst         : in  STD_LOGIC;
			sample_trig : in  STD_LOGIC;
			X_in        : in  STD_LOGIC_VECTOR(15 downto 0);
			filter_done : out STD_LOGIC;
			Y_out       : out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
begin

	---- connect all the "filter done" with an AND gate to the user_logic top level entity.
	FILTER_DONE <= IIR_LP_Done_R and IIR_LP_Done_L and IIR_BP_Done_R and IIR_BP_Done_L and IIR_HP_Done_R and IIR_HP_Done_L;

	-----Pad the Audio output with 8 zeros to make it up to 24 bit,
	AUDIO_OUT_L <= AUDIO_OUT_TRUNC_L & X"00";
	AUDIO_OUT_R <= AUDIO_OUT_TRUNC_R & X"00";

	---this process controls each individual filter and the final output of the filter. 
	process(HP_BTN, BP_BTN, LP_BTN, IIR_BP_Y_Out_L, IIR_BP_Y_Out_R, IIR_HP_Y_Out_L, IIR_HP_Y_Out_R, IIR_LP_Y_Out_L, IIR_LP_Y_Out_R)
		variable VAL : std_logic_vector(2 downto 0);
	begin
		VAL := HP_BTN & BP_BTN & LP_BTN;
		case VAL is
			when "000" =>
				AUDIO_OUT_TRUNC_L <= (others => '0');
				AUDIO_OUT_TRUNC_R <= (others => '0');
			when "001" =>
				AUDIO_OUT_TRUNC_L <= IIR_LP_Y_Out_L;
				AUDIO_OUT_TRUNC_R <= IIR_LP_Y_Out_R;
			when "010" =>
				AUDIO_OUT_TRUNC_L <= IIR_BP_Y_Out_L;
				AUDIO_OUT_TRUNC_R <= IIR_BP_Y_Out_R;
			when "011" =>
				AUDIO_OUT_TRUNC_L <= std_logic_vector(unsigned(IIR_LP_Y_Out_L) + unsigned(IIR_BP_Y_Out_L));
				AUDIO_OUT_TRUNC_R <= std_logic_vector(unsigned(IIR_LP_Y_Out_R) + unsigned(IIR_BP_Y_Out_R));
			when "100" =>
				AUDIO_OUT_TRUNC_L <= IIR_HP_Y_Out_L;
				AUDIO_OUT_TRUNC_R <= IIR_HP_Y_Out_R;
			when "101" =>
				AUDIO_OUT_TRUNC_L <= std_logic_vector(unsigned(IIR_LP_Y_Out_L) + unsigned(IIR_HP_Y_Out_L));
				AUDIO_OUT_TRUNC_R <= std_logic_vector(unsigned(IIR_LP_Y_Out_R) + unsigned(IIR_HP_Y_Out_R));
			when "110" =>
				AUDIO_OUT_TRUNC_L <= std_logic_vector(unsigned(IIR_HP_Y_Out_L) + unsigned(IIR_BP_Y_Out_L));
				AUDIO_OUT_TRUNC_R <= std_logic_vector(unsigned(IIR_HP_Y_Out_R) + unsigned(IIR_BP_Y_Out_R));
			when "111" =>
				AUDIO_OUT_TRUNC_L <= std_logic_vector(unsigned(IIR_LP_Y_Out_L) + unsigned(IIR_BP_Y_Out_L) + unsigned(IIR_HP_Y_Out_L));
				AUDIO_OUT_TRUNC_R <= std_logic_vector(unsigned(IIR_LP_Y_Out_R) + unsigned(IIR_BP_Y_Out_R) + unsigned(IIR_HP_Y_Out_R));
			when others =>
				AUDIO_OUT_TRUNC_L <= (others => '0');
				AUDIO_OUT_TRUNC_R <= (others => '0');
		end case;
	end process;

	IIR_LP_R : IIR_Biquad_II
		generic map(
			Coef_b0 => B"00_00_0000_0001_0000_1100_0011_1001_1100", -- b0		~ +0.0010232
			Coef_b1 => B"00_00_0000_0010_0001_1000_0111_0011_1001", -- b1		~ +0.0020464
			Coef_b2 => B"00_00_0000_0001_0000_1100_0011_1001_1100", -- b2		~ +0.0010232
			Coef_a1 => B"10_00_0101_1110_1011_0111_1110_0110_1000", -- a1		~ -1.9075016 	
			Coef_a2 => B"00_11_1010_0101_0111_1001_0000_0111_0101" -- a2		~ +0.9115945
		)
		port map(
			clk         => CLK_48,
			rst         => RST,
			sample_trig => Sample_trig, --Sample_IIR,
			X_in        => AUDIO_IN_R(23 downto 8),
			filter_done => IIR_LP_Done_R,
			Y_out       => IIR_LP_Y_Out_R
		);

	IIR_LP_L : IIR_Biquad_II
		generic map(
			Coef_b0 => B"00_00_0000_0001_0000_1100_0011_1001_1100", -- b0		~ +0.0010232							  
			Coef_b1 => B"00_00_0000_0010_0001_1000_0111_0011_1001", -- b1		~ +0.0020464
			Coef_b2 => B"00_00_0000_0001_0000_1100_0011_1001_1100", -- b2		~ +0.0010232
			Coef_a1 => B"10_00_0101_1110_1011_0111_1110_0110_1000", -- a1		~ -1.9075016	
			Coef_a2 => B"00_11_1010_0101_0111_1001_0000_0111_0101" -- a2		~ +0.9115945
		)
		port map(
			clk         => CLK_48,
			rst         => RST,
			sample_trig => Sample_trig, --Sample_IIR,
			X_in        => AUDIO_IN_L(23 downto 8), --X_in_truncated_L,
			filter_done => IIR_LP_Done_L,
			Y_out       => IIR_LP_Y_Out_L
		);

	IIR_BP_R : IIR_Biquad_II            --(20 - 20000)
		generic map(
			Coef_b0 => B"00_00_1101_1001_0100_1010_0010_0011_0000", -- b0	~ +0.212196872
			Coef_b1 => B"11_10_0101_0001_1010_0101_0110_1110_1000", -- b1		~ -0.420267366
			Coef_b2 => B"00_00_1101_1001_0100_1010_0010_0011_0000", -- b2		~ +0.212196872
			Coef_a1 => B"11_10_0101_0001_1010_0101_0110_1110_1000", -- a1		~ -0.575606257	
			Coef_a2 => B"11_01_1011_0010_1001_0100_0100_0110_0000" -- a2		~ +0.986994963	
		)
		port map(
			clk         => CLK_48,
			rst         => RST,
			sample_trig => Sample_trig, --Sample_IIR,
			X_in        => AUDIO_IN_R(23 downto 8), --X_in_truncated_R,
			filter_done => IIR_BP_Done_R,
			Y_out       => IIR_BP_Y_Out_R
		);

	IIR_BP_L : IIR_Biquad_II            --(20 - 20000)
		generic map(
			Coef_b0 => B"00_00_1101_1001_0100_1010_0010_0011_0000", -- b0		~ +0.212196872
			Coef_b1 => B"11_10_0101_0001_1010_0101_0110_1110_1000", -- b1		~ -0.420267366
			Coef_b2 => B"00_00_1101_1001_0100_1010_0010_0011_0000", -- b2		~ +0.212196872
			Coef_a1 => B"11_10_0101_0001_1010_0101_0110_1110_1000", -- a1		~ -0.575606257	
			Coef_a2 => B"11_01_1011_0010_1001_0100_0100_0110_0000" -- a2		~ +0.986994963
		)
		port map(
			clk         => CLK_48,
			rst         => RST,
			sample_trig => Sample_trig, --Sample_IIR,
			X_in        => AUDIO_IN_L(23 downto 8), --X_in_truncated_L,
			filter_done => IIR_BP_Done_L,
			Y_out       => IIR_BP_Y_Out_L
		);

	IIR_HP_R : IIR_Biquad_II
		generic map(
			Coef_b0 => B"00_00_0000_0000_1010_1011_0111_0101_1110", -- b0		~ +0.00065407
			Coef_b1 => B"00_00_0000_0000_0000_0000_0000_0000_0000", -- b1		~ 0.0
			Coef_b2 => B"11_11_1111_1111_0101_0100_1000_1010_0010", -- b2		~ -0.00065407
			Coef_a1 => B"10_00_0000_0001_0110_0100_0110_0011_0100", -- a1		~ -1.998640489	
			Coef_a2 => B"00_11_1111_1110_1010_1001_0001_0100_0010" -- a2		~ +0.998691859	

		)
		port map(
			clk         => CLK_48,
			rst         => RST,
			sample_trig => Sample_trig, --Sample_IIR,
			X_in        => AUDIO_IN_R(23 downto 8), --X_in_truncated_R,
			filter_done => IIR_HP_Done_R,
			Y_out       => IIR_HP_Y_Out_R
		);

	IIR_HP_L : IIR_Biquad_II
		generic map(
			Coef_b0 => B"00_00_0000_0000_1010_1011_0111_0101_1110", -- b0		~ +0.00065407
			Coef_b1 => B"00_00_0000_0000_0000_0000_0000_0000_0000", -- b1		~ 0.0
			Coef_b2 => B"11_11_1111_1111_0101_0100_1000_1010_0010", -- b2		~ -0.00065407
			Coef_a1 => B"10_00_0000_0001_0110_0100_0110_0011_0100", -- a1		~ -1.998640489	
			Coef_a2 => B"00_11_1111_1110_1010_1001_0001_0100_0010" -- a2		~ +0.998691859	

		)
		port map(
			clk         => CLK_48,
			rst         => RST,
			sample_trig => Sample_trig, --Sample_IIR,
			X_in        => AUDIO_IN_L(23 downto 8), --X_in_truncated_L,
			filter_done => IIR_HP_Done_L,
			Y_out       => IIR_HP_Y_Out_L
		);
------------------------------------------


end architecture RTL;
