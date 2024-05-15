/****************************************************************************************
*** Program:    exercise1a.sas
*** Output:     N/A
*** Purpose:    Produce Basic Bar Chart with SGPLOT
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
footnote "SGPLOT - Bar Chart Component Only";

proc sgplot data = OUTD.TRTPCT;
   format TRTAN trt. PCT_ROW pctfmt.; 
   xaxis type = discrete label = " ";
   yaxis type = linear label = "Percentage of Patients with Dermatologic Event (%)"
         values = (0 to 100 by 25);
   vbar TRTAN / response = PCT_ROW
                datalabel = PCT_ROW;
run;
ods rtf close;
ods pdf close;