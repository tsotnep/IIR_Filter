--////////////////////// IIR_Biquad_II /////////////////////////////////--
-- ***********************************************************************
-- FileName: IIR_Biquad_II.vhd
-- FPGA: Xilinx Spartan 6
-- IDE: Xilinx ISE 13.1 
--
-- HDL IS PROVIDED "AS IS." DIGI-KEY EXPRESSLY DISCLAIMS ANY
-- WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
-- PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
-- BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
-- DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
-- PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
-- BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
-- ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
-- DIGI-KEY ALSO DISCLAIMS ANY LIABILITY FOR PATENT OR COPYRIGHT
-- INFRINGEMENT.
--
-- Version History
-- Version 1.0 7/31/2012 Tony Storey
-- Initial Public Releaselibrary ieee;


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity IIR_Biquad_II is
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
end IIR_Biquad_II;

architecture arch of IIR_Biquad_II is

	-- band stop butterworth  2nd order  fo = 59.79, fl = 55Hz, fu = 65Hz, Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
	--------------------------------------------------------------------------
	--	
	--			           b0 + b1*Z^-1 + b2*Z^-2
	--				H[z] = -------------------------
	--						  1 + a1*Z^-1 + a2*Z^-2
	--
	--------------------------------------------------------------------------	

	-- define biquad coefficients --WORKED WITH HIGH SOUND
	--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_11_1111_1111_1101_1101_1011_0000_1001";				-- b0		~ +0.999869117
	--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"10_00_0000_0000_0101_0100_1100_1000_1010";				-- b1		~ -1.999676575
	--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"00_11_1111_1111_1101_1101_1011_0000_1001";				-- b2		~ +0.999869117	
	--
	--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"10_00_0000_0000_0101_0100_1100_1000_1010";				-- a1		~ -1.999676575 	
	--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_11_1111_1111_1011_1011_0110_0001_0011";				-- a2		~ +0.999738235


	-- Pre Generated Example IIR filters
	-------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------


	--	-- band pass  2nd order butterworth  f0 = 2000Hz, fl = 1500Hz, fu = 2500 Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
	--	--------------------------------------------------------------------------
	----	
	----			           b0 + b1*Z^-1 + b2*Z^-2
	----				H[z] = -------------------------
	----						  1 + a1*Z^-1 + a2*Z^-2
	----
	--	--------------------------------------------------------------------------	
	--
	---- define biquad coefficients --DID NOT WORK NO SOUND
	--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_00_0011_1110_1111_1100_1111_0000_1111";				-- b0		~ +0.061511769
	--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"00_00_0000_0000_0000_0000_0000_0000_0000";				-- b1		~ 0.0
	--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"11_11_1100_0001_0000_0011_0000_1111_0001";				-- b0		~ -0.061511769	
	--
	--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"10_00_1011_1011_0111_1011_1110_0101_0111";				-- a1		~ -1.816910185 	
	--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_11_1000_0010_0000_0110_0001_1110_0010";				-- a2		~ +0.876976463

	--	-- band pass  2nd order elliptical  fl= 7200Hz, fu = 7400Hz, Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
	--	--------------------------------------------------------------------------
	----	
	----			           b0 + b1*Z^-1 + b2*Z^-2
	----				H[z] = -------------------------
	----						  1 + a1*Z^-1 + a2*Z^-2
	----
	--	--------------------------------------------------------------------------	
	--
	---- define biquad coefficients --WORKED WITH VERY HIGH SOUND
	--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_11_1111_1101_0010_0010_0011_1010_0101";				-- b0		~ +0.9944543
	--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"10_11_0110_1000_0111_0101_1111_1101_1011";				-- b1		~ -1.1479874
	--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"00_11_1111_1101_0010_0010_0011_1010_0101";				-- b2		~ +0.9944543
	--
	--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"10_11_0110_1000_0111_0101_1111_1101_1011";				-- a1		~ -1.1479874 	
	--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_11_1111_0100_1010_0100_0111_0100_1011";				-- a2		~ +0.9889086


	--	 stop band  2nd order butterworth  f0 = 3000Hz, fl = 2000Hz, fu = 4000Hz,  Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
	--	--------------------------------------------------------------------------
	----	
	----			           b0 + b1*Z^-1 + b2*Z^-2
	----				H[z] = -------------------------
	----						  1 + a1*Z^-1 + a2*Z^-2
	----
	--	--------------------------------------------------------------------------	
	--
	---- define biquad coefficients -- WORKED WITH VERY HIGH SOUND
	--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_11_1000_1000_1101_1111_0001_1100_0110";				-- b0		~ +0.8836636
	--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"10_01_0110_1001_1001_0110_1000_0001_1011";				-- b1		~ -1.6468868
	--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"00_11_1000_1000_1101_1111_0001_1100_0110";				-- b2		~ +0.8836636	
	--
	--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"10_01_0110_1001_1001_0110_1000_0001_1011";				-- a1		~ -1.6468868 	
	--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_11_0001_0001_1011_1110_0011_1000_1011";				-- a2		~ +0.7673272


	--	-- band pass  2nd order elliptical  fl= 2000Hz, fu = 2500Hz, Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
	--	--------------------------------------------------------------------------
	----	
	----			           b0 + b1*Z^-1 + b2*Z^-2
	----				H[z] = -------------------------
	----						  1 + a1*Z^-1 + a2*Z^-2
	----
	--	--------------------------------------------------------------------------	
	--
	---- define biquad coefficients DID NOT WORK NO SOUND
	--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_00_0100_1001_0001_0011_0101_0100_0111";				-- b0		~ +0.0713628
	--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"00_00_0000_0000_0000_0000_0000_0000_0000";				-- b1		~ +0.0
	--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"11_11_1011_0110_1110_1100_1010_1011_1000";				-- b2		~ -0.0713628
	--
	--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"10_00_1110_0011_0001_0001_1010_1011_1111";				-- a1		~ -1.7782529 	
	--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_11_0110_1101_1101_1001_0101_0111_0001";				-- a2		~ +0.8572744


	--   -- Used Bilinear Z Transform
	--	-- low pass  2nd order butterworth  fc = 12000Hz, Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
	--	--------------------------------------------------------------------------
	----	
	----			           b0 + b1*Z^-1 + b2*Z^-2
	----				H[z] = -------------------------
	----						  1 + a1*Z^-1 + a2*Z^-2
	----
	--	--------------------------------------------------------------------------	
	--
	---- define biquad coefficients --WORKED WITH VERY HIGH SOUND
	--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_01_0010_1011_1110_1100_0011_0011_0011";				-- b0		~ +0.292893219
	--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"00_10_0101_0111_1101_1000_0110_0110_0110";				-- b1		~ +0.585786438
	--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"00_01_0010_1011_1110_1100_0011_0011_0011";				-- b2		~ +0.292893219
	--
	--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"00_00_0000_0000_0000_0000_0000_0000_0000";				-- a1		~ 0.0 	
	--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_00_0000_0000_0000_0101_0111_1101_1000";				-- a2		~ +0.171572875


	--
	--	-- stop band  2nd order butterworth  f0 = 3000Hz, fl = 2000Hz, fu = 4000Hz,  Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
	--	--------------------------------------------------------------------------
	----	
	----			           b0 + b1*Z^-1 + b2*Z^-2
	----				H[z] = -------------------------
	----						  1 + a1*Z^-1 + a2*Z^-2
	----
	--	--------------------------------------------------------------------------	
	--
	---- define biquad coefficients WORKED WITH VERY HIGH SOUND
	--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_11_1000_1000_1101_1111_0001_1100_0110";				-- b0		~ +0.8836636
	--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"10_01_0110_1001_1001_0110_1000_0001_1011";				-- b1		~ -1.6468868
	--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"00_11_1000_1000_1101_1111_0001_1100_0110";				-- b2		~ +0.8836636	
	--
	--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"10_01_0110_1001_1001_0110_1000_0001_1011";				-- a1		~ -1.6468868 	
	--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_11_0001_0001_1011_1110_0011_1000_1011";				-- a2		~ +0.7673272

	--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_00_0000_0001_0000_1100_0011_1001_1100";				-- b0		~ +0.0010232
	--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"00_00_0000_0010_0001_1000_0111_0011_1001";				-- b1		~ +0.0020464
	--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"00_00_0000_0001_0000_1100_0011_1001_1100";				-- b2		~ +0.0010232	
	--
	--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"10_00_0101_1110_1011_0111_1110_0110_1000";				-- a1		~ -1.9075016 	
	--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_11_1010_0101_0111_1001_0000_0111_0101";				-- a2		~ +0.9115945


	-- define each pre gain sample flip flop
	signal ZFF_X0, ZFF_X1, ZFF_X2, ZFF_Y1, ZFF_Y2 : std_logic_vector(31 downto 0) := (others => '0');

	-- define each post gain 64 bit sample
	signal pgZFF_X0_quad, pgZFF_X1_quad, pgZFF_X2_quad, pgZFF_Y1_quad, pgZFF_Y2_quad : std_logic_vector(63 downto 0) := (others => '0');

	-- define each post gain 32 but truncated sample
	signal pgZFF_X0, pgZFF_X1, pgZFF_X2, pgZFF_Y1, pgZFF_Y2 : std_logic_vector(31 downto 0) := (others => '0');

	-- define output double reg
	signal Y_out_double : std_logic_vector(31 downto 0) := (others => '0');

	-- state machine signals
	type state_type is (idle, run);
	signal state_reg, state_next : state_type;

	-- counter signals
	signal q_reg, q_next  : unsigned(2 downto 0);
	signal q_reset, q_add : std_logic;

	-- data path flags
	signal mul_coefs, trunc_prods, sum_stg_a, trunc_out : std_logic;

