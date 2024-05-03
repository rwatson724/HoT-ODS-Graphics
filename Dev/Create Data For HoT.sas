/****************************************************************************************
ADTTE - TIME TO DERMATOLOGIC EVENT
GRAPH - DETERMINE PERCENT WHO HAD AN EVENT BY TREATMENT
INSET A TABLE THAT SHOWS COMPARISON OF PLACEBO TO EACH DOSE LEVEL
****************************************************************************************/

%let path = C:\Users\gonza\OneDrive - datarichconsulting.com\Desktop\GitHub\HoT-ODS-Graphics\Dev;

libname adam "&path.\SDTM_ADaM_Pilot_Project";
libname outd "&path.\Example\Data";

/* need to  make sure the ods listing destination is on so that the results from the SAS proc */
/* will go to the listing destination for future reference                                    */
ods listing;

/************************************************************************************/
/******** BEGIN SECTION TO OBTAIN COUNTS AND PERCENTS AND FORMAT ACCORDINGLY ********/
/************************************************************************************/
/* subset the source data set */
proc sort data = ADAM.ADTTE
           out = adtte;
  where SAFFL = 'Y' and PARAMCD = 'TTDE';
  by TRTAN;
run;

/* obtain the percents for each success for each treatment */
proc freq data = adtte order = data;
  tables TRTAN * CNSR / out = trtpct (where = (CNSR = 0) keep = TRTAN CNSR PCT_ROW) outpct;

  tables TRTAN * CNSR / trend;
  output out = OUTD.FREQTREND (keep = _TREND_ PR_TREND) trend;
run;

/* macro to obtain the p-values for comparison */
%macro statpval(i=);
  /* loop through all doses to get Fisher's exact p-value */
    %global valuechi0&i pchi0&i;
    /* obtain the Pearson's Chi-square p-value */
    proc freq data = adtte;
      tables TRTAN * CNSR / chisq;
      output out = OUTD.FREQCHISQ&i (keep = _PCHI_ P_PCHI) chisq;
	   where TRTAN in (0 &i);
    run;
%mend statpval;
%statpval(i = 54)
%statpval(i = 81)

proc sort data = OUTD.TRTPCT;
   by TRTAN;
run;