##1.To record the patient statistics, the agency wants
##  to find the age category of people who frequents the hospital and has the maximum expenditure.
library(dplyr)
setwd("C:\\DataSets")
hs<-read.csv("HospitalCosts.csv")
hist(hs$AGE, main = "Histogram for Age",xlab = "Age")
table(hs$AGE)
tapply(X = hs$TOTCHG, INDEX = list(hs$AGE), FUN = sum,na.rm = T)


##Result:
##age category of people who frequents the hospital is :0-1
##age catogery of people who has the maximum expenditure is :0-1
#NOte: since it is sample data outliers not removed from data set.


##2.In order of severity of the diagnosis and treatments and to find out the expensive treatments,
##the agency wants to find the diagnosis related group that has maximum hospitalization and expenditure.

hist(hs$APRDRG, main = "Diagnosis realted group",col = "blue",xlab = "APRDRG")
summarise(group_by(hs,APRDRG), TotalCharge = sum(TOTCHG, na.rm = T), LengthOfStay = sum(LOS),Number = n())->DG1
paste("Diagnosis related group that has maximum hospitalization is :", as.character(DG1$APRDRG[DG1$LengthOfStay == max(DG1$LengthOfStay)]))
paste("Diagnosis related group that has maximum expenditure is :" , as.character(DG1$APRDRG[DG1$TotalCharge == max(DG1$TotalCharge)]))

##Result:
##diagnosis related group that has maximum hospitalization is :640
##diagnosis related group that has maximum expenditure is      :640


##3.To make sure that there is no malpractice, the agency needs to analyze 
##  if the race of the patient is related to the hospitalization costs.

##Data Preprocessing
##Impute the missing values
colSums(is.na(hs))
##delete all the rows having NA
na.omit(object = hs)->Hospital3
colSums(is.na(Hospital3))

##Uni-variate analysis as well as Bi-Variate analysis to verify correlation between label and features
library(corrplot)
cor(Hospital3)
corrplot(cor(Hospital3))


##To verify race of the patient is related to the hospitalization costs
model_anova = aov(TOTCHG~RACE, data = Hospital3)
summary(model_anova)

##Result: There is no significance association between race and hospitalization costs .


##To properly utilize the costs, the agency has to analyze the severity of the hospital costs 
## by age and gender for proper allocation of resources.

model_anova1 = aov(TOTCHG~., data = Hospital3)
summary(model_anova1)

##Result:since age and gender associated with costs.
##agency can analyze the severity of the hospital costs based on age and gender.

##5.Since the length of stay is the crucial factor for inpatients, the agency wants 
## to find if the length of stay can be predicted from age, gender, and race.


## To find out outliers of LOS(Length of stay)
a = boxplot(Hospital3$LOS)
a$out
## To find out outliers of TOTCHG(Hospital discharge costs)
b=boxplot(Hospital3$TOTCHG)
b$out
##To delete outliers from both LOS and TOTCHG
hosp3 = hs[-which(Hospital3$LOS %in% a$out,Hospital3$TOTCHG %in% b$out),]

##To Create a linear regression model to find if the length of stay can be predicted from age, gender, and race.
lr_model = lm(formula = LOS~AGE+RACE+FEMALE, data = hosp3)
summary(lr_model)

##Result:Agency can't predict length of stay from age, gender, and race(LOS ~ AGE + RACE + FEMALE)
##Adjusted R-squared is very low and p-value is greather than 0.05.

##6.To perform a complete analysis, the agency wants 
# to find the variable that mainly affects the hospital costs.

##To create a linear regression model
lr_model = lm(formula = TOTCHG~., data = hosp3)
summary(lr_model)

##Result:LOS,APRDRG, and AGE effects the hospital costs.