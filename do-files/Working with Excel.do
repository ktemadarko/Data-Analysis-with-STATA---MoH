//From datasets to variables - Export data in Stata into different formats
	****Export a STATA data to Excel
import excel "K:\STATA\MoH-advanced-data-analysis\datasets\HTS_CMIS.xlsx", sheet("Sheet1") firstrow case(lower) clear
keep maritalstatus sex dateofbirth pid testdate entrypoint resultsstatus clearviewresult region facilityname
drop if entrypoint!=""
export excel using "hts.xlsx", sheet("demographics") sheetreplace firstrow(variables)
ta region
drop if region=="MANZINI"
export excel using "hts.xlsx", sheet("demographics") sheetreplace firstrow(variables)
