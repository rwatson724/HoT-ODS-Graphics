/****************************************************************************************
*** Program:    exercise1b.sas
*** Output:     N/A
*** Purpose:    Produce Basic Bar Chart with GTL
*** Programmer: Richann Jean Watson
*** Date:       02MAY2024
****************************************************************************************/

/**** CHANGE PATH TO WHERE SETUP.SAS IS LOCATED ****/
%inc "ENTER_PATHNAME_HERE\setup.sas";

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
   
            /***** ENTER PLOT STATEMENMT TO PRODUCE A VERTICAL BAR CHART *****/

         endlayout;
      endgraph;
   end;
run;

/***** ENTER DATA SET NAME AND TEMPLATE NAME TO RENDER THE GRAPH *****/
proc sgrender data =         template =       ;
  format TRTAN trt. PCT_ROW pctfmt.; 
run;

ods rtf close;
ods pdf close;