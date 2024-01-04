libname samp 'C:\Users\user\Desktop\GTL\';

/* normalize the data for one of the variables */
data threeaxes;
   set samp.threeaxes;
   var2 = var2 / 5;
run;

/* info on how to do this was taken from a blog written by Sanjay                     */
/* https://blogs.sas.com/content/graphicallyspeaking/2012/01/16/the-more-the-merrier/ */
/* code  modified with help from GTL training co-author Kriss Harris                  */
proc template;
   define statgraph gtl_3_Axis_sanjay_blog;
      begingraph;
         entrytitle '3 Axis Plot';

		 /* split graph area so you save a bit of room on the left (or right if you want on right) to draw extra axis */
         layout lattice / rows=1  
                          order=columnmajor 
                          columnweights=(0.12 0.88);
            /* layout 1 - to draw the extra axis on the left side - if want this on the right side */
			/* then need to move to after the layout with the series statements and switch order of*/
			/* the column weights in the lattice layout above                                      */
            layout overlay / walldisplay=none
                             xaxisopts=(display=none 
                                        linearopts=(tickvaluesequence=(start=0 
                                                                       end=30 
                                                                       increment=3)
                                                    tickvaluepriority=true))
                             yaxisopts=(linearopts=(tickvaluelist=(0 10 20 30 40 50 60)
                                                    tickdisplaylist=('0' '50' '100' '150' '200' '250' '300')
                                                    tickvaluepriority=true) 
                                        display=(tickvalues label)
                                        label='Var2');
               /* draw the third axis */
               seriesplot x=avisit y=var2 / lineattrs=(thickness=0);
            endlayout; /* end layout 1 */

			/* layout to draw each series line for all there types of data */
            layout overlay / xaxisopts=(linearopts=(tickvaluesequence=(start=0 end=30 increment=3)
                                                    tickvaluepriority=true)  griddisplay=on label='Visit')
                             yaxisopts=(linearopts=(tickvaluelist=(0 10 20 30 40 50 60)
                                                    tickdisplaylist=('0' '10' '20' '30' '40' '50' '60')
                                                    tickvaluepriority=true) 
                                        griddisplay=on 
                                        display=(ticks tickvalues label)
                                        label='Var1')
                             y2axisopts=(linearopts=(tickvaluesequence=(start=0 end=12 increment=2) 
                                                     tickvaluepriority=true) 
                                        display=(tickvalues ticks label) label='Var3');

               /* notice that VAR1 and VAR2 use left axis (y1) and VAR3 use right axis (y2) */
               seriesplot x=avisit y=var2 /  curvelabel='VAR2'  
                                             curvelabelattrs=graphdata2   
                                             lineattrs=graphdata2(pattern=solid);
               seriesplot x=avisit y=var1 /  curvelabel='VAR1'    
                                             curvelabelattrs=graphdata1   
                                             lineattrs=graphdata1(pattern=solid);
               seriesplot x=avisit y=var3 /  yaxis=y2 curvelabel='VAR3'    
                                             curvelabelattrs=graphdata3   
                                             lineattrs=graphdata3(pattern=solid);
            endlayout; /* end layout 2 */
         endlayout; /* end of lattice */
      endgraph;
   end;
run;

ods listing;

/*--Three Axis Plot--*/
proc sgrender data=threeaxes template=gtl_3_Axis_sanjay_blog;
run;
