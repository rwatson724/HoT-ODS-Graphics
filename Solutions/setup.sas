/****************************************************************************************
*** Program:    setup.sas
*** Output:     N/A
*** Purpose:    Initialize the setup of libnames, output paths, macro variables and formats
*** Programmer: Richann Jean Watson
*** Date:       02MAY2024
*** Acknowledgment: Thanks to Bartosz Jablonski for the suggestions for improvement for determining mode.
****************************************************************************************/
%macro path;
   /* identify the location where the program that is currently being executed is saved */
   data _null_;
      length pgmpath $9000 pgmname fldtype $200 root $400;
      /* based on the platform SAS is executed determines which system macro variables are used */

      mode = upcase(symget("sysprocessmode"));
      /* interactive SAS */
      if  mode = "SAS DMS SESSION" then pgmpath = sysget("SAS_EXECFILEPATH");
      /* SAS EG */
      else if  mode = "SAS WORKSPACE SERVER" then pgmpath = symget('_SASPROGRAMFILE');
      /* batch */
      else if  mode = "SAS BATCH MODE" then pgmpath = getoption('sysin');

      /* remove the quotes from around the program path name */
      pgmpath = strip(dequote(pgmpath));

      /* retrieve the program name without the '.sas' extension, deliverable name, production/validation, task (e.g., SDTM, ADaM, IAD, Tables, etc.) */
      pgmname = strip(scan(pgmpath, -2, '\/.'));
      fldtype = strip(scan(pgmpath, -2, '\/'));

      /* 20210413 - rwatson - new path name and description */
      pgmroot = substr(pgmpath, 1, find(pgmpath, fldtype, 't') + length(fldtype) - 1);
      root = substr(pgmpath, 1, find(pgmpath, fldtype, 't') - 1);

      /* create global macro variables to be used for defining libnames */
      call symputx('pgmname', pgmname, 'G');
      call symputx('fldtype', fldtype, 'G');
      call symputx('root',    root,    'G');
      call symputx('pgmroot', pgmroot, 'G');
      call symputx('pgmpath', pgmpath, 'G');
   run;
%mend path;

%path

libname outd "&root.Data";
%let outp = &root.Output/;

ods path work.TEMPLAT (update) SASUSER.TEMPLAT (read) SASHELP.TMPLMST (read);

/* need to  make sure the ods listing destination is on so that the results from the SAS proc */
/* will go to the listing destination for future reference                                    */
ods listing;

proc format;
   value trt
       0 = 'Placebo'
      54 = 'Xanomeline Low Dose'
      81 = 'Xanomeline High Dose'
          ;

   picture pctfmt (round) 0-high = '000%';
run;

/* create a macro variable of the test statistic and the p-value */
data _null_;
  set OUTD.FREQTREND;
  call symputx ("cmstat", round(_TREND_, .01));

  if PR_TREND < 0.001 then pr_trendc = '<0.001';
  else pr_trendc = put(round(PR_TREND, 0.001), 6.3);
  call symputx ("cmpvalue", pr_trendc, 'G');
run;

/* macro to obtain the p-values for comparison */
%macro statpval(i=);
  /* loop through all doses to get Fisher's exact p-value */
    %global valuechi0&i pchi0&i;
	/* create a macro variable of the test statistic and the p-value */
	data _null_;
	  set OUTD.FREQCHISQ&i;
	  call symputx ("valuechi0&i", round(_PCHI_, .01));

	  if P_PCHI < 0.001 then p_chic = '<0.001';
	  else p_chic = put(round(P_PCHI, 0.001), 6.3);
	  call symputx ("pchi0&i", p_chic, 'G');
	run;
%mend statpval;
%statpval(i = 54)
%statpval(i = 81)