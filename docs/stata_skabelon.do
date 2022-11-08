***************************************************
* Projekt: Analyse af summer school øvelsesdata
* Forfatter: SCA
* Dato: 11. feb. 2021
* Revision:
***************************************************


* Setup---------------------------------------------------------

clear*

cd "sti-til-den-mappe-du-arbejder-i"

* ssc install balancetable // et lille program, som hjælper til nemt at lave balancetabeller fra Stata til Latex


global kontrolvar "female parental_schooling parental_lincome "



* Data preparation--------------------------------------------------

* Indlæs csv/xls data og gem som school_data_1.dta, school_data_3.dta


* LAv variable som er indlæst som tekst om til tal:
destring parental_schooling test_year_5 test_year_6, ignore(NA) replace

* Flette datasæt

* Brug foreach hver gang samme kommandoer skal gentages!!!
foreach n in 2 3 {
	merge 1:1 person_id using school_data_`n' 
	drop _merge
	}


* Reshape til langt format (samme elev optræder på flere linjer - en for hvert klassetrin/år)


* Gem test score som _raw og lave en standardiseret test score per år (klassetrin)

* Standardize test score by year
bysort year: egen test_score = std(test_score_raw)



* Data analysis------------------------------------------------------

* Balance table
balancetable letter $kontrolvar test_score  using balance.tex if year==5, replace booktabs ctitles("No letter" "Letter" "Difference (2)-(1)")    pvalues 

* Compare means of treatment groups
balancetable letter test_score  using treatment.tex if year==6, replace booktabs ctitles("No letter" "Letter" "Difference (2)-(1)")    pvalues 
