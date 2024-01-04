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

/* subset the source data set */
proc sort data=adam.adqsnpix
           out=adqsnpix (keep = USUBJID TRTP AVAL PARAMCD);
  where PARAMCD = 'NPTOTMN' and ABLFL ne 'Y' and ANL01FL = 'Y' and AVAL ne .;
  by PARAMCD;
run;

/* determine summary stats */
proc means data = adqsnpix noprint;
  by PARAMCD;
  var AVAL;
  output out = summstat n=n q1=q1 median=q2 q3=q3 max=q4 min=min;
run;

/* combine the quartiles with data */
data adqs2;
  merge adqsnpix summstat;
  by PARAMCD;

  if . < AVAL <= q1 then qrtl = 1;
  else if q1 < AVAL <= q2 then qrtl = 2;
  else if q2 < AVAL <= q3 then qrtl = 3;
  else if q3 < AVAL then qrtl = 4;
run;

proc sort data = adqs2;
  by PARAMCD qrtl;
run;

/* determine the min and max within each quartile */
proc means data = adqs2 noprint;
  by PARAMCD qrtl;
  output out = minmax (drop = _:) n(AVAL) = qrt_n
                                  mean(AVAL) = qrt_mean
                                  min(AVAL) = qrt_min
								  max(AVAL) = qrt_max;
run;

/* merge the summary stats per quartile back to subject level data */
data newadqs;
  merge adqs2 minmax;
  by PARAMCD qrtl;
  drop q1 q2 q3 q4 min _:;
run;

/* retrieve the AEs */
proc sort data = ADAM.ADAE
           out = adae (keep = USUBJID TRTA AEDECOD);
  by USUBJID;
  where AEDECOD ? 'SKIN' or AEDECOD ? 'RASH';
run;

/* determine number of AEs per subject */
proc freq data = adae noprint;
  tables USUBJID / out = aecntpersubj (drop = PERCENT rename = (COUNT = aesi_cnt));
run;

proc sort data = newadqs;
  by USUBJID;
run;

/* combine the AE count and the Mean NPIX info into one data set   */
/* keep only subjects that had Mean NPIX - default missing AE to 0 */
data all;
  merge newadqs aecntpersubj;
  by USUBJID;
  if aesi_cnt = . then aesi_cnt = 0;
  if AVAL ne .;
run;

proc sort data = all;
  by qrtl;
run;

/* determine number of mean AESI per quartile */
proc means data = all noprint;
  by qrtl;
  output out = ccm_aesi mean(aesi_cnt) = mean_aesi;
run;

/* merge mean AESI with rest of data and format */
data all2;
  merge all ccm_aesi;
  by qrtl;

  qrt_cnt = cat("Q", strip(put(qrtl, 1.)), " (n=", strip(put(qrt_n, best.)), ")");

  aesi_mean_qrtl = round(mean_aesi, .1);
  
  label qrtl = 'Mean N-Pix by Quartile'
        aesi = 'Number of Skin Related AEs';
run;

proc sort data =  all2;
  by PARAMCD;
run;

/* determine max number of AEs */
proc sql noprint;
  select max(aesi_cnt) into :maxaecnt
  from all2;
quit;