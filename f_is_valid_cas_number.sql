CREATE OR REPLACE FUNCTION f_is_valid_cas_number(p_cas_number IN VARCHAR2)
  return NUMBER is

/*
 * Function to validate a CAS Registry Number / CAS Number / CASRN
 * 
 * CAS Number is a unique numerical identifier assigned by Chemical Abstracts
 * Service (CAS) to every chemical substance described in the open scientific
 * literature (currently including those described from at least 1957 through
 * the present), including organic and inorganic compounds, minerals,
 * isotopes, alloys and nonstructurable materials (UVCBs, of unknown, variable
 * composition, or biological origin).
 *
 * @author		Abhinav Sood
 * @author_url	http://www.abhinavsood.com/
 * @link		http://www.abhinavsood.com/cas-number-validation/
 * @version		1.0
**/

  -- Last digit of the CAS Number is the check digit
  check_digit NUMBER(1);

  -- Remove HYPHENs from CAS Number and compute checksum using all but the last digit
  checksum_source        NUMBER;
  checksum_source_length NUMBER;

  -- Computed checksum.
  -- Check Digit should be equal to this checksum for the CAS number to be valid
  checksum NUMBER := 0;

  -- Set to 1 if format of input CAS number is valid
  is_format_valid NUMBER(1) := 0;

  -- Set to 1 if format as well as checksum of input CAS Number is valid
  is_valid_cas NUMBER(1) := 0;
BEGIN
  SELECT REGEXP_INSTR(p_cas_number, '^\d{1,7}-\d{2}-\d$'),
         TRANSLATE(p_cas_number, 'a-', 'a'),
         LENGTH(TRANSLATE(p_cas_number, 'a-', 'a')) - 1,
         SUBSTR(p_cas_number, -1, 1)
    INTO is_format_valid,
         checksum_source,
         checksum_source_length,
         check_digit
    FROM dual;

  -- If format is valid then compute checksum and validate the check digit against it
  IF is_format_valid = 1 THEN
    FOR i IN 1 .. checksum_source_length LOOP
      checksum := checksum + (SUBSTR(checksum_source, i, 1) *
                  (checksum_source_length - i + 1));
    END LOOP;

    checksum := MOD(checksum, 10);

    -- CAS Number is valid only if checksum matches with the check digit
    IF checksum = check_digit THEN
      is_valid_cas := 1;
    END IF;
  END IF;

  RETURN(is_valid_cas);
EXCEPTION
  WHEN VALUE_ERROR THEN
    RETURN(is_valid_cas);
END f_is_valid_cas_number;
 	