begin

	-- process to shift samples
	process(clk, rst)
	begin
		if (rst = '0') then
			ZFF_X0 <= (others => '0');
			ZFF_X1 <= (others => '0');
			ZFF_X2 <= (others => '0');
			ZFF_Y1 <= (others => '0');
			ZFF_Y2 <= (others => '0');

		elsif (rising_edge(clk)) then
			if (sample_trig = '1' and state_reg = idle) then
				ZFF_X0 <= X_in(15) & X_in(15) & X_in(15) & X_in(15) & X_in & B"0000_0000_0000"; -- X_in(17) & X_in(17) & X_in & B"0000_0000_0000";
				ZFF_X1 <= ZFF_X0;
				ZFF_X2 <= ZFF_X1;
				ZFF_Y1 <= Y_out_double;
				ZFF_Y2 <= ZFF_Y1;
			end if;
		end if;
	end process;

	-- STATE UPDATE AND TIMING
	process(clk, rst)
	begin
		if (rst = '0') then
			state_reg <= idle;
			q_reg     <= (others => '0'); -- reset counter
		elsif (rising_edge(clk)) then
			state_reg <= state_next;    -- update the state
			q_reg     <= q_next;
		end if;
	end process;

	-- COUNTER FOR TIMING 
	q_next <= (others => '0') when q_reset = '1' else -- resets the counter 
		q_reg + 1 when q_add = '1' else -- increment count if commanded
		q_reg;

	-- process for control of data path flags
	process(q_reg, state_reg, sample_trig)
	begin

		-- defaults
		q_reset     <= '0';
		q_add       <= '0';
		mul_coefs   <= '0';
		trunc_prods <= '0';
		sum_stg_a   <= '0';
		trunc_out   <= '0';
		filter_done <= '0';

		case state_reg is
			when idle =>
				if (sample_trig = '1') then
					state_next <= run;
				else
					state_next <= idle;
				end if;

			when run =>
				if (q_reg < B"001") then
					q_add      <= '1';
					state_next <= run;
				elsif (q_reg < "011") then
					mul_coefs  <= '1';
					q_add      <= '1';
					state_next <= run;
				elsif (q_reg < "100") then
					trunc_prods <= '1';
					q_add       <= '1';
					state_next  <= run;
				elsif (q_reg < "101") then
					sum_stg_a  <= '1';
					q_add      <= '1';
					state_next <= run;
				elsif (q_reg < "110") then
					trunc_out  <= '1';
					q_add      <= '1';
					state_next <= run;
				else
					q_reset     <= '1';
					filter_done <= '1';
					state_next  <= idle;
				end if;

		end case;
	end process;

	-- add gain factors to numerator of biquad (feed forward path)
	pgZFF_X0_quad <= std_logic_vector(signed(Coef_b0) * signed(ZFF_X0)) when mul_coefs = '1';
	pgZFF_X1_quad <= std_logic_vector(signed(Coef_b1) * signed(ZFF_X1)) when mul_coefs = '1';
	pgZFF_X2_quad <= std_logic_vector(signed(Coef_b2) * signed(ZFF_X2)) when mul_coefs = '1';

	-- add gain factors to denominator of biquad (feed back path)
	pgZFF_Y1_quad <= std_logic_vector(signed(Coef_a1) * signed(ZFF_Y1)) when mul_coefs = '1';
	pgZFF_Y2_quad <= std_logic_vector(signed(Coef_a2) * signed(ZFF_Y2)) when mul_coefs = '1';

	-- truncate the output to summation block
	process(clk)
	begin
		if rising_edge(clk) then
			if (trunc_prods = '1') then
				pgZFF_X0 <= pgZFF_X0_quad(61 downto 30);
				pgZFF_X2 <= pgZFF_X2_quad(61 downto 30);
				pgZFF_X1 <= pgZFF_X1_quad(61 downto 30);
				pgZFF_Y1 <= pgZFF_Y1_quad(61 downto 30);
				pgZFF_Y2 <= pgZFF_Y2_quad(61 downto 30);
			end if;
		end if;
	end process;

	-- sum all post gain feedback and feedfoward paths
	-- Y[z] = X[z]*bo + X[z]*b1*Z^-1 + X[z]*b2*Z^-2 - Y[z]*a1*z^-1 + Y[z]*a2*z^-2
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (sum_stg_a = '1') then
				Y_out_double <= std_logic_vector(signed(pgZFF_X0) + signed(pgZFF_X1) + signed(pgZFF_X2) - signed(pgZFF_Y1) - signed(pgZFF_Y2));
			end if;
		end if;
	end process;

	-- output truncation block
	process(clk)
	begin
		if rising_edge(clk) then
			if (trunc_out = '1') then
				Y_out <= Y_out_double(30 downto 15);
			end if;
		end if;
	end process;
