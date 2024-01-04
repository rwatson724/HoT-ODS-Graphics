/****************************************************************************************
ADTTE - TIME TO DERMATOLOGIC EVENT
GRAPH - DETERMINE PERCENT WHO HAD AN EVENT BY TREATMENT
INSET A TABLE THAT SHOWS COMPARISON OF PLACEBO TO EACH DOSE LEVEL
****************************************************************************************/
libname adam 'C:\Users\gonza\OneDrive - datarichconsulting.com\Desktop\GitHub\HoT-GTL\Dev\SDTM_ADaM_Pilot_Project';
libname outd 'C:\Users\gonza\OneDrive - datarichconsulting.com\Desktop\Conferences\Drafts\GTL HoT\Dev\Example 1\Data';

/* need to  make sure the ods listing destination is on so that the results from the SAS proc */
/* will go to the listing destination for future reference                                    */
ods listing;

proc format;
   value trt
       0 = 'Placebo'
      54 = 'Xanomeline Low Dose'
      81 = 'Xanomeline High Dose'
          ;
run;

/************************************************************************************/
/******** BEGIN SECTION TO OBTAIN COUNTS AND PERCENTS AND FORMAT ACCORDINGLY ********/
/************************************************************************************/

/* subset the source data set */
proc sort data=adam.adtte
           out=adtte;
  where SAFFL = 'Y' and PARAMCD = 'TTDE';
  by TRTAN;
run;

/* obtain the percents for each success for each treatment */
proc freq data = adtte order=data;
  tables TRTAN * CNSR / out = pct (where=(CNSR = 0) keep=TRTAN CNSR PCT_ROW) outpct;

  tables TRTAN * CNSR / trend;
  output out = freqtrend (keep = _TREND_ PR_TREND) trend;
run;

/* create a macro variable of the test statistic and the p-value */
data _null_;
  set freqtrend;
  call symputx ("cmstat", round(_TREND_, .01));

  if PR_TREND < 0.001 then pr_trendc = '<0.001';
  else pr_trendc = put(round(PR_TREND, 0.001), 6.3);
  call symputx ("cmpvalue", pr_trendc);
run;

/* macro to obtain the p-values for comparison */
%macro statpval(i=);
  /* loop through all doses to get Fisher's exact p-value */
    %global valuechi0&i pchi0&i;
    /* obtain the Pearson's Chi-square p-value */
    proc freq data = adtte;
      tables TRTAN * CNSR / chisq;
      output out = freqchisq&i (keep = _PCHI_ P_PCHI) chisq;
	  where TRTAN in (0 &i);
    run;

	/* create a macro variable of the test statistic and the p-value */
	data _null_;
	  set freqchisq&i;
	  call symputx ("valuechi0&i", round(_PCHI_, .01));

	  if P_PCHI < 0.001 then p_chic = '<0.001';
	  else p_chic = put(round(P_PCHI, 0.001), 6.3);
	  call symputx ("pchi0&i", p_chic);
	run;
%mend statpval;
%statpval(i=54)
%statpval(i=81)

/* create format for display purposes */
proc format;
   picture pctfmt (round) 0-high='000%';
run;

proc sort data = pct
          out = OUTD.TRTPCT;
   by TRTAN;
run;