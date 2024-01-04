
/* subset for glucose - remove end of treatment record */
proc sort data = ADAM.ADLBC
           out = adlbc (keep = USUBJID PARAM: AVAL AVISITN ADT ABLFL TRTA ADY BASE CHG);
    where PARAMCD = 'GLUC' and AVAL ne . and AVISITN ne 99;
    by USUBJID AVISITN;
run;

/* create new records for Glucose in mg/dL */
/* create a new record for HbA1c           */
data gluc;
   set adlbc;
   by USUBJID AVISITN;

   /* keep all the glucose records */
   output;
   
   /* convert to  mg/dL */
   PARAMCD = 'GLUCCN';
   PARAM = 'Glucose (mg/dL)';
   AVAL = AVAL * 18.1;
   if BASE ne . then BASE = BASE * 18.1;
   if BASE ne . then CHG = AVAL - BASE;
   output;
run;

/* SAS macro that duplicates the Excel RANDBETWEEN function */
%macro randbetween(min, max);
   (&min + floor((1+&max-&min)*rand("uniform")))
%mend;

/* for each subject that has Baseline, Week 12 and Week 24/26 create dummy HbA1c values */
data hba1c;
  set gluc;
  where PARAMCD = 'GLUCCN' and AVISITN in (0 12 24);
  PARAMCD = 'HBA1C';
  PARAM = 'HbA1c (%)';
  AVAL = %randbetween(4, 7) + ranuni(1246);

  drop BASE CHG;
run;

/* create the baseline and determine change from baseline */
data hba1c2;
   merge hba1c
         hba1c (keep = USUBJID AVISITN AVAL
		        where = (origvis = 0)
				rename = (AVISITN = origvis AVAL = BASE));
   by USUBJID;

   if AVISITN ne 0 and BASE ne . and AVAL ne . then CHG = AVAL - BASE;
run;

data ADAM.ADLBGLUC;
  set gluc hba1c2;
run;

proc sort data=ADAM.ADLBGLUC;
  by USUBJID PARAMCD AVISITN;
run;