end arch;

-- Pre Generated Example IIR filters
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------


--	-- band pass  2nd order butterworth  f0 = 2000Hz, fl = 1500Hz, fu = 2500 Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
--	--------------------------------------------------------------------------
----	
----			           b0 + b1*Z^-1 + b2*Z^-2
----				H[z] = -------------------------
----						  1 + a1*Z^-1 + a2*Z^-2
----
--	--------------------------------------------------------------------------	
--
---- define biquad coefficients
--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_00_0011_1110_1111_1100_1111_0000_1111";				-- b0		~ +0.061511769
--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"00_00_0000_0000_0000_0000_0000_0000_0000";				-- b1		~ 0.0
--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"11_11_1100_0001_0000_0011_0000_1111_0001";				-- b0		~ -0.061511769	

--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"10_00_1011_1011_0111_1011_1110_0101_0111";				-- a1		~ -1.816910185 	
--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_11_1000_0010_0000_0110_0001_1110_0010";				-- a2		~ +0.876976463

--	-- band pass  2nd order elliptical  fl= 7200Hz, fu = 7400Hz, Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
--	--------------------------------------------------------------------------
----	
----			           b0 + b1*Z^-1 + b2*Z^-2
----				H[z] = -------------------------
----						  1 + a1*Z^-1 + a2*Z^-2
----
--	--------------------------------------------------------------------------	
--
---- define biquad coefficients
--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_11_1111_1101_0010_0010_0011_1010_0101";				-- b0		~ +0.9944543
--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"10_11_0110_1000_0111_0101_1111_1101_1011";				-- b1		~ -1.1479874
--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"00_11_1111_1101_0010_0010_0011_1010_0101";				-- b2		~ +0.9944543

