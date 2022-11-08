***************************************************
* Projekt: Analyse af summer school øvelsesdata
* Forfatter: SCA
* Dato: 11. feb. 2021
* Revision: 
*			23. feb. 2021: Tilpasning til Mac
*			26. feb. 2021: Øvelse med regression
***************************************************


* Setup---------------------------------------------------------

clear*

cd "C:\Users\au103612\Dropbox (Dept of Pol Science)\Professorat\Undervisning\Uddannelsespolitik, BA seminar\Øvelser\Sievertsen_ovelse"
*cd "/Users/au103612/Dropbox (Dept of Pol Science)/Professorat/Undervisning/Uddannelsespolitik, BA seminar/Øvelser/Sievertsen_ovelse/"

* ssc install balancetable

global kontrolvar "female parental_schooling parental_lincome "

global outcomes "test_score_raw test_score"

* Data preparation--------------------------------------------------

* Indlæse csv/xls data og gemme som dta
import delimited "school_data_1.csv"
* import delimited "/Users/au103612/Dropbox (Dept of Pol Science)/Professorat/Undervisning/Uddannelsespolitik, BA seminar/Øvelser/Sievertsen_øvelse/school_data_1.csv", delimiter(";") clear 

destring parental_schooling test_year_5 test_year_6, ignore(NA) replace
save "school_data_1.dta", replace

import excel "school_data_3.xlsx", firstrow clear
save "school_data_3.dta", replace

* Flette datasæt
use school_data_1

foreach number in 2 3 {
	merge 1:1 person_id using school_data_`number'
	drop _merge 
	}


* Reshape til langt format (samme elev optræder på flere linjer - en for hvert klassetrin/år)
reshape long test_year_, i(person_id) j(year)
rename test_year_ test_score_raw

lab var  letter "Invitation letter"

* Standardize test score by year
bysort year: egen test_score = std(test_score_raw)
/*For Stata 15 el. tidligere, som ikke tillader by i fbm. egen... std:
egen test_score_mean = mean(test_score_raw), by(year)
egen test_score_sd = sd(test_score_raw), by(year)
gen test_score = (test_score_raw-test_score_mean)/test_score_sd
*/

* Data analysis------------------------------------------------------

* Balance table
balancetable letter female parental_schooling parental_lincome test_score  using balance.tex if year==5, replace booktabs ctitles("No letter" "Letter" "Difference (2)-(1)")    pvalues 

* Compare means of treatment groups (looper over de to test scores: raw og standardized)
foreach out in $outcomes {
	balancetable letter `out'  using treatment_`out'.tex if year==6, ///
	replace booktabs ctitles("No letter" "Letter" "Difference (2)-(1)")    pvalues 
	}
	

	
* Regression -----------------------------------------------------

reg summercamp $kontrolvar
predict summercamp_predicted, xb
predict summercamp_res, res
browse summercamp*


* Regression af test-score på deltagelse i summer school - bruge esttab til output til Latex/Word
eststo clear
eststo: reg test_score summercamp
eststo: reg test_score summercamp $kontrolvar
eststo: reg test_score summercamp_res

*Tabel til Latex
esttab using regression.tex, se ar2 booktabs replace
*Tabel til Word
*esttab using regression.rtf, se  replace

* Regression af test-score på randomiseret letter
eststo clear
eststo: reg test_score letter
eststo: reg test_score letter $kontrolvar

*Tabel til Latex
esttab using regression_letter.tex, se ar2 booktabs replace
*Tabel til Word
*esttab using regression_letter.rtf, se  replace
