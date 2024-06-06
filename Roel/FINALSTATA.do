clear


import excel "C:\Users\lustr\Documents\UVA\BSA Thesis\STATA\BSA-dataset-synthetic.xlsx", sheet("Program1") firstrow


capture rename Course31 Course3_1
capture rename Course91 Course9_1
capture rename Course81 Course8_1
capture rename Course71 Course7_1


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

local final_grade_columns
foreach var of local course_columns {
    if !regexm("`var'", "-1$") & !regexm("`var'", "-R$") {
        local final_grade_columns `final_grade_columns' `var'
    }
}

// Display the results
display "First Try Columns: `first_try_columns'"
display "Resit Columns: `resit_columns'"
display "Final Grade Columns: `final_grade_columns'"

local block1and2_results
// Iterate through each column in first_try_columns
foreach col of local first_try_columns {
    // Extract the course number X from the column name
    local course_num : subinstr local col "_1" "", all
    
    // Add the initial attempt column (CourseX-1)
    local block1and2_results `block1and2_results' `col'
    
    // Check if there's a corresponding resit column (CourseX-R)
    local resit_col = "`course_num'R"
    if "`resit_col'" != "" & strpos("`resit_columns'", "`resit_col'") {
        // Add the resit column to the list
        local block1and2_results `block1and2_results' `resit_col'
    }
}

// Display the resulting list of column names
display "block1and2_results: `block1and2_results'"


// Step 1: Extract first_try_columns (assuming this step is already done and stored in a macro)
// Example: local first_try_columns Course3_1 Course9_1 Course8_1 Course7_1

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

// Display the resulting list of column names (optional)
display "block1and2_results: `block1and2_results'"

// Initialize the resits_needed variable
gen resits_needed = 0

// Loop through each column in first_try_columns to update resits_needed
foreach col of local first_try_columns {
    replace resits_needed = resits_needed + 1 if `col' < 5.5 | missing(`col')
}

// Display the result
list resits_needed



// Initialize the absent variable
gen absent = 0

// Loop through each column in first_try_columns to update absent for first attempts
foreach col of local first_try_columns {
    replace absent = absent + 1 if `col' == .
}

// Loop through each column in first_try_columns to update absent for resit attempts
foreach col of local first_try_columns {
    // Extract the course number without the '-1' suffix
    local course_num : subinstr local col "-1" "", all
    
    // Define the corresponding resit column name
    local resit_col = "`course_num'-R"
    
    // Update absent for resit attempts if the condition is met
    if "`resit_col'" != "" & strpos("`resit_columns'", "`resit_col'") {
        replace absent = absent + 1 if `resit_col' == . & (`col' < 5.5 | missing(`col'))
    }
}

// Display the result
list absent




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

// Display the results
list average_gradeB1B2 mean_programB1B2


// Step 1: Generate deviations from the mean per course and calculate how far away each student's average grade is from the mean program grade

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

// Display the results to verify
list deviationB1B2




// Step 1: Initialize the `YEAR` variable
gen YEAR = 0

// Step 2: Display the final grade columns (optional, for verification)
display "Final Grade Columns: `final_grade_columns'"

// Step 3: Iterate through `final_grade_columns` and update `YEAR`
foreach var of local final_grade_columns {
    replace YEAR = YEAR + 6 if `var' >= 5.5 & !missing(`var')
}

// Display the results to verify
list YEAR


gen Nederland_dummy = (Nationality == "Nederland")

*Dummies BSA

gen passed42 = (YEAR >= 42)
gen passed48 = (YEAR >=48)
gen passed36 = (YEAR >=36)





















logit passed42 deviationB1B2 absent CreditsB1B2
*deviationB1B2 absent CrdB1B2 resit_factor 
*passedC3 passedC9 passedC7 passedC8
*CreditsB1 roel_factor deviationB1
*CrdB1B2 roel_factor deviationB1B2 
*deviationB1B2 absent CrdB1B2 resits_needed 
























est table, eform

margins, dydx(*)

vif, uncentered

estimates store model1


