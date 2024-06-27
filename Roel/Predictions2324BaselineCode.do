clear

local sheetname "Program4"
import excel "..." , sheet("`sheetname'") firstrow clear 


gen pass = (CreditsB1B2 >= 18 & !missing(CreditsB1B2))




*Calculate accuracy and other
egen total_passed = total(pass)
gen a = _N
gen percentage = (total_passed / _N)* 100
gen total_failed = (_N - total_passed)
browse