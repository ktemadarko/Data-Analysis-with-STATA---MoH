**************************************************
*************DATA ANALYSIS WORKSHOP***************
*******************EXERCISES**********************
cd "K:\STATA\MoH-advanced-data-analysis\datasets\"
****Remember to SET MORE OFF
	set more off
	************
	//Reading Dates into STATA
	**Begin by importing/opening a STATA data file
	//Remember that import is different from open
	*HINT: Open - a STATA data. *Import - a data from another source e.g excel spreadsheet
	import delimited "PMTCT_CMIS.csv", varnames(1) clear
	browse //Browse the dataset to note data structure
	*All date related variables including Date of birth, dateofvist, ancstartdate and hivdiagnosed date are string
	***Remember variable types? 
	
	//Generate a new dateofbirth, note that the existing is structured as MDY
	generate dob_pmtct= date(dateofbirth_pmtct, "MDY") //genereate a new date of birth
	format dob_pmtct %td //format as a date.
	****************************
	//Repeat this process for others.
	generate ancstartdate_pmtct= date(ancstart_pmtct, "MDY") //genereate a new date of ANC Start
	format ancstartdate_pmtct %td //format as a date. ***ancstrt_pmtct

	generate hivdiagn_pmtct= date(hivdiagnosisdate_pmtct, "MDY") //genereate a new date of HIV diagnosis
	format hivdiagn_pmtct %td //format as a date.

	generate dov_pmtct= date(dateofvisit_pmtct, "MDY") //genereate a new date of visit
	format dov_pmtct %td //format as a date.
	drop dateofbirth_pmtct dateofvisit_pmtct hivdiagnosisdate_pmtct ancstart_pmtct //drop the previous date of birth variable

//////////////////////////////PRIOR TO ATTEMPTING EXERCISES, LET'S DO A FEW MANAGEMENT.
ta region_pmtct
***Note that there are fewer regions (19,528) compared 
**to the total observation (19,600). This is NOT NORMAL
ta region_pmtct, missing
//Note how there are 72 missing values browse and identify where they are from
gen region=proper(region_pmtct)
replace region="Manzini" if region_pmtct==""

drop region_pmtct
rename region region_pmtct
ta region_pmtct
//Seems perfect now.
	
**EXERCISE 1 -
	**Generate a new variable - age at HIV diagnosis
		gen age_hivdiagnosis=int((hivdiagn_pmtct-dob_pmtct)/365.5) //Starting with the most recent (ANC Start).
	**Recode the age at diagnosis into 5 years age group and label
	/*recode age_hivdiagnosis (0/4=1 "0-4") (5/9=2 "5-9") (10/14=3 "10-14") (15/19=4 "15-19") ///
		(20/24=5 "20-24") (25/29=6 "25-29") (30/34=7 "30-34") (35/39=8 "35-39") ///
			(40/44=9 "40-44") (45/49=10 "45-49") (50/max=11 "50+"), gen(age_grp)*/
		recode age_hivdiagnosis (min/14=1 "<15") (15/19=2 "15-19") (20/24=3 "20-24") ///
		(25/29=4 "25-29") (30/34=5 "30-34") (35/39=6 "35-39")(40/44=7 "40-44") ///
			(45/49=8 "45-49") (50/max=9 "50+"), gen(age_grp)
			
	**Cross-tabulate age group with region for women who attended ANC since 01 January 2017
		tab age_grp region_pmtct if ancstartdate_pmtct>=d(01jan2017)
		
	**Cross-tabulate age group with region for women who attended ANC between January-September 2017
		tab age_grp region_pmtct if ancstartdate_pmtct>=d(01jan2017)&ancstartdate_pmtct<=d(30sep2017)
		
	**Tabulate age group with region for women who were diagnosed before 01 July 2017
		tab age_grp region_pmtct if hivdiagn_pmtct<=d(01jul2017)
		
	**Tabulate region for women who were born after 01 January 1980 and started ANC between 01 Sep 2016 - 31 Oct 2017
		tab region_pmtct if dob_pmtct>d(01jan1980)&(ancstartdate_pmtct>d(01sep2016)&ancstartdate_pmtct<d(31oct2017))
		
	**Cross-tabulate region with age group for women between 20-34 years and diagnosed in 01-30 Sep 2016 or 01-31 Oct 2017
		tab region_pmtct age_grp if (age_hivdiagnosis>20&age_hivdiagnosis<34) ///
			&((hivdiagn_pmtct>=d(01sep2016)&hivdiagn_pmtct<=d(30sep2016))| ///
				(hivdiagn_pmtct>=d(01oct2017)&hivdiagn_pmtct<=d(30oct2017)))
				
	**NB: All age groups in the above refers to age group at diagnosis not necessarily their current age
	******HINT**** gen age_hivdiagnos=int((dateofdiagnosis-dateofbirth)/365.5)

