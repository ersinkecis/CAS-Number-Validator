/****** Object:  StoredProcedure [dbo].[p_is_valid_cas_number]    Script Date: 15.10.2019 01:06:49 ******/
CREATE PROCEDURE [dbo].[p_is_valid_cas_number](@p_cas_number AS VARCHAR(50)) --'1234-56-7'
AS

/*
 * Procedure to validate a CAS Registry Number / CAS Number / CASRN
 * 
 * CAS Number is a unique numerical identifier assigned by Chemical Abstracts
 * Service (CAS) to every chemical substance described in the open scientific
 * literature (currently including those described from at least 1957 through
 * the present), including organic and inorganic compounds, minerals,
 * isotopes, alloys and nonstructurable materials (UVCBs, of unknown, variable
 * composition, or biological origin).
 *
 * @author1        Abhinav Sood (Oracle - PL/SQL version)
 * @author1_url    http://www.abhinavsood.com/
 * @ora_link       http://www.abhinavsood.com/cas-number-validation/
 *
 ****************************************************************************************
 *
 * @author2        Ersin Kecis (MSSQL Server - T/SQL version)
 * @author2_url    https://github.com/ersinkecis/
 * @sql_link       https://github.com/ersinkecis/CAS-Number-Validator
 *
 * @checksum       https://www.cas.org/support/documentation/chemical-substances/checkdig
 *                 http://www.caslab.com/Validate-CAS-Number/index.php
 *                 https://www.wikizeroo.org/wiki/en/CAS_Registry_Number
 *                 CAS number of water is 7732-18-5: the checksum 5 is calculated as 
 *                 (8×1 + 1×2 + 2×3 + 3×4 + 7×5 + 7×6) = 105 mod 10 = 5.
 *
 *                 CAS No: 1002-84-2  (Pentadecanoic Acid)
 *                 digits: 6543-21-X  (Check digit not used)
 *                 1 * 6 =  6
 *                 0 * 5 =  0
 *                 0 * 4 =  0
 *                 2 * 3 =  6
 *                 8 * 2 = 16
 *                 4 * 1 =  4
 *                 Checksum = (6 + 0 + 0 + 6 + 16 + 4) MOD 10 = (32 MOD 10) = 2
 *
 *                 A CAS Registry Number® includes up to 10 digits which are separated into 3 groups by hyphens. 
 *                 The first part of the number, starting from the left, has 2 to 7 digits; the second part has 2 digits. 
 *                 The final part consists of a single check digit. The format is 'xxxxxxx-yy-z' (look 1th checksum link)
 * @version        1.0 (t-sql)
**/

BEGIN
  -- Set to 1 if format as well as checksum of input CAS Number is valid
  DECLARE @is_format_valid NUMERIC(1) = 0;
  DECLARE @is_valid_cas NUMERIC(1) = 0;

  IF (@p_cas_number IS NOT NULL AND LEN(@p_cas_number) >= 6) --'1-23-4' <<--<< this is a smallest CAS number example. (max length=12 -> 1234567-89-0)
  BEGIN
    -- Last digit of the CAS Number is the check digit (checksum)
    DECLARE @check_digit NUMERIC;
    DECLARE @checksum_source_length NUMERIC;
    DECLARE @input_param_length NUMERIC;
    
    -- Remove HYPHENs from CAS Number and compute checksum using all but the last digit
    DECLARE @reversed_cas_number VARCHAR(50);
    SET @reversed_cas_number = REVERSE(@p_cas_number); --'7-65-4321' -> '7654321'
    SET @reversed_cas_number = REPLACE(@reversed_cas_number,'-',''); --'7-65-4321' -> '7654321'
    SET @reversed_cas_number = SUBSTRING(@reversed_cas_number, 2, LEN(@reversed_cas_number) - 1); --'654321'
    
    -- Set to 1 if format of input CAS number is valid
    --SET @is_format_valid = ISNUMERIC(REPLACE(@p_cas_number,'-',''));
    SET @is_format_valid = 1;
    SET @input_param_length = LEN(@p_cas_number);
    DECLARE @onechar VARCHAR(1);
    DECLARE @i int = 0
    WHILE @i < @input_param_length
    BEGIN
        SET @i = @i + 1
        SET @onechar = SUBSTRING(@p_cas_number, @i, 1);
        IF (CHARINDEX(@onechar, '1234567890-') = 0)
        BEGIN
          SET @is_format_valid = 0;
        END
    END

    IF (@is_format_valid = 1)
    BEGIN
      -- Computed checksum.
      -- Check Digit should be equal to this checksum for the CAS number to be valid
      SET @check_digit = CONVERT(NUMERIC, SUBSTRING(@p_cas_number, LEN(@p_cas_number), 1)); --'7'
    
      -- If format is valid then compute checksum and validate the check digit against it
      DECLARE @temp NUMERIC = 0;
      DECLARE @checksum NUMERIC = 0;
      DECLARE @checksum_source VARCHAR(50);
      SET @checksum_source = @reversed_cas_number;
      SET @checksum_source_length = LEN(@checksum_source);
      SET @checksum = 0;
      SET @i = 0;
      WHILE @i < @checksum_source_length
      BEGIN
          SET @i = @i + 1
          SET @temp = CONVERT(NUMERIC, SUBSTRING(@checksum_source, @i, 1))  * @i;
          SET @checksum = @checksum + @temp;
      END
      
      SET @temp = @checksum % 10;
      SET @checksum = @temp;
      
      -- CAS Number is valid only if checksum matches with the check digit
      IF (@checksum = @check_digit)
      BEGIN
          SET @is_valid_cas = 1;
      END
    END --IF (@is_format_valid = 1)
  END --IF (@p_cas_number IS NOT NULL AND LEN(@p_cas_number) >= 6)

  SELECT @is_valid_cas;
END --PROCEDURE
