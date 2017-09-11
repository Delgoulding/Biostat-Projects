**********************************************************************************;
*	PROGRAM NAME: Project 0 BIOS6623 code										 *;
*	DATE CREATED: September 2017												 *;
*	LAST UPDATED: September 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Evaluate if treatment results in lower average 					 *;
*	pocket depth and attachment loss at one year	     						 *;
**********************************************************************************;


options nocenter nodate nonumber source2 mprint symbolgen;
ods escapechar='~';
%let bold_style=~S={font_size=14pt font_weight=bold}~; 

*--import dental data --* ;
proc import dbms=xls out=dentalv1                                                                                                       
datafile="/folders/myfolders/bios6623-delgoulding/Project0/raw data/Project0_dental_data (1).xls";                                                                                              
getnames=YES;                                                                                                                           
run; 
*-- data management 
	change control group (2) to reference group(0)
	change race to account for missing 3 and make white reference--*;

*--descriptive statistics by treatment group
	create formats for coding --*;
proc format;
value trtgroup
		2='Control'
		1='Placebo'
		3='low'
		4='Medium'
		5='High';                                                                                                                         
value sex                                                                                                                               
        1='M'                                                                                                                       
        2='F';
value race 
		1='Native American'
		2='African American'
		4='Asian'
		5='White';
value smoke                                                                                                                         
        0='No'                                                                                                                  
        1='Yes';
run;
*-- descriptive statistics for table 1--*;
proc freq data=dentalv1;
tables trtgroup*(sex race_new smoker) / chisq fishers ;
title 'Descriptive Statistics for Categorical Variables in Project 0';
format sex sex. race_new race. smoker smoke. trtgroup trtgroup.;
run;
proc means data=dentalv1 mean t PRT nmiss;
var age; 
class trtgroup; /*block this for overall age*/
title 'Descriptive Statistics for Continuous Variables in Project 0';
format trtgroup trtgroup.;
run;
proc sgplot data=dentalv1;
scatter x=attachbase y=age / group=trtgroup; /* x=attachbase x=pdbase*/
run;
*-- descriptive statistics for outcomes by trtgroup --*;
data dentalv2;
set  dentalv1;
if pdbase = ' ' then pdbase= .;
if attachbase = ' ' then attachbase = .;
run;

proc univariate data=dentalv2 plots;
var attachbase	attach1year	pdbase	pd1year;
class trtgroup;
histogram attachbase attach1year pdbase	pd1year;
run;
*-- making new variables for difference between base and one year --*;
data dentalv2;
set dentalv2;
attach_dif = . ;
attach_dif = attachbase-attach1year;
run;
data dentalv2;
set dentalv2;
pd_dif = . ;
pd_dif = pdbase-pd1year;
run;
proc sgplot data=dentalv2;
scatter x=pd_dif y=age / group=trtgroup; /* x=attachbase x=pdbase*/
run;
*-- linear regression --*;
*-- dummy coding trtment groups--*;
data dentalv3;
set dentalv2;
array t{*} placebo control low medium high ; 
do i = 1 to 5;
     t(i) = (trtgroup=i);
end;
drop i;
run;

*-- linear regression per treatment group and outcome --*;
proc reg data=dentalv3;
model attach_dif= attachbase;
run;
proc reg data=dentalv3;
model attach_dif=age;
run;
proc reg data=dentalv3; /*contrast statement or manual f test */
model attach_dif= placebo low medium high /*attachbase*/; /*adding attachbase in outcome may make this Y2? not completely sure*/
test placebo,low,medium,high;
test placebo=low;
test placebo=medium;
test placebo=high;
test low=medium;
test low=high;
test medium=high;
run; 

proc reg data=dentalv3; /*contrast statement or manual f test */
model pd_dif= placebo low medium high;
test placebo,low,medium,high;
test placebo=low;
test placebo=medium;
test placebo=high;
test low=medium;
test low=high;
test medium=high;
run; 