**EXERCISE 2 - 
	**Generate a new variable - age at ANC Start
		gen age_atanc=int((ancstartdate_pmtct-dob_pmtct)/365.5) //Starting with the most recent (ANC Start).
	**Recode the age at diagnosis into 5 years age group and label
	/*recode age_hivdiagnosis (0/4=1 "0-4") (5/9=2 "5-9") (10/14=3 "10-14") (15/19=4 "15-19") ///
		(20/24=5 "20-24") (25/29=6 "25-29") (30/34=7 "30-34") (35/39=8 "35-39") ///
			(40/44=9 "40-44") (45/49=10 "45-49") (50/max=11 "50+"), gen(age_grp)*/
		recode age_atanc (min/14=1 "<15") (15/19=2 "15-19") (20/24=3 "20-24") ///
		(25/29=4 "25-29") (30/34=5 "30-34") (35/39=6 "35-39")(40/44=7 "40-44") ///
			(45/49=8 "45-49") (50/max=9 "50+"), gen(age_grpanc)
		tab age_grpanc

	**Create a new variable diagnosis status - 1 "Not diagnosed" 2 "Diagnosed
	*****HINT***** - Those not diagnosed are missing (.)
		gen diagnos_stat=.
			replace diagnos_stat=1 if hivdiagn_pmtct==.
			replace diagnos_stat=2 if hivdiagn_pmtct!=.
			label define diagnos_stat 1 "Not diagnosed" 2 "Diagnosed"
			label values diagnos_stat diagnos_stat
		tabulate diagnos_stat

	**Provide the percentage of ANC women 20-34 years who were not diagnosed.
		tab diagnos_stat if age_atanc>=20&age_atanc<=34
	
	**How many pregnant women 15-24 years were diagnosed in 2017?
		count if hivdiagn_pmtct>=d(01jan2017)&age_atanc>=15&age_atanc<=24
		tabulate age_grpanc if hivdiagn_pmtct>=d(01jan2017)&age_atanc>=15&age_atanc<=24

	**How many pregnant women in HHOHHO region were not diagnosed?
		count if region_pmtct=="Hhohho"&hivdiagn_pmtct==.
		count if region_pmtct=="Hhohho"&diagnos_stat==1
		tabulate region_pmtct if diagnos_stat==1
		tabulate region_pmtct if hivdiagn_pmtct==.
		
	**How many pregnant women in the regions excluding HHOHHO were diagnosed before 01 Jan 2017
		count if (hivdiagn_pmtct<d(01jan2017)&region_pmtct!="Hhohho")
		tabulate region_pmtct if (hivdiagn_pmtct<d(01jan2017)&region_pmtct!="Hhohho")
		
	**How many of the women who started ANC between 01 Sep 2016 – 30 October 2017 were not diagnosed
		count if (ancstartdate_pmtct>d(01sep2016)&ancstartdate_pmtct<d(30oct2017))& diagnos_stat==1
		count if (ancstartdate_pmtct>d(01sep2016)&ancstartdate_pmtct<d(30oct2017))& hivdiagn_pmtct==.
		tabulate diagnos_stat if (ancstartdate_pmtct>d(01sep2016)&ancstartdate_pmtct<d(30oct2017))& diagnos_stat==1
		tabulate diagnos_stat if (ancstartdate_pmtct>d(01sep2016)&ancstartdate_pmtct<d(30oct2017))
		
***https://docs.google.com/spreadsheets/d/1z9pILqPlqIFolo9LMNd4Pzfwa5wsrLN65N0mHLKyJJY/edit?usp=sharing
loc url https://docs.google.com/spreadsheets/d/1z9pILqPlqIFolo9LMNd4Pzfwa5wsrLN65N0mHLKyJJY/edit?usp=sharing
if c(os)=="MacOSX" {
    !open `url'
}
else if c(os)=="Unix" {
    // requires xdg-utils
    !xdg-open `url'
}
else if c(os)=="Windows" {
    !cmd /c start `url'
}
//	

