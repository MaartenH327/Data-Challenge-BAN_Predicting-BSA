clear

import excel "C:\Users\lustr\Documents\UVA\BSA Thesis\STATA\BSA-dataset-synthetic.xlsx", sheet("Program1") firstrow

*change variable names
rename Course31 Course3_1
rename Course91 Course9_1
rename Course81 Course8_1
rename Course71 Course7_1

*Dummies passed course?
gen passedC3 = (Course3 >= 5.5)
gen passedC8 = (Course8 >= 5.5)
gen passedC7 = (Course7 >= 5.5)
gen passedC9 = (Course9 >= 5.5)

*generate the resit rate dummy
gen roel_factor = 0
replace roel_factor = 1 if Course3R == . & Course9R != .
replace roel_factor = 1 if Course3R != . & Course9R == .
replace roel_factor = 2 if Course3R != . & Course9R != .


* Generate variable "not_started" dummy
gen not_started = (Course3 == . & Course8 == . & Course9 == . & Course7 == . & Course23 == . & Course26 == . & Course16 == . & Course22 == . & Course25 == . & Course24 == . & CreditsY1 == .)


* Average grades block 1 and 2
egen average_gradeB1B2 = rowmean(Course3 Course8 Course9 Course7)
replace average_gradeB1B2 = round(average_gradeB1B2, 0.01) 
*Average grade dummy
gen Maarten_B1B2 = (average_gradeB1B2 >=5.5)

*average all final grades in year
egen average_gradeY1 = rowmean(Course23 Course26 Course3 Course16 Course8 Course9 Course22 Course7 Course25 Course24)
replace average_gradeY1= round(average_gradeY1, 0.01) 
gen Maarten_Y1 = (average_gradeY1 >=5.5)


egen mean_course3 = mean(Course3)
egen mean_course7 = mean(Course7)
egen mean_course8 = mean(Course8)
egen mean_course9 = mean(Course9)
replace mean_course3 = round(mean_course3, 0.01) 
replace mean_course7 = round(mean_course7, 0.01) 
replace mean_course8 = round(mean_course8, 0.01) 
replace mean_course9 = round(mean_course9, 0.01) 

gen deviation_course3 = Course3 - mean_course3
replace deviation_course3 = round(deviation_course3, 0.01) 
gen deviation_course7 = Course7 - mean_course7
replace deviation_course7 = round(deviation_course7, 0.01) 
gen deviation_course8 = Course8 - mean_course8
replace deviation_course8 = round(deviation_course8, 0.01) 
gen deviation_course9 = Course9 - mean_course9
replace deviation_course9 = round(deviation_course9, 0.01) 


gen CREDITS = 0
foreach var of varlist Course3 Course8 Course9 Course7 {
    replace CREDITS = CREDITS + 6 if `var' >= 5.5 & !missing(`var')
}

gen YEAR = 0
foreach var of varlist Course23 Course26 Course3 Course16 Course8 Course9 Course22 Course7 Course25 Course24 {
    replace YEAR = YEAR + 6 if `var' >= 5.5 & !missing(`var')
}

*no credits at all
gen zero_credits = 0
replace zero_credits = 1 if  YEAR == 0
*Dummies BSA
gen warned = (CREDITS <= 18)
gen passed42 = (YEAR >= 42)
gen passed48 = (YEAR >=48)

regress  passed42 passedC3 passedC8 passedC7 passedC9
predict yhat1
regress  passed48 passedC3 passedC8 passedC7 passedC9
predict yhat2


gen quit_early = 0
replace quit_early = 1 if missing(Course23) & missing(Course26) & missing(Course16) & missing(Course22) & missing(Course25) & missing(Course24)



*change labels 
label variable train "ID"
label variable Gender "Gender"
label variable Nationality "Nationality"
label variable PreEducation "Pre-Education"
label variable Program "Program name"
label variable Year "Year of programm"
label variable BSA "BSA result"
label variable Course3_1 "First try Course 3"
label variable Course9_1 "First try Course 9"
label variable Course8_1 "First try Course 8"
label variable Course7_1 "First try Course 7"
label variable Course3R "Grade resit Course 3"
label variable Course9R "Grade resit Course 9"
label variable CreditsB1B2 "Credits block 1 and 2"
label variable Course23 "Grade Course 23"
label variable Course26 "Grade Course 26"
label variable Course3 "Grade Course 3"
label variable Course16 "Grade Course 16"
label variable Course8 "Grade Course 8"
label variable Course9 "Grade Course 9"
label variable Course22 "Grade Course 22"
label variable Course7 "Grade Course 7"
label variable Course25 "Grade Course 25"
label variable Course24 "Grade Course 24"
label variable CreditsY1 "Credits year 1"
label variable warned "Warned halfway"

label variable passedC3 "Passed Course 3"
label variable passedC8 "Passed Course 8"
label variable passedC7 "Passed Course 7"
label variable passedC9 "Passed Course 9"

label variable roel_factor "Number of Resits"
label variable not_started "Did not Start at all"
label variable zero_credits "Zero Credits achieved"
label variable quit_early "Quit study early"
label variable average_gradeB1B2 "Average grade block 1 and 2"
label variable Maarten_B1B2 "Average grade 5.5 or higher block 1 and 2"
*gender dummy
*gen gender_dummy = (Gender == "M")

*nationality dummies
*gen Nederland_dummy = (Nationality == "Nederland")
*gen Azie_dummy = (Nationality == "Azie")
*gen EU_dummy = (Nationality == "EU")
*gen Afrika_dummy = (Nationality == "Afrika")
*gen Europa_dummy = (Nationality == "Europa")
*gen Oceanie_dummy = (Nationality == "Oceanie")
*gen Onbekend_dummy = (Nationality == "Onbekend")
*gen Noord_Amerika_dummy = (Nationality == "Noord-Amerika")
*gen Mid_Zuid_Amerika_dummy = (Nationality == "Mid-Zuid-Amerika")

*label variable gender_dummy "Gender"
*label variable Nederland_dummy "Nederlands"
*label variable Azie_dummy "Aziatisch"
*label variable EU_dummy "EU lidstaat"
*label variable Afrika_dummy "Afrikaans"
*label variable Europa_dummy "Europees"
*label variable Oceanie_dummy "Oceanie"
*label variable Onbekend_dummy "Unknown"
*label variable Noord_Amerika_dummy "Noord-Amerikaans"
*label variable Mid_Zuid_Amerika_dummy "Midden-Zuid-Amerikaans"

browse 