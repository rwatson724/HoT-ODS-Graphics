/* formats to display time point */
proc format;
   picture dy2mo (round)
              0 = 'Baseline' (noedit)
	   1 - high = 09 (prefix = 'Month ' mult = 0.035714)
                ;

   picture dy2wk (round)
              0 = 'Baseline' (noedit)
	   1 - high = 09 (prefix = 'Wk ' mult = 0.142857)
                ;

   value meds
              1 = 'Glucose Supplement'
			  3 = 'Rapid-acting Insulin'
			  5 = 'Fast-acting Insulin'
			    ;
run;

/*************************************************************************/
/************ FORMAT THE DATA FOR PROCESSING TO PRODUCE GRAPH ************/
/*************************************************************************/
libname adam '/folders/myfolders/Diabetic_Profile_Ex4';
proc sort data = ADAM.ADLB
           out = adlb;
  by USUBJID ADY PARAMCD;
  where ANL01FL = 'Y';
run;

/* transpose lab data to get one record per timepoint */
proc transpose data = adlb
                out = tadlb (drop = _:);
  by USUBJID ADY ADT;
  var AVAL;
  id PARAMCD;
run;

/* stack all the data into one data set */
data all;
  set tadlb 
      ADAM.ADAE (drop = TRTSDT) 
      ADAM.ADCM (drop = CMTRT TRTSDT);

  strtday = coalesce(ADY, ASTDY);

  /* create barbed arrow for ongoing events */
  length aecap cmcap $15;
  if AEENRTPT = 'ONGOING' then aecap = 'FILLEDARROW';
  else aecap = 'NONE';

  /* create barbed arrow for ongoing events */
  if CMENRTPT = 'ONGOING' then cmcap = 'FILLEDARROW';
  else cmcap = 'NONE';
run;

/* need to sort in reverse order so that can find last study day for ongoing events */
proc sort data = all;
  by USUBJID descending strtday;
run;

/* need to determine the last study day for ongoing events */
data all2;
   set all;
   by USUBJID descending strtday;
   retain endday;
   if first.USUBJID then endday = .;

   /* set the end day based on if end day already exist or if ongoing use the previous record */
   /* to determine latest date and then add 20 days to indicate it still ongoing              */
   /* need to add the 20 days so the duration is longer than the length of the arrow otherwise*/
   /* the arrow will not show at the end of the duration that is marked as ongoing            */
   if ADY ne . then endday = ADY;
   else if (AEDECOD ne '' or ACAT ne '') and AENDY ne . then endday = AENDY;
   else if (AEDECOD ne '' and AEENRTPT = 'ONGOING') or (ACAT ne '' and CMENRTPT = 'ONGOING') then endday = endday + 20;

   /* create dummy variables so that these data will be placed on the y-axis in the correct spot */
   /* and can assign different symbols and colors as necessary                                   */
   if index(AEDECOD, 'Hypo') then dummy1 = 8;
   else if index(AEDECOD, 'Hyper') then dummy2 = 9;
   if index(ACAT, 'Supplement') then dummy3 = 1;
   else if index(ACAT, 'Rapid') then dummy3 = 3;
   else if index(ACAT, 'Fast') then dummy3 = 5;
run;
