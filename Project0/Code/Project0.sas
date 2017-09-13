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
datafile="/folders/myfolders/bios6623-delgoulding/Project0/raw data/Project0_dental_data (1).xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run; 
*-- data management DO NOT change treatment group order because don't know of any association--*;

*--descriptive statistics by treatment group--*;

*--	create formats for coding --*;
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
tables trtgroup*(sex race smoker) / chisq fishers ;
title 'Descriptive Statistics for Categorical Variables in Project 0';
format sex sex. race race. smoker smoke. trtgroup trtgroup.;
run;
proc means data=dentalv1 mean std nmiss;
var age sites; 
class trtgroup; /*block this for overall */
title 'Descriptive Statistics for Continuous Variables in Project 0';
format trtgroup trtgroup.;
run;
proc reg data=dentalv1;
model age=trtgroup; /*looking for pvalue for age and sites across treatment groups */
run;
*-- investigating any possible relationship by demographic variables--*;
proc sgplot data=dentalv1;
scatter x=pdbase y=race / group=trtgroup; /* x=attachbase x=pdbase y=race y=age y=sex y=smoke*/
format trtgroup trtgroup. race race.;
run;

*-- descriptive statistics for outcomes by trtgroup--*;
 
*--	assinging blank to period for numerical missing--*;
data dentalv2;
set  dentalv1;
if pdbase = ' ' then pdbase= .;
if attachbase = ' ' then attachbase = .;
run;
*--	examining violations of outcome variables--*;
proc univariate data=dentalv2 plots;
var attachbase	attach1year	pdbase	pd1year;
class trtgroup;
histogram attachbase attach1year pdbase	pd1year;
run;
*-- making new variables for change between base and one year --*;
data dentalv2;
set dentalv2;
attach_change = . ;
attach_change = attachbase-attach1year;
run;
data dentalv2;
set dentalv2;
pd_change = . ;
pd_change = pdbase-pd1year;
run;
proc sgplot data=dentalv2;
scatter x=pd_change y=age / group=trtgroup; /* x=attach_change x=pd_change y=age y=smoke y=race y=base*/
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


*-- looking at potential covariates in attachment difference --*;
proc reg data=dentalv3;
model attach_change= attachbase; /*significant, precision variable?*/
run;
proc reg data=dentalv3;
model attach_change=age; /*not significant*/
run;
proc reg data=dentalv3;
model attach_change=sex; /*p=0.0696, almost significant?*/
run;
proc reg data=dentalv3;
model attach_change=race; /*not significant*/
run;
proc reg data=dentalv3;
model attach_change=smoker; /*not significant*/
run;
proc reg data=dentalv3;
model attach_change=sites;
run;
*-- attachment crude model and unblock covariates that were considered significant for adjusted *--;
proc reg data=dentalv3; /*use contrast statement or manual f test */
model attach_change= placebo low medium high /*attachbase*/; /*unblock attachbase for adjusted model*/
test placebo,low,medium,high;
test placebo=low;
test placebo=medium;
test placebo=high;
test low=medium;
test low=high;
test medium=high;
run; 
*-- looking at potential covariates in pd difference --*;
proc reg data=dentalv3;
model pd_change= pdbase; /*significant, precision variable?*/
run;
proc reg data=dentalv3;
model pd_change=age; /*not significant*/
run;
proc reg data=dentalv3;
model pd_change=sex; /*p=0.0268, significant- precision variable? not related to exposure and not on casual pathway*/
run;
proc reg data=dentalv3;
model pd_change=race; /*not significant*/
run;
proc reg data=dentalv3;
model pd_change=smoker; /*not significant*/
run;
proc reg data=dentalv3;
model pd_change=sites; /*not significant*/
run;
*-- difference in pd outcome crude model, unblock for adjusted model --*;
proc reg data=dentalv3; /*use contrast statement */
model pd_change= control placebo low medium high /*pdbase*/ ; /*add sex to see difference between pdbase and sex for adjusted models*/
test placebo,low,medium,high;
test placebo=low;
test placebo=medium;
test placebo=high;
test low=medium;
test low=high;
test medium=high;
run; 


/*NOTE FOR FUTURE: proc glm automatically dummycodes variables with class statement? 
I am not sure my dummy coding worked with the proc reg so I am trying the GLM statement to see
if I got similar answers. I read in my biostats 6602 that you should leave out the variable you want to be
considered the reference (which is what I did above). I got this code from Andrea and I looked at
another couple githubs and they looked similar to this. I am confused how I would use it though and
it looks like a overall ANOVA of trtgroups rather than reporting differences between the groups. */
/*proc glm data=dentalv3;
class trtgroup / ref=first ;
model attach_change=trtgroup;
contrast trtgroup;
run; */