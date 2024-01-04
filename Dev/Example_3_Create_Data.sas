/****************************************************************************************
ADQSNPPIX - BOXPLOT OF AESI AND MEAN N-PIX BY QUARTILE
GRAPH - BOXPLOT OF MEAN N-PIX BY QUARTILE OVERLAID WITH SCATTERPLOT OF AESI WITHIN EACH QUARTILE
WITH TABLE OF MEAN #AESI AND MIN AND MAX COUNT BY QUARTILE
****************************************************************************************/
libname adam '/folders/myfolders/SDTM_ADaM_Pilot_Project_Ex1_3';

/* need to  make sure the ods listing destination is on so that the results from the SAS proc */
/* will go to the listing destination for future reference                                    */
ods listing;

/************************************************************************************/
/******** BEGIN SECTION TO OBTAIN COUNTS AND PERCENTS AND FORMAT ACCORDINGLY ********/
/************************************************************************************/
/* retrieve HbA1c and Glucose (mg/dL) results that are post-baseline */
proc sort data = ADAM.ADLBGLUC
           out = gluc (keep = USUBJID PARAMCD CHG AVISIT:);
   by USUBJID PARAMCD AVISITN;
   where PARAMCD in ('HBA1C' 'GLUCCN') and AVISITN > 0;
run;

/* keep last post-baseline */
data gluc2;
   set gluc;
   by USUBJID PARAMCD;
   retain hba1c gluccn;
   if first.USUBJID then do;
      hba1c = .;
	  gluccn = .;
   end;
   if last.PARAMCD then do;
      if PARAMCD = 'HBA1C' then hba1c = CHG;
	  else if PARAMCD = 'GLUCCN' then gluccn = CHG;
   end;
   if last.USUBJID;
   keep USUBJID hba1c gluccn;
run;

/* determine quartiles for HbA1c */
proc means data = gluc2 noprint;
  var hba1c;
  output out = summstat n=n q1=q1 median=q2 q3=q3 max=q4 min=min;
run;

/* combine the quartiles with data */
proc sql noprint;
   create table gluc3 as
   select a.*, b.*
   from gluc2 a, summstat b;
quit;

/* for each record determine which quartile the HbA1c result falls in */
data gluc4;
  set gluc3;

  if . < hba1c <= q1 then qrtl = 1;
  else if q1 < hba1c <= q2 then qrtl = 2;
  else if q2 < hba1c <= q3 then qrtl = 3;
  else if q3 < hba1c then qrtl = 4;

  keep USUBJID hba1c gluccn qrtl;
run;

proc sort data = gluc4;
  by qrtl;
run;

/* determine the number of subjects with Glucose and mean value within each HbA1c quartile */
proc means data = gluc4 noprint;
  by qrtl;
  output out = gluc_mmm (drop = _:) n(gluccn) = qrt_n
                                    mean(gluccn) = qrt_mean
                                    min(gluccn) = qrt_min
								    max(gluccn) = qrt_max;
run;

/* create a quartile record that captures range of each quartile */
data qrtl (keep = qrtl q_range);
   set summstat;
   array qt(5) min q1 q2 q3 q4;
   do qrtl = 1 to 4;
      q_range = cat("(", strip(put(round(qt(qrtl), .1), 8.1)), "-", strip(put(round(qt(qrtl+1), .1), 8.1)), ")");
	  if qrtl > 1 then q_range = tranwrd(q_range, '(', '(>');
	  output;
   end;
run;

/* combine the glucose by quartiles with the quartile range and hba1c by quartile */
data all;
   merge gluc4 gluc_mmm qrtl;
   by qrtl;
run;