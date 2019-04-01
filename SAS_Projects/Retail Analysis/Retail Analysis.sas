/*1. To import Retail Analysis_Dataset.xlsx*/
FILENAME REFFILE '/folders/myfolders/DataSets_072018/Project 04_Retail Analysis_Dataset.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.RETAIL;
	GETNAMES=YES;
RUN;
/*2. descriptive statistics for the dataset*/ 
/* Step 1: Create a new variable Total_Sales(sales*quantity) as sales variable value is just per unit price */
data Retail;
set Retail;
Total_Sales = sales*quantity;
run;
/*Step 2: Find mean,mode,medain,standard deviation,min and max for each product*/
proc means data = work.retail mean mode Median std min max;
class products;
var Total_Sales Quantity Discount Profit shipping_cost ;
output out =DecriptiveRetailOutput;
run;
/*Step 3:Verify normal distribution*/
proc univariate data = work.retail normal plot;
var Total_Sales Quantity Discount Profit;
run;

/*3. significance of independent variables */

/* Step 1: Create a new variable Total_Sales(sales*quantity) as sales variable value is just per unit price */
data Retail;
set Retail;
Total_Sales = sales*quantity;
run;

/* Step 2: Now predict total_sales and not sales */
PROC REG DATA=Retail;
MODEL Total_Sales= Quantity Discount Profit Shipping_Cost;
run;

/* Step 3: As per result output: Since shipping cost is straight away 10% of profit across all 
observations this variable (Shipping_cost) should be dropped */
PROC REG DATA=Retail;
MODEL Total_Sales= Quantity Discount Profit ;
run;

/* Step 4: Discount is insignificant in the results. Drop discount  */
/* As per below model quantity and profit as significant variables */
PROC REG DATA=Retail;
MODEL Total_Sales= Quantity Profit ;
run;

/* Below model is final model with Adj Rsquare as .88 ,which is 88% accuracy*/
PROC REG DATA=Retail;
MODEL Total_Sales= Quantity Profit ;
run;

/* See the prediction in output dataset "_SalesPrediction" and compare it with 
Actual Total_Sales and gauge the accuracy of model*/
PROC REG DATA=Retail;
MODEL Total_Sales= Quantity Profit ;
output out = _SalesPrediction p=Predicted_Total_Sales;
run;


/* Step 6: Optional - You can see that predictions are -ve for Product 2.
Next Step - Run a model separately for Product 2 and rest of products separately */
