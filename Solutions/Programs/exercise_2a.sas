/****************************************************************************************
*** Program:    exercise2a.sas
*** Output:     N/A
*** Purpose:    Produce Bar Chart with Titles/Footnotes Inside/Outside Graph Area with SGPLOT
*** Programmer: Richann Jean Watson
*** Date:       02MAY2024
****************************************************************************************/

/**** CHANGE PATH TO WHERE SETUP.SAS IS LOCATED ****/
%inc "ENTER_PATHNAME_HERE\setup.sas";

/*********************************************************************************************************************/
/*** BEGIN SECTION TO PRODUCE BASIC BAR CHART USING SGPLOT AND GTL WITH TITLE/FOOTNOTE INSIDE AND OUTSIDE OF GRAPH ***/
/*********************************************************************************************************************/
/* close the listing destination */
ods listing close;
ods escapechar='^';
options nodate nonumber nobyline orientation = landscape;

data insidetf;
   retain function 'text' drawspace 'graphpercent' width 100;
   length anchor $6 textstyleelement $17 label $51;
   input x1 y1 anchor $ textstyleelement $ label $ 32 - 82;
   cards4;
50 99 top    GraphTitleText    Patients with Dermatologic Events                  ;
20  1 bottom GraphFootnoteText Subjects only counted once in each treatment group.
;;;;
run;

ods graphics / imagename = "&pgmname" height = 6in width = 9in outputfmt = png noborder;
goptions device = png;
ods pdf notoc dpi = 300 file = "&outp.&pgmname..pdf" nogtitle nogfootnote;
ods rtf image_dpi = 300 file = "&outp.&pgmname..rtf" nogtitle nogfootnote;
title "Bar Chart by Treatment for Percent of Patients with Dermatologic Event - &pgmname";
footnote "SGPLOT - Titles/Footnotes Inside and Outide Graph Area";

proc sgplot data = OUTD.TRTPCT pad = (top = 5% bottom = 5%) sganno = insidetf;
   format TRTAN trt. PCT_ROW pctfmt.; 
   xaxis type = discrete label = " ";
   yaxis type = linear label = "Percentage of Patients with Dermatologic Event (%)"
         values = (0 to 100 by 25);
   vbar TRTAN / response = PCT_ROW
                datalabel = PCT_ROW;
run;
ods rtf close;
ods pdf close;