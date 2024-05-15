/****************************************************************************************
*** Program:    exercise1b.sas
*** Output:     N/A
*** Purpose:    Produce Basic Bar Chart with GTL
*** Programmer: Richann Jean Watson
*** Date:       02MAY2024
****************************************************************************************/

/**** CHANGE PATH TO WHERE SETUP.SAS IS LOCATED ****/
%inc "C:\Users\gonza\OneDrive - datarichconsulting.com\Desktop\GitHub\HoT-ODS-Graphics\Solutions\setup.sas";

/**********************************************************************************************************/
/*** BEGIN SECTION TO PRODUCE BASIC BAR CHART USING SGPLOT AND GTL WITH TITLE/FOOTNOTE OUTSIDE OF GRAPH ***/
/**********************************************************************************************************/
/* close the listing destination */
ods listing close;
ods escapechar='^';
options nodate nonumber nobyline orientation = landscape;

ods graphics / imagename = "&pgmname" height = 6in width = 9in outputfmt = png noborder;
goptions device = png;
ods pdf notoc dpi = 300 file = "&outp.&pgmname..pdf" nogtitle nogfootnote;
ods rtf image_dpi = 300 file = "&outp.&pgmname..rtf" nogtitle nogfootnote;
title "Bar Chart by Treatment for Percent of Patients with Dermatologic Event - &pgmname";
footnote "GTL - Bar Chart Component Only";

proc template;
   define statgraph recrgrphb;
      begingraph / border = false;

	      /* need to force the y-axis to display up through 100 in order for the table to be displayed */
         layout overlay / xaxisopts = (label = " "
                                       type = discrete)
                          yaxisopts = (label = "Percentage of Patients with Dermatologic Event (%)"
                                       linearopts = (tickvaluesequence = (start = 0 end = 100 increment = 25)
                                                                          viewmax = 100));

		   	/* create the vertical bar charts for each treatment group */
            barchart x = TRTAN y = PCT_ROW / orient = vertical
                                             barlabel = true;

         endlayout;
      endgraph;
   end;
run;

proc sgrender data = OUTD.TRTPCT template = recrgrphb;
  format TRTAN trt. PCT_ROW pctfmt.; 
run;

ods rtf close;
ods pdf close;