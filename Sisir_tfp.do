xtset id Year
sort id Year 


** calculate Gross Investment (net values) for tangible and intangible

gen GI_tangible = TangibleAssets[_n] - TangibleAssets[_n-1] + Depreciation[_n]


gen GI_intangible = IntangibleAssets[_n] - IntangibleAssets[_n-1] + TotalImpairmentAmortisation[_n]



** calculate capital from Prepetual Inventory method


**NEED TO MERGE IN DEPRECIATION RATES --  SEE UKSICdeprMapping.do and DepreciationRates.dta



gen k = TangibleAssets[_n-1] * (1-Depreciation_Tangible[_n]) + GI_tangible[_n]

gen kICT = IntangibleAssets[_n-1] * (1-Amortisation_Intangible[_n]) + GI_intangible[_n]

gen kandICT = k + kICT

replace kandICT = kICT if missing(k)

replace kandICT = k if missing(kICT)

replace kandICT = 0 if kandICT < 0
 
replace kICT = 0 if kICT < 0

replace kICT = kICT + 1 if !missing(k)

replace k = 0 if k < 0 


**log 

replace k = log(k)

replace kICT = log(kICT)

replace kandICT = log(kandICT)




**TFP estimation - other inputs other than capital


*Calculating the var2 variable denoting intermediate inputs
gen var2 = abs(CostofSales) + abs(AdministrationExpenses) - Remuneration

*Log of intermediate inputs
qui gen double m = log(var2)
label var m "Log value intermediate inputs"

*Log of the number of employees
qui gen double l=log(Numberofemployees)
label var l "Log number of employess"

*Log value added
qui gen double va = log(Turnover - var2)
label var va "Log value added"




*** RUN PRODUCTION FUCTION FOR INTAG AND TANG ***
drop if missing(id)


****ACF******

acfest va, state(k kICT) proxy(m) free(l) nbs(${bsn}) va

predict double tfp_7_ACF_TangIntang, omega

 
***** RUNING JUST FOR TANGIBLE ASSETS *****

acfest va, state(k) proxy(m) free(l) nbs(${bsn}) va

predict double tfp_7_ACF_Tang, omega





***** LP ******
** just tangibles

levpet va, free(l) proxy(m) capital(k) valueadded reps(${bsn})

predict double tfp_7_LP_Tang, omega 

replace tfp_7_LP_Tang = log(tfp_7_LP_Tang)


** sum of tang and intang k kICT


levpet va, free(l) proxy(m) capital(kandICT) valueadded reps(${bsn})

predict double tfp_7_LP_kandICT, omega 

replace tfp_7_LP_kandICT = log(tfp_7_LP_kandICT)