--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"10_11_0110_1000_0111_0101_1111_1101_1011";				-- a1		~ -1.1479874 	
--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_11_1111_0100_1010_0100_0111_0100_1011";				-- a2		~ +0.9889086


--	 stop band  2nd order butterworth  f0 = 3000Hz, fl = 2000Hz, fu = 4000Hz,  Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
--	--------------------------------------------------------------------------
----	
----			           b0 + b1*Z^-1 + b2*Z^-2
----				H[z] = -------------------------
----						  1 + a1*Z^-1 + a2*Z^-2
----
--	--------------------------------------------------------------------------	
--
---- define biquad coefficients
--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_11_1000_1000_1101_1111_0001_1100_0110";				-- b0		~ +0.8836636
--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"10_01_0110_1001_1001_0110_1000_0001_1011";				-- b1		~ -1.6468868
--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"00_11_1000_1000_1101_1111_0001_1100_0110";				-- b2		~ +0.8836636	

--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"10_01_0110_1001_1001_0110_1000_0001_1011";				-- a1		~ -1.6468868 	
--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_11_0001_0001_1011_1110_0011_1000_1011";				-- a2		~ +0.7673272


--	-- band pass  2nd order elliptical  fl= 2000Hz, fu = 2500Hz, Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
--	--------------------------------------------------------------------------
----	
----			           b0 + b1*Z^-1 + b2*Z^-2
----				H[z] = -------------------------
----						  1 + a1*Z^-1 + a2*Z^-2
----
--	--------------------------------------------------------------------------	
--
---- define biquad coefficients
--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_00_0100_1001_0001_0011_0101_0100_0111";				-- b0		~ +0.0713628
--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"00_00_0000_0000_0000_0000_0000_0000_0000";				-- b1		~ +0.0
--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"11_11_1011_0110_1110_1100_1010_1011_1000";				-- b2		~ -0.0713628

