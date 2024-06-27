clear

//Change the sheetname here to the program of interest
local sheetname "Program4"


//import the training data
import excel "...", sheet("`sheetname'") firstrow


//Rename courses, STATA can have difficulties reading certain names if not changed
capture rename Course31 Course3_1
capture rename Course91 Course9_1
capture rename Course81 Course8_1
capture rename Course71 Course7_1
capture rename Course41 Course4_1
capture rename Course61 Course6_1
capture rename Course51 Course5_1
capture rename Course121 Course12_1
capture rename Course21 Course2_1
capture rename Course11 Course1_1
capture rename Course111 Course11_1
capture rename Course101 Course10_1
capture rename V Course11



// Create a macro to hold all variable names
ds Course*

// Extract columns for first tries
ds Course*_1
local first_try_columns `r(varlist)'

// Extract columns for resits
ds Course*R
local resit_columns `r(varlist)'

// Extract columns for final grades (exclude first try and resit columns)
ds Course*
local course_columns `r(varlist)'

local final_grade_columns ""
foreach var of local course_columns {
    if !regexm("`var'", "_1$") & !regexm("`var'", "R$") {
        local final_grade_columns `final_grade_columns' `var'
    }
}


// Initialize an empty list to store column names (block1and2_results)
local block1and2_results

// Extract the relevant course columns (first attempt and resits)
foreach col of local first_try_columns {
    local course_num : subinstr local col "-1" "", all
    local block1and2_results `block1and2_results' `col'
    local resit_col = "`course_num'-R"
    if "`resit_col'" != "" & strpos("`resit_columns'", "`resit_col'") {
        local block1and2_results `block1and2_results' `resit_col'
    }
}


// Initialize the absent variable
gen absent = 0

foreach col of local first_try_columns {
    replace absent = absent + 1 if missing(`col')
}

foreach col of local resit_columns {
    replace absent = absent + 1 if missing(`col')
}

foreach col of local first_try_columns {
   local resit_col = subinstr("`col'", "_1", "R", . )

	capture confirm numeric variable `resit_col'
	if _rc == 0 {
		replace absent = absent -1 if !missing(`col') & `col' >= 5.5
	}
}


// Calculate students' average grades for block 1 and 2
egen average_gradeB1B2 = rowmean(`block1and2_results')
replace average_gradeB1B2 = round(average_gradeB1B2, 0.01)

// Initialize local macros to store mean of each course
local mean_vars

// Calculate mean for each course and store in a macro
foreach col of local block1and2_results {
    local mean_var = "mean_`col'"
    egen `mean_var' = mean(`col')
    replace `mean_var' = round(`mean_var', 0.01)
    local mean_vars `mean_vars' `mean_var'
}

// Generate the mean of all courses for block 1 and 2
egen mean_programB1B2 = rowmean(`mean_vars')
replace mean_programB1B2 = round(mean_programB1B2, 0.01)



// Generate deviations from the mean per course
foreach col of local block1and2_results {
    // Define the corresponding mean variable name
    local mean_var = "mean_`col'"
    
    // Generate the deviation variable for each course
    gen deviation_`col' = `col' - `mean_var'
    replace deviation_`col' = round(deviation_`col', 0.01)
}

// Calculate the deviation of the student's average grade from the mean program grade
gen deviationB1B2 = average_gradeB1B2 - mean_programB1B2
replace deviationB1B2 = round(deviationB1B2, 0.01)




gen YEAR = 0


//Iterate through `final_grade_columns` and update `YEAR`
foreach var of local final_grade_columns {
    replace YEAR = YEAR + 6 if `var' >= 5.5 & !missing(`var')
}


*Dummies BSA

gen passed42 = (YEAR >= 42)
gen passed48 = (YEAR >=48)
gen passed36 = (YEAR >=36)

























*change target below to amount of credits of interest

****************************************************************************************************

gen target = passed42 

logit target deviationB1B2 absent CrdB1B2

****************************************************************************************************


































est table, eform

margins, dydx(*)

vif, uncentered

estimates store model1


