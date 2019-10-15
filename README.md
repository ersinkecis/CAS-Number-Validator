# CAS-Number-Validator
Microsoft T-SQL procedure to validate CAS Registry Numbers

## What is a CAS Registry Number?
CAS Registry Numbers are universally used to provide a unique, unmistakable identifier for chemical substances. CAS Number is a unique numerical identifier assigned by Chemical Abstracts Service (CAS) to every chemical substance described in the open scientific literature (currently including those described from at least 1957 through the present), including organic and inorganic compounds, minerals, isotopes, alloys and nonstructurable materials (UVCBs, of unknown, variable composition, or biological origin).

A CAS Registry Number itself has no inherent chemical significance but provides an unambiguous way to identify a chemical substance or molecular structure when there are many possible systematic, generic, proprietary or trivial names.

## Usage
The procedure `p_is_valid_cas_number` takes a CAS Number as the only input parameter, of type `VARCHAR`, and returns 1 if the input is a valid CAS number and 0 if the input is not a valid CAS Number.

```sql
-- Valid CAS Number for Water, returns 1
EXEC p_is_valid_cas_number '7732-18-5';

-- Invalid syntax, returns 0
EXEC p_is_valid_cas_number '7A2-181-522';

-- Valid syntax but incorrect checksum, returns 0
EXEC p_is_valid_cas_number '1-11-5';
```

In MS T-SQL, the procedure can be used to set a flag as follows:
```sql
  -- Valid CAS Number for Water, sets is_valid_cas_number flag to 1
  EXEC p_is_valid_cas_number '7732-18-5';
```


### Useful Links
[CAS Registry Number](http://en.wikipedia.org/wiki/CAS_Registry_Number)

[Chemical Abstracts Service](http://www.cas.org/)

[Chemical Abstracts Service FAQs](http://www.cas.org/about-cas/faqs)

[How To Calculate Check Digit?](https://www.cas.org/support/documentation/chemical-substances/checkdig)



