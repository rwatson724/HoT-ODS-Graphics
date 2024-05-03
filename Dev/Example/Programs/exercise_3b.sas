/****************************************************************************************
*** Program:    exercise3b.sas
*** Output:     N/A
*** Purpose:    Produce Bar Chart with Table Using DRAWTEXT with GTL
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

ods graphics / imagename = "&pgmname" height = 6in width = 9in outputfmt = png noborder;
goptions device = png;
ods pdf notoc dpi = 300 file = "&outp.&pgmname..pdf" nogtitle nogfootnote;
ods rtf image_dpi = 300 file = "&outp.&pgmname..rtf" nogtitle nogfootnote;
title "Bar Chart by Treatment for Percent of Patients with Dermatologic Event - &pgmname";
footnote "GTL - Inset Table Component Using DRAWTEXT";

proc template;
   define statgraph recrgrphb;
      begingraph / border = false;

         entrytitle "Patients with Dermatologic Events";
         entryfootnote halign = left "Subjects only counted once in each treatment group.";

	      /* need to force the y-axis to display up through 100 in order for the table to be displayed */
         layout overlay / xaxisopts = (label = " "
                                       type = discrete)
                          yaxisopts = (label = "Percentage of Patients with Dermatologic Event (%)"
                                       linearopts = (tickvaluesequence = (start = 0 end = 100 increment = 25)
                                                                          viewmax = 100));

		   	/* create the vertical bar charts for each treatment group */
            barchart x = TRTAN y = PCT_ROW / orient = vertical
                                             barlabel = true;                                             

            /* drawtext statements */
            drawtext textattrs = (size = 8pt) "Pearson's Chi-square Test Results                                   Cochran-Armitage Trend Test Results"  
                       / x = 20 y = 99 width = 75 widthunit = percent xspace = wallpercent yspace = datavalue anchor = left;
                                                             
            drawtext textattrs = (size = 8pt) "    Treatment Comparison                    Value   P-Value                  Value = &cmstat"
                       / x = 20 y = 96 width = 75 widthunit = percent xspace = wallpercent yspace = datavalue anchor = left;
                                              
            drawtext textattrs = (size = 8pt) "      Placebo - Low Dose                     &valuechi054   &pchi054                    P-value = &cmpvalue" 
                       / x = 20 y = 93 width = 75 widthunit = percent xspace = wallpercent yspace = datavalue anchor = left;
                                              
            drawtext textattrs = (size = 8pt) "      Placebo - High Dose                    &valuechi081   &pchi081"
                       / x = 20 y = 90 width = 75 widthunit = percent xspace = wallpercent yspace = datavalue anchor = left;
         endlayout;
      endgraph;
   end;
run;

proc sgrender data = OUTD.TRTPCT template = recrgrphb;
  format TRTAN trt. PCT_ROW pctfmt.; 
run;

ods rtf close;
ods pdf close;