import excel "...", sheet("`sheetname'") firstrow clear 



//Rename courses, STATA can have difficulties reading certain names if not changed
capture rename Course31 Course3_1
capture rename Course91 Course9_1
capture rename Course81 Course8_1
capture rename Course71 Course7_1
capture rename Course41 Course4_1
capture rename Course61 Course6_1
capture rename Course51 Course5_1
capture rename Course121 Course12_1
capture rename Course21 Course2_1
capture rename Course11 Course1_1
capture rename Course111 Course11_1
capture rename Course101 Course10_1
capture rename V Course11



// Create a macro to hold all variable names
ds Course*

// Extract columns for first tries
ds Course*_1
local first_try_columns `r(varlist)'

// Extract columns for resits
ds Course*R
local resit_columns `r(varlist)'

// Extract columns for final grades (exclude first try and resit columns)
ds Course*
local course_columns `r(varlist)'

local final_grade_columns ""
foreach var of local course_columns {
    if !regexm("`var'", "_1$") & !regexm("`var'", "R$") {
        local final_grade_columns `final_grade_columns' `var'
    }
}


// Initialize an empty list to store column names (block1and2_results)
local block1and2_results

// Extract the relevant course columns (first attempt and resits)
foreach col of local first_try_columns {
    local course_num : subinstr local col "-1" "", all
    local block1and2_results `block1and2_results' `col'
    local resit_col = "`course_num'-R"
    if "`resit_col'" != "" & strpos("`resit_columns'", "`resit_col'") {
        local block1and2_results `block1and2_results' `resit_col'
    }
}


// Initialize the absent variable
gen absent = 0

foreach col of local first_try_columns {
    replace absent = absent + 1 if missing(`col')
}

foreach col of local resit_columns {
    replace absent = absent + 1 if missing(`col')
}

foreach col of local first_try_columns {
   local resit_col = subinstr("`col'", "_1", "R", . )

	capture confirm numeric variable `resit_col'
	if _rc == 0 {
		replace absent = absent -1 if !missing(`col') & `col' >= 5.5
	}
}


// Calculate students' average grades for block 1 and 2
egen average_gradeB1B2 = rowmean(`block1and2_results')
replace average_gradeB1B2 = round(average_gradeB1B2, 0.01)

// Initialize local macros to store mean of each course
local mean_vars

// Calculate mean for each course and store in a macro
foreach col of local block1and2_results {
    local mean_var = "mean_`col'"
    egen `mean_var' = mean(`col')
    replace `mean_var' = round(`mean_var', 0.01)
    local mean_vars `mean_vars' `mean_var'
}

// Generate the mean of all courses for block 1 and 2
egen mean_programB1B2 = rowmean(`mean_vars')
replace mean_programB1B2 = round(mean_programB1B2, 0.01)



// Generate deviations from the mean per course
foreach col of local block1and2_results {
    // Define the corresponding mean variable name
    local mean_var = "mean_`col'"
    
    // Generate the deviation variable for each course
    gen deviation_`col' = `col' - `mean_var'
    replace deviation_`col' = round(deviation_`col', 0.01)
}

// Calculate the deviation of the student's average grade from the mean program grade
gen deviationB1B2 = average_gradeB1B2 - mean_programB1B2
replace deviationB1B2 = round(deviationB1B2, 0.01)




gen YEAR = 0


//Iterate through `final_grade_columns` and update `YEAR`
foreach var of local final_grade_columns {
    replace YEAR = YEAR + 6 if `var' >= 5.5 & !missing(`var')
}


*Dummies BSA

gen passed42 = (YEAR >= 42)
gen passed48 = (YEAR >=48)
gen passed36 = (YEAR >=36)












*************************************************************************************
gen target = passed42

predict y_hat
*************************************************************************************





*when do we accept correct answer? chance > 0.5
gen binary_predict = (y_hat > 0.5) & !missing(y_hat)


*Calculate accuracy and other
egen total_passed = total(binary_predict)
gen a = _N
gen percentage = (total_passed / _N)* 100
gen total_failed = _N - binary_predict

browse
