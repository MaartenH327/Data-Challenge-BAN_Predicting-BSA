clear

//Change the sheetname here to the program of interest
local sheetname "Program3"

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

// Display the results
display "First Try Columns: `first_try_columns'"
display "Resit Columns: `resit_columns'"
display "Final Grade Columns: `final_grade_columns'"

local block1_results ""

// Iterate through each column in first_try_columns
foreach col of local first_try_columns {
    // Extract the course number X from the column name
    local course_num : subinstr local col "_1" "", all
    
    // Check if there's a corresponding resit column (CourseX-R)
    local resit_col = "`course_num'R"
    if "`resit_col'" != "" & strpos("`resit_columns'", "`resit_col'") {
        // Add the first try column to the block1_results list
        local block1_results `block1_results' `col'
    }
}



// Initialize the absent variable
gen absent = 0

// Loop through each column in first_try_columns to update absent for first attempts
foreach col of local block1_results {
    replace absent = absent + 1 if `col' == .
}



// Calculate students' average grades for block 1 and 2
egen average_gradeB1 = rowmean(`block1_results')
replace average_gradeB1 = round(average_gradeB1, 0.01)

// Initialize local macros to store mean of each course
local mean_vars

// Calculate mean for each course and store in a macro
foreach col of local block1_results {
    local mean_var = "mean_`col'"
    egen `mean_var' = mean(`col')
    replace `mean_var' = round(`mean_var', 0.01)
    local mean_vars `mean_vars' `mean_var'
}

// Generate the mean of all courses for block 1 and 2
egen mean_programB1 = rowmean(`mean_vars')
replace mean_programB1 = round(mean_programB1, 0.01)


// Generate deviations from the mean per course
foreach col of local block1_results {
    // Define the corresponding mean variable name
    local mean_var = "mean_`col'"
    
    // Generate the deviation variable for each course
    gen deviation_`col' = `col' - `mean_var'
    replace deviation_`col' = round(deviation_`col', 0.01)
}

// Calculate the deviation of the student's average grade from the mean program grade
gen deviationB1 = average_gradeB1 - mean_programB1
replace deviationB1 = round(deviationB1, 0.01)


*Generate amount of credits
gen CreditsB1 = 0

foreach var of local block1_results {
    replace CreditsB1 = CreditsB1 + 6 if `var' >= 5.5 & !missing(`var')
}

gen YEAR = 0

//Iterate through `final_grade_columns` and update `YEAR`
foreach var of local final_grade_columns {
    replace YEAR = YEAR + 6 if `var' >= 5.5 & !missing(`var')
}

*Dummies BSA
gen passed42 = (YEAR >=42)


















*The model

logit passed42 deviationB1 absent CreditsB1





























*keep predictions in storage, and show tables checking for multicolinearity and correlation

est table, eform

margins, dydx(*)

vif, uncentered

estimates store model1

*import testing data

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

// Display the results
display "First Try Columns: `first_try_columns'"
display "Resit Columns: `resit_columns'"
display "Final Grade Columns: `final_grade_columns'"

local block1_results ""

// Iterate through each column in first_try_columns
foreach col of local first_try_columns {
    // Extract the course number X from the column name
    local course_num : subinstr local col "_1" "", all
    
    // Check if there's a corresponding resit column (CourseX-R)
    local resit_col = "`course_num'R"
    if "`resit_col'" != "" & strpos("`resit_columns'", "`resit_col'") {
        // Add the first try column to the block1_results list
        local block1_results `block1_results' `col'
    }
}



// Initialize the absent variable
gen absent = 0

// Loop through each column in first_try_columns to update absent for first attempts
foreach col of local block1_results {
    replace absent = absent + 1 if `col' == .
}



// Calculate students' average grades for block 1 and 2
egen average_gradeB1 = rowmean(`block1_results')
replace average_gradeB1 = round(average_gradeB1, 0.01)

// Initialize local macros to store mean of each course
local mean_vars

// Calculate mean for each course and store in a macro
foreach col of local block1_results {
    local mean_var = "mean_`col'"
    egen `mean_var' = mean(`col')
    replace `mean_var' = round(`mean_var', 0.01)
    local mean_vars `mean_vars' `mean_var'
}

// Generate the mean of all courses for block 1 and 2
egen mean_programB1 = rowmean(`mean_vars')
replace mean_programB1 = round(mean_programB1, 0.01)


// Generate deviations from the mean per course
foreach col of local block1_results {
    // Define the corresponding mean variable name
    local mean_var = "mean_`col'"
    
    // Generate the deviation variable for each course
    gen deviation_`col' = `col' - `mean_var'
    replace deviation_`col' = round(deviation_`col', 0.01)
}

// Calculate the deviation of the student's average grade from the mean program grade
gen deviationB1 = average_gradeB1 - mean_programB1
replace deviationB1 = round(deviationB1, 0.01)


*Generate amount of credits
gen CreditsB1 = 0

foreach var of local block1_results {
    replace CreditsB1 = CreditsB1 + 6 if `var' >= 5.5 & !missing(`var')
}

gen YEAR = 0

//Iterate through `final_grade_columns` and update `YEAR`
foreach var of local final_grade_columns {
    replace YEAR = YEAR + 6 if `var' >= 5.5 & !missing(`var')
}

*Dummies BSA
gen passed42 = (YEAR >=42)

*make predictions
predict y_hat


*when do we accept correct answer? chance > 0.5
gen binary_predict = (y_hat > 0.5) & !missing(y_hat)
*was prediction correct?
gen correct_prediction = (passed48 == binary_predict)
*gen correct_prediction = (passed42 == binary_predict)

*Calculate accuracy and other

egen total_correct = total(correct_prediction)
gen total_incorrect = _N - total_correct

*generate TruePositives etc
gen TP = (passed48 == 1 & binary_predict == 1)
gen FP = (passed48 == 0 & binary_predict == 1)
gen TN = (passed48 == 0 & binary_predict == 0)
gen FN = (passed48 == 1 & binary_predict == 0)


*Calculate precision and recall
egen a = total(TP)
egen b = total(FP)
egen c = total(FN)
gen accuracy = total_correct / _N 
gen precision = (a / (a + b))
gen recall = (a / (a + c))
gen F1score = (2*precision * recall)/(precision + recall)

replace F1score = round(F1score, 0.01)
replace accuracy = round(accuracy, 0.01)
replace precision = round(precision, 0.01)
replace recall = round(recall, 0.01)
gen sum = accuracy + F1score + precision + recall
scalar precision = (a / (a + b))
scalar recall = (a / (a + c))
drop a b c

*show total false negatives and false positives
egen Total_FN = total(FN == 1)
egen Total_FP = total(FP == 1)

*show results
browse