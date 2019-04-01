/* Generated Code (IMPORT) */
/* Source File: Project 03_Attrition Analysis_Datasets.xlsx */
/* Source Path: /folders/myfolders/DataSets_072018 */
/* Code generated on: 8/16/18, 9:56 PM */
/*1.Import the required dataset*/
%web_drop_table(WORK.Attrition_Analysis);


FILENAME REFFILE '/folders/myfolders/DataSets_072018/Project 03_Attrition Analysis_Datasets.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.Attrition_Analysis;
	GETNAMES=YES;
RUN;

/*PROC CONTENTS DATA=WORK.Attrition_Analysis; RUN;*/
/*To drop varibales which are not required*/
DATA Attrition_Analysis;
SET Attrition_Analysis(drop=F G H I J K L);
RUN;

/*2.Check the frequency of churn */
/*28 people left*/
proc freq data = Attrition_Analysis;
tables Retain_indicator;
run;

/*3.Perform descriptive statistics for the dataset*/
/*Then copy the table to excel and calculate percentage or you can do it in SAS as well*/
proc freq data = Attrition_Analysis;
tables Sex_indicator*Retain_indicator/ nocol norow nopercent nocum;
run;

proc freq data = Attrition_Analysis;
tables Relocation_indicator*Retain_indicator/ nocol norow nopercent nocum;;
run;
/**/
proc freq data = Attrition_Analysis;
tables Marital_status*Retain_indicator/ nocol norow nopercent nocum;;
run;

/*4.Perform logistic regression*/

/*--------------------------------------------------------*/
%web_drop_table(WORK.Attrition_Analysis1);


FILENAME REFFILE '/folders/myfolders/DataSets_072018/Attrition Analysis_Dataset _ articulate.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.Attrition_Analysis1;
	GETNAMES=YES;
RUN;
data Attrition_Analysis1;
set Attrition_Analysis1;
if Retain_Indicator = 'Retained' then Retained_Num = 0;
else if Retain_Indicator = 'Left' then Retained_Num = 1;
run;
/*predicting atritride(who left the company) so event eqaul to 1*/
proc logistic data = Attrition_Analysis1;
class Sex_indicator Relocation_indicator Marital_status;
model Retained_Num (event="1") = Sex_indicator Relocation_indicator Marital_status/link=logit;
run;

/*Sex_Indicator probability value is more then 63 percent so droping this variable
and running model again*/
proc logistic data = Attrition_Analysis1;
class Relocation_indicator Marital_status;
model Retained_Num (event="1") = Relocation_indicator Marital_status/link=logit;
run;
/*Relocation_indicator probability value is 28% so droping this variable
and run model again with Marital_status*/
proc logistic data = Attrition_Analysis1;
class  Marital_status;
model Retained_Num (event="1") = Marital_status/link=logit;
run;

/*5. Check Max and Min values for the probability of churn*/
proc logistic data = Attrition_Analysis1;
class  Marital_status;
model Retained_Num (event="1") = Marital_status/link=logit;
output out = Attr_predictedValues p = _predicted;
run;
/*Max value for the probability of churn*/
proc sql;
select max(_predicted) from Attr_predictedValues
quit;
/*Min value for the probability of churn*/
proc sql;
select min(_predicted) from Attr_predictedValues
quit;

/*6.Create new dataset to add all “churned” employees above the cut-off value */
/*create new column with  Final_predictedValue with cut off 50% */
data Attr_predictedValues;
set Attr_predictedValues;
if _predicted > 0.5 then Final_predictedValue = 1;
else if _predicted < 0.5 then Final_predictedValue = 0;
run;
/*Filter all “churned”(left) employees above the cut-off value 50% */
data Attr_predictedValues1;
set Attr_predictedValues;
where Final_predictedValue = 1;