--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"10_00_1110_0011_0001_0001_1010_1011_1111";				-- a1		~ -1.7782529 	
--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_11_0110_1101_1101_1001_0101_0111_0001";				-- a2		~ +0.8572744


--   -- Used Bilinear Z Transform
--	-- low pass  2nd order butterworth  fc = 12000Hz, Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
--	--------------------------------------------------------------------------
----	
----			           b0 + b1*Z^-1 + b2*Z^-2
----				H[z] = -------------------------
----						  1 + a1*Z^-1 + a2*Z^-2
----
--	--------------------------------------------------------------------------	
--
---- define biquad coefficients
--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_01_0010_1011_1110_1100_0011_0011_0011";				-- b0		~ +0.292893219
--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"00_10_0101_0111_1101_1000_0110_0110_0110";				-- b1		~ +0.585786438
--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"00_01_0010_1011_1110_1100_0011_0011_0011";				-- b2		~ +0.292893219

--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"00_00_0000_0000_0000_0000_0000_0000_0000";				-- a1		~ 0.0 	
--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_00_0000_0000_0000_0101_0111_1101_1000";				-- a2		~ +0.171572875


--
--	-- stop band  2nd order butterworth  f0 = 3000Hz, fl = 2000Hz, fu = 4000Hz,  Fs = 48000Hz, PBR = .08 dB, SBR = .03 dB
--	--------------------------------------------------------------------------
----	
----			           b0 + b1*Z^-1 + b2*Z^-2
----				H[z] = -------------------------
----						  1 + a1*Z^-1 + a2*Z^-2
----
--	--------------------------------------------------------------------------	
--
---- define biquad coefficients
--	constant	Coef_b0	:	std_logic_vector(31 downto 0) := B"00_11_1000_1000_1101_1111_0001_1100_0110";				-- b0		~ +0.8836636
--	constant	Coef_b1	:	std_logic_vector(31 downto 0) := B"10_01_0110_1001_1001_0110_1000_0001_1011";				-- b1		~ -1.6468868
--	constant	Coef_b2	:	std_logic_vector(31 downto 0) := B"00_11_1000_1000_1101_1111_0001_1100_0110";				-- b2		~ +0.8836636	

--	constant	Coef_a1	:	std_logic_vector(31 downto 0) := B"10_01_0110_1001_1001_0110_1000_0001_1011";				-- a1		~ -1.6468868 	
--	constant	Coef_a2	:	std_logic_vector(31 downto 0) := B"00_11_0001_0001_1011_1110_0011_1000_1011";				-- a2		~ +0.7673272