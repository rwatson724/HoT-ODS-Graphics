/****************************************************************************************
ADTTE - TIME TO DERMATOLOGIC EVENT
GRAPH - DETERMINE PERCENT WHO HAD AN EVENT BY TREATMENT
INSET A TABLE THAT SHOWS COMPARISON OF PLACEBO TO EACH DOSE LEVEL
****************************************************************************************/
libname adam 'C:\Users\gonza\OneDrive - datarichconsulting.com\Desktop\GitHub\HoT-GTL\Dev\SDTM_ADaM_Pilot_Project';
libname outd 'C:\Users\gonza\OneDrive - datarichconsulting.com\Desktop\GitHub\HoT-GTL\Dev\Example\Data';

%let fnmprt = 1b;
%let outdir = C:\Users\gonza\OneDrive - datarichconsulting.com\Desktop\GitHub\HoT-GTL\Dev\Example\Output\;

/* need to  make sure the ods listing destination is on so that the results from the SAS proc */
/* will go to the listing destination for future reference                                    */
ods listing;

proc format;
   value trt
       0 = 'Placebo'
      54 = 'Xanomeline Low Dose'
      81 = 'Xanomeline High Dose'
          ;

   picture pctfmt (round) 0-high='000%';
run;

/************************************************************************************/
/******** BEGIN SECTION TO OBTAIN COUNTS AND PERCENTS AND FORMAT ACCORDINGLY ********/
/************************************************************************************/
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

%macro gendsn;
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

   %statpval(i = 54)
   %statpval(i = 81)

   proc sort data = trtpct;
      by TRTAN;
   run;
%mend gendsn;

/* only run this if you have opened a fresh SAS session */
%gendsn

/*********************************************************************************************************************/
/*** BEGIN SECTION TO PRODUCE BASIC BAR CHART USING SGPLOT AND GTL WITH TITLE/FOOTNOTE INSIDE AND OUTSIDE OF GRAPH ***/
/*********************************************************************************************************************/
/* close the listing destination */
ods listing close;
ods escapechar='^';
options nodate nonumber nobyline orientation = landscape;


/*********** NEED TO UNDERSTAND WHAT IS MEANT BY ANCHOR AND THE VALUE OF X1 --- WHY 50 AND 20 *****************/
data insidetf;
   retain function 'text' drawspace 'graphpercent' width 100;
   length anchor $6 textstyleelement $17 label $51;
   input x1 y1 anchor $ textstyleelement $ label $ 32 - 82;
   cards;
50 99 top    GraphTitleText    Patients with Dermatologic Events                  
20  1  bottom GraphFootnoteText Subjects only counted once in each treatment group.
;
run;

ods graphics / imagename = "ex&fnmprt._barchart_sgplot" height = 6in width = 9in outputfmt = png noborder;
goptions device = png;
ods pdf notoc dpi = 300 file = "&outdir.ex&fnmprt._barchart_sgplot.pdf" nogtitle nogfootnote;
ods rtf image_dpi = 300 file = "&outdir.ex&fnmprt._barchart_sgplot.rtf" nogtitle nogfootnote;
title "Bar Chart by Treatment for Percent of Patients with Dermatologic Event - &fnmprt";
footnote "SGPLOT - Titles/Footnotes Inside and Outide Graph Area";
proc sgplot data = trtpct pad = (top = 5% bottom = 5%) sganno = insidetf;
   format TRTAN trt. pct_row pctfmt.; 
   xaxis type = discrete label = " ";
   yaxis type = linear label = "Percentage of Patients with Dermatologic Event (%)"
         values = (0 to 100 by 25);
   vbar TRTAN / response = pct_row
                datalabel = pct_row;
run;
ods rtf close;
ods pdf close;

ods graphics / imagename = "ex&fnmprt._barchart_gtl" height = 6in width = 9in outputfmt = png;
goptions device = png;
ods pdf notoc dpi = 300 file = "&outdir.ex&fnmprt._barchart_gtl.pdf";
ods rtf image_dpi = 300 file = "&outdir.ex&fnmprt._barchart_gtl.rtf";
title "Bar Chart by Treatment for Percent of Patients with Dermatologic Event - &fnmprt";
footnote "GTL - Titles/Footnotes Inside and Outide Graph Area";

proc template;
   define statgraph recrgrphb;
      begingraph / border = false;

         /*** MAKE THIS PART OF THE EXERCISE -- I.E., ADD TITLE/FOOTNOTE INSIDE OF GRAPH ***/
         entrytitle "Patients with Dermatologic Events";
         entryfootnote halign = left "Subjects only counted once in each treatment group.";

	      /* need to force the y-axis to display up through 100 in order for the table to be displayed */
         layout overlay / xaxisopts = (label = " "
                                       type = discrete)
                          yaxisopts = (label = "Percentage of Patients with Dermatologic Event (%)"
                                       linearopts = (tickvaluesequence = (start = 0 end = 100 increment = 25)
                                                                          viewmax = 100));

		   	/* create the vertical bar charts for each treatment group */
            barchart x = TRTAN y = pct_row / orient = vertical
                                             barlabel = true;

         endlayout;
      endgraph;
   end;
 run;

proc sgrender data = trtpct template = recrgrphb;
  format TRTAN trt. pct_row pctfmt.; 
run;

ods rtf close;
ods pdf close;