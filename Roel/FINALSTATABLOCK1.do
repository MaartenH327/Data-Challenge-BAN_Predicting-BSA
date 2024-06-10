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

// Display the resulting list of column names
display "block1_results: `block1_results'"



// Initialize the resits_needed variable
gen resits_needed = 0

// Loop through each column in first_try_columns to update resits_needed
foreach col of local block1_results {
    replace resits_needed = resits_needed + 1 if `col' < 5.5 | missing(`col')
}

// Display the result
list resits_needed



// Initialize the absent variable
gen absent = 0

// Loop through each column in first_try_columns to update absent for first attempts
foreach col of local block1_results {
    replace absent = absent + 1 if `col' == .
}

// Display the result
list absent




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

// Display the results
list average_gradeB1 mean_programB1


// Step 1: Generate deviations from the mean per course and calculate how far away each student's average grade is from the mean program grade

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

// Display the results to verify
list deviationB1

// Step 1: Initialize the `YEAR` variable
gen CreditsB1 = 0

foreach var of local block1_results {
    replace CreditsB1 = CreditsB1 + 6 if `var' >= 5.5 & !missing(`var')
}
list CreditsB1


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

gen passed42 = (YEAR >=42)
gen passed48 = (YEAR >=48)
gen passed36 = (YEAR >=36)