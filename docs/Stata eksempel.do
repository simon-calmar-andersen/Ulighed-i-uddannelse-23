***********************
* Eksempel på do-file der gemmer regressions-output i en bestemt mappe og i format så det kan bruges i Latex
***********************


* Change directory (cd): Vælger hvilken mappe, Stata arbejder i:
cd  "/Users/au103612/Dropbox (Dept of Pol Science)/Professorat/Undervisning/Uddannelsespolitik, BA seminar/Latex/Eksempel"

*Indlæs data:
use "Data_Perceptions of public and private performance_final.dta", clear


*Kør regression(er)
reg effective treatment
reg service treatment

*Gem regressionsoutput som tabel, der kan læses af Latex
esttab using tabel.tex, replace