import excel "C:\Users\lustr\Documents\UVA\BSA Thesis\STATA\BSA-dataset-synthetic.xlsx", sheet("Program1") firstrow clear

capture rename Course31 Course3_1
capture rename Course91 Course9_1
capture rename Course81 Course8_1
capture rename Course71 Course7_1


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

local final_grade_columns
foreach var of local course_columns {
    if !regexm("`var'", "-1$") & !regexm("`var'", "-R$") {
        local final_grade_columns `final_grade_columns' `var'
    }
}

// Display the results
display "First Try Columns: `first_try_columns'"
display "Resit Columns: `resit_columns'"
display "Final Grade Columns: `final_grade_columns'"

local block1and2_results
// Iterate through each column in first_try_columns
foreach col of local first_try_columns {
    // Extract the course number X from the column name
    local course_num : subinstr local col "_1" "", all
    
    // Add the initial attempt column (CourseX-1)
    local block1and2_results `block1and2_results' `col'
    
    // Check if there's a corresponding resit column (CourseX-R)
    local resit_col = "`course_num'R"
    if "`resit_col'" != "" & strpos("`resit_columns'", "`resit_col'") {
        // Add the resit column to the list
        local block1and2_results `block1and2_results' `resit_col'
    }
}

// Display the resulting list of column names
display "block1and2_results: `block1and2_results'"


// Step 1: Extract first_try_columns (assuming this step is already done and stored in a macro)
// Example: local first_try_columns Course3_1 Course9_1 Course8_1 Course7_1

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

// Display the resulting list of column names (optional)
display "block1and2_results: `block1and2_results'"

// Initialize the resits_needed variable
gen resits_needed = 0

// Loop through each column in first_try_columns to update resits_needed
foreach col of local first_try_columns {
    replace resits_needed = resits_needed + 1 if `col' < 5.5 | missing(`col')
}

// Display the result
list resits_needed



// Initialize the absent variable
gen absent = 0

// Loop through each column in first_try_columns to update absent for first attempts
foreach col of local first_try_columns {
    replace absent = absent + 1 if `col' == .
}

// Loop through each column in first_try_columns to update absent for resit attempts
foreach col of local first_try_columns {
    // Extract the course number without the '-1' suffix
    local course_num : subinstr local col "-1" "", all
    
    // Define the corresponding resit column name
    local resit_col = "`course_num'-R"
    
    // Update absent for resit attempts if the condition is met
    if "`resit_col'" != "" & strpos("`resit_columns'", "`resit_col'") {
        replace absent = absent + 1 if `resit_col' == . & (`col' < 5.5 | missing(`col'))
    }
}

// Display the result
list absent




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

// Display the results
list average_gradeB1B2 mean_programB1B2


// Step 1: Generate deviations from the mean per course and calculate how far away each student's average grade is from the mean program grade

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

// Display the results to verify
list deviationB1B2




// Step 1: Initialize the `YEAR` variable
gen YEAR = 0

// Step 2: Display the final grade columns (optional, for verification)
display "Final Grade Columns: `final_grade_columns'"

// Step 3: Iterate through `final_grade_columns` and update `YEAR`
foreach var of local final_grade_columns {
    replace YEAR = YEAR + 6 if `var' >= 5.5 & !missing(`var')
}

// Display the results to verify
list YEAR


gen Nederland_dummy = (Nationality == "Nederland")

*Dummies BSA

gen passed42 = (YEAR >= 42)
gen passed48 = (YEAR >=48)
gen passed36 = (YEAR >=36)

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

*gen DISP = (BSA == "DI")
*gen view = CreditsY1
*gen P42 = passed42

*egen Total_disp = total(BSA == "DI")
*egen WhereTP = total(BSA == "DI" & TP == 1)
*egen WhereTN = total(BSA == "DI"  & TN == 1)
*egen WhereFN = total(BSA == "DI"  & FN == 1)
*egen WhereFP = total(BSA == "DI"  & FP == 1)





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



egen Total_FN = total(FN == 1)
egen Total_FP = total(FP == 1)
browse

