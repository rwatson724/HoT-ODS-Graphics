/****************************************************************************************
*** Program:    exercise3c.sas
*** Output:     N/A
*** Purpose:    Produce Bar Chart with Table with LAYOUT GRIDDED (Inside) with GTL
*** Programmer: Richann Jean Watson
*** Date:       02MAY2024
****************************************************************************************/

/**** CHANGE PATH TO WHERE SETUP.SAS IS LOCATED ****/
%inc "C:\Users\gonza\OneDrive - datarichconsulting.com\Desktop\GitHub\HoT-ODS-Graphics\Dev\Example\setup.sas";

/*********************************************************************************************************************/
/*** BEGIN SECTION TO PRODUCE BASIC BAR CHART USING SGPLOT AND GTL WITH TITLE/FOOTNOTE INSIDE AND OUTSIDE OF GRAPH ***/
/*********************************************************************************************************************/
/* close the listing destination */
ods listing close;
ods escapechar='^';
options nodate nonumber nobyline orientation = landscape;

ods graphics / imagename = "&pgmname" height = 6in width = 9in outputfmt = png;
goptions device = png;
ods pdf notoc dpi = 300 file = "&outp.&pgmname..pdf";
ods rtf image_dpi = 300 file = "&outp.&pgmname..rtf";
title "Bar Chart by Treatment for Percent of Patients with Dermatologic Event - &pgmname";
footnote "GTL - Inset Table Component Using GRIDDED (Inside)";
proc template;
   define statgraph recrgrphd;

      /* indicate the macro variables that will be used to create the inset table */
      mvar valuechi054 pchi054 valuechi081 pchi081 cmstat cmpvalue;

      begingraph / border = false;

         entrytitle "Patients with Dermatologic Events";
         entryfootnote halign = left "Subjects only counted once in each treatment group.";

            /* portion to inset Toxicity table - to be placed in center    */
	         /* order = rowmajor indicates that the grid will be filled out */
	         /* in row order so each column in the row will be populated    */
			   /* prior to moving onto the next row                           */

   	      /* need to force the y-axis to display up through 100 in order for the table to be displayed */
            layout overlay / xaxisopts = (label = " "
                                          type = discrete)
                             yaxisopts = (label = "Percentage of Patients with Dermatologic Event (%)"
                                          linearopts = (tickvaluesequence = (start = 0
                                                                             end = 100
                                                                             increment = 25)
                                                        viewmax = 100));
   			   /* create the vertical bar charts for each treatment group */
               barchart x = TRTAN y = PCT_ROW / orient = vertical
                                                barlabel = true;

            /* portion to embed table – to be placed at the top            */
   	      /* order = rowmajor indicates that the grid will be filled out */
   	      /* in row order so each column in the row will be populated    */
   	      /* prior to moving onto the next row                           */
            layout gridded / columns = 4
			         order = rowmajor
                          autoalign = (top); 
                          entry "Pearson's Chi-square Test Results";
                          entry " ";
                          entry " ";
                          entry "Cochran-Armitage Trend Test Results";
                          entry "    Treatment Comparison";
                          entry "Value";
                          entry "P-value";
                          entry "    Value = " cmstat;
                          entry "    Placebo - Low Dose";
                          entry valuechi054;
                          entry pchi054;
                          entry "P-value = " cmpvalue;
                          entry "    Placebo - High Dose";
                          entry valuechi081;
                          entry pchi081;
            endlayout;

         endlayout;
      endgraph;
   end;
run;

proc sgrender data = OUTD.TRTPCT template = recrgrphd;
  format TRTAN trt. PCT_ROW pctfmt.; 
run;

ods rtf close;
ods pdf close;