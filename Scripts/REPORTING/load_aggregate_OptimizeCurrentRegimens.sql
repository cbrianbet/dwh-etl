IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateOptimizeCurrentRegimens]', N'U') IS NOT NULL	
	DROP table [REPORTING].[dbo].[AggregateOptimizeCurrentRegimens];

SELECT 
	SiteCode,
	FacilityName,
	County, 
	Subcounty, 
	PartnerName,
	AgencyName,
	Agegroup,
	DATIMAgeGroup,
	Gender,
	StartRegimen,
	StartARTMonth,
	StartARTYr,
    AsOfDate,
	CurrentVL,
	SUM(ISTxCurr) As TXCurr,
	CurrentRegimen,
	Lastregimen,
	RegimenLine,
	LastRegimenClean,
	WeightBands,
	AgeBands,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO [REPORTING].[dbo].[AggregateOptimizeCurrentRegimens]
from (
	Select 
		cast (MFLCode as nvarchar) As SiteCode,
		FacilityName,
		County, 
		Subcounty, 
		PartnerName,
		AgencyName,
		DateName(m,StartARTDateKey) AS StartARTMonth,
		Year(StartARTDateKey) AS StartARTYr,
        EOMONTH(date.Date ) AS AsOfDate,
		CASE 
			WHEN CurrentRegimen like '3TC+DTG+TDF' THEN 'TLD'
			WHEN CurrentRegimen like '3TC+EFV+TDF' THEN 'TLE'
			WHEN CurrentRegimen like '%NVP%' THEN 'NVP'
			ELSE  'Other Regimen' 
		END AS CurrentRegimen,
		CurrentRegimen Lastregimen,
		StartRegimen,
		pat.Gender,
		CASE WHEN currentRegimenLine like 'First%' OR currentRegimenLine like '%PMTCT%' THEN 'First Regimen Line'
			WHEN currentRegimenLine like 'Second%' THEN 'Second Regimen Line'
			WHEN currentRegimenLine like 'Third%' THEN 'Third Regimen Line'
			ELSE 'Undocumented Regimen Line' 
		END AS RegimenLine,
		Agegrouping as Agegroup,
		b.DATIMAgeGroup,
		age,
		vl.LastVL AS CurrentVL,
		ISTxCurr,

		CASE 
			WHEN cast (obs.LatestWeight as float) <20 Then '<20Kgs'
			WHEN cast (obs.LatestWeight as float) >20 and cast (obs.LatestWeight as float) <=35 THEN '20-35Kgs'
			when cast (obs.LatestWeight as float) >35  and cast (obs.LatestWeight as float) <100 THEN '>35Kgs'
			ELSE 'Not Documented' 
		END AS WeightBands,

		CASE 
			WHEN cast (age as float) <2 THEN '<2 Years'
			WHEN cast (age as float) between 2 and 4	THEN '2-4 Years'
			WHEN cast (age as float) between 5 and 9 THEN '5-9 Years'
			WHEN cast (age as float) between 10 and 14 THEN '10-14 Years'
			ELSE 'Adults' 
		END AS AgeBands,
    
		CASE
			WHEN CurrentRegimen in ('3TC+ABC+ATV/r','(3TC300mg)+(ABC600mg)+(ATV300mg)+(RTV100mg)') THEN 'ABC+3TC+ATV/r'
			WHEN CurrentRegimen in ('NVP','TDF','AZT+DTG','Other','DTG+FTC+TDF','FTC+RPV','AZTliquidBID+NVPliquidODfor6weeksthenNVPliquidODuntil6weeksaftercompletecessationofBreastfeeding','NULL','EFV/3TC/TDF/ATV/r','LOP+RTV','LPV/r','RHE','AZT+EFV+TDF','SRfbHZE','ETR+FTC+TDF','DRV+RTV','VIRAMUNE','ATV+RTV','DTG','EFV','RfbHZ', '3TC+ABC+ATV+RTV+TDF','3TC+ATV+EFV+RTV+TDF','3TC+ABC+DTG+TDF','3TC+D4T+TDF','3TC+DRV/r+RAL+TDF','3TC+EFV+LPV/r+TDF','3TC+ATV/rTV+DTG+TDF','3TC+DTG+FTC+TDF','3TC+AZT+EFV+NVP+TDF','3TC+DTG+EFV+TDF','3TC+EFV+NVP+TDF','3TC+AZT+DTG+NVP+TDF','3TC+DRV+RTV+TDF','3TC+AZT+DTG+TDF','3TC+DRV/r+DTG+EFV+TDF','3TC+ATV+DTG+RTV+TDF',
			'3TC+AF2G-TDF+RAL','3TC+ABC+LOP+RTV+TDF','3TC+DRV+RAL+RTV+TDF','3TC+ATV/r+DTG+TDF','3TC+DRV+DTG+TDF','3TC+DTG+NVP+TDF','3TC+DRV+EFV+RTV+TDF','3TC+ATV/r+AZT+TDF','3TC+DRV+DTG+RTV+TDF','ATV/r+FTC+TDF','3TC+AZT+LPV/r+TDF','3TC+ABC+LPV/r+TDF','3TC+ATV/r+EFV+TDF','3TC+DRV+DTG+ETR+RTV+TDF','3TC+ATV+DTG+TDF','3TC+DRV/r+DTG+TDF','3TC+ETR+LPV/r+TDF',
			'3TC+RAL+TDF','[DTG]+3TC+ATV/rTV+AZT''3TC+ABC','3TC+ABC+ATV+AZT+RTV','3TC+D4T+EFV','3TC+D4T+LPV/r','3TC+D4T+NFV','3TC+D4T+NVP','[DTG]+3TC+ATV/rTV+AZT','3TC+AZT+DTG+NVP''3TC+AZT+DRV+DTG+RTV','3TC+ATV+AZT+NVP+RTV','3TC+ATV/r+AZT+NVP','3TC+ABC+ATV+RTV+TDF','3TC+ABC+DTG+TDF','3TC+ABC+LOP+RTV+TDF','3TC+ABC','3TC+ABC+LOP+RTV+TDF','3TC+ABC+LPV/r+TDF','NULL','3TC+ABC+ATV/r+AZT','3TC+ABC+ATV/r+DTG','3TC+ABC+ATV/r+NVP',
			'3TC+ABC+AZT+LOP+RTV','3TC+ABC+AZT+LPV/r','3TC+ABC+D4T','3TC+ABC+DRV+DTG+RTV','3TC+ABC+DRV+RAL+RTV','3TC+ABC+DRV+RTV','3TC+ABC+DRV/r+RAL','3TC+ABC+DTG+LPV/r','3TC+ABC+RTV','3TC+ATV+AZT+DTG+RTV','3TC+ATV/r+DTG','3TC+AZT+DRV+RAL+RTV','3TC+AZT+DRV+RTV','3TC+AZT+DRV/r+RAL','3TC+AZT+EFV+NVP','3TC+AZT+LOP+NVP+RTV','3TC+AZT+RTV','3TC+DRV+DTG+RTV','3TC+DRV+ETV+RTV','3TC+DRV+RAL+RTV','3TC+DTG','3TC+ZDV','ABC+ATV/r','ABC+AZT+DDI','ABC+DDI+LPV/r','ABC+LPV/r+TDF','Anyother1stlineadult/peadiatricregimen','Anyother1stlineAdultregimens','Anyother1stlinePaediatricregimens','Anyother2ndlineAdultregimens',
			'Anyother2ndlinePaediatricregimens','Anyother3rdlineAdultregimens','Anyother1stlineadult/peadiatricregimen','Anyother1stlineAdultregimens','Anyother1stlinePaediatricregimens','Anyother2ndlineAdultregimens','Anyother2ndlinePaediatricregimens','Anyother3rdlineAdultregimens','AZT+DDI+LPV/r','NULL','Anyother3rdlinePaediatricregimens','AnyotherPMTCTregimensforWomen','ATV+DTG+RTV', '3TC+ATV+DTG+RTV','3TC+ATV+RTV','3TC+AZT+DRV+DTG+RTV','3TC+AZT+DTG+NVP','3TC+ABC+ATV+ZDV','3TC+ABC+DTG+EFV+TDF','3TC+ATV+NVP+RTV','ABC+DTG','ATV+FTC+RPV+RTV','ATV+LOP+RTV','FTC+TDF','LPV/r+TDF/3TC/EFV','NULL') THEN 'Other'
			WHEN CurrentRegimen in ('3TC+DTG+TDF','(3TC300mg)+(DTG50mg)+(TDF300mg)','(3TC300mg)+(Dolutegravir50mg)+(TDF300mg)','(3TC300mg)+(Dolutegravir50mg)+(Tenofovir300mg)','(3TC300mg)+(Dolutegravir100mg)+(TDF300mg)') THEN 'TDF+3TC+DTG'
			WHEN CurrentRegimen in ('3TC+ATV/r+TDF','3TC+ATV/r+PM11-TDF','(3TC300mg)+(ATV300mg)+(RTN100mg)+(TDF300mg)','(3TC300mg)+(RTN100mg)+(RTV100mg)+(TDF300mg)') THEN 'TDF+3TC+ATV/r'
			WHEN CurrentRegimen in ('3TC+ABC+EFV','(3TC60mg)+(ABC120mg)+(EFV200mg)','(3TC300mg)+(ABC600mg)+(EFV200mg)','(3TC300mg)+(ABC300mg)+(EFV200mg)') THEN 'ABC+3TC+EFV'
			WHEN CurrentRegimen in ('3TC+ABC+DTG','3TC+ABC+DRV','3TC+ABC+DTG+dtg1','3TC+ABC+dtg1','ABC/3TC+dtg1','(3TC300mg)+(ABC600mg)+(DTG50mg)','(3TC60mg)+(ABC120mg)+(DTG50mg)','(3TC300mg)+(ABC600mg)+(Dolutegravir50mg)','(3TC300mg)+(ABC600mg)+(Dolutegravir50mg)','(3TC60mg)+(ABC120mg)+(Dolutegravir50mg)','(3TC300mg)+(ABC300mg)+(Dolutegravir50mg)','(3TC300mg)+(ABC300mg)+(Dolutegravir50mg)')THEN 'ABC+3TC+DTG'
			WHEN CurrentRegimen in ( '3TC+ABC+ATV/r','3TC+ABC+ATV+RTV','300+3TC+3TC600+ABC+ATV/r') THEN 'ABC+3TC+ATV/r'
			WHEN CurrentRegimen in ('3TC+ABC+NVP','3TC+ABC+NVP') THEN 'ABC+3TC+NVP'
			WHEN CurrentRegimen ='3TC+ABC+AZT' THEN 'ABC+AZT+3TC'
			WHEN CurrentRegimen in ('3TC+ABC+LPV/r','(3TC300mg)+(ABC600mg)+(LPV200mg)+(RTV50mg)','(3TC60mg)+(ABC120mg)+(LPV100mg)+(RTV25mg)','(3TC150mg)+(ABC600mg)+(LPV200mg)+(RTV50mg)','(3TC60mg)+(ABC120mg)+(LPV40mg)+(RTV20mg)','(3TC60mg)+(ABC120mg)+(LPV100mg)+(RTV125mg)','(3TC60mg)+(ABC120mg)+(LPV200mg)+(RTV50mg)','(3TC60mg)+(ABC120mg)+(LPV80mg/ml)+(RTV100mg)+(RTV20mg/ml)','(3TC300mg)+(ABC600mg)+(RTV250mg)','(3TC300mg)+(ABC600mg)+(RTV250mg)','(3TC60mg)+(ABC120mg)+(RTV250mg)') THEN 'ABC+3TC+LPV/r'
			WHEN CurrentRegimen= '3TC+ABC+RAL' THEN 'ABC+3TC+RAL'
			WHEN CurrentRegimen='3TC+ABC+TDF' THEN 'ABC+3TC+TDF'
			WHEN CurrentRegimen in ('3TC+APV/r+TDF','3TC+ATV+TDF','(3TC300mg)+(ATV300mg)+(RTV100mg)+(TDF300mg)') THEN 'TDF+3TC+ATV/r'
			WHEN CurrentRegimen in ('3TC+ATV+AZT','3TC+ATV/r+AZT','3TC+ATV/r+ZDV','3TC+ATV/rTV+AZT','3TC+ATV+AZT+RTV','(3TC150mg)+(ATV300mg)+(AZT300mg)+(RTV100mg)','(3TC150mg)+(AZT300mg)+(RTV250mg)','(3TC)+(AZT)+(RTV)','(3TC150mg)+(ATV300mg)+(AZT300mg)+(RTN100mg)','(3TC150mg)+(AZT300mg)+(RTV100mg)') THEN 'AZT+3TC+ATV/r'
			WHEN CurrentRegimen in ('3TC+AZT+DRV+DTG','3TC+AZT+DTG','3TC+DTG+PMTCTHAART:AZT','3TC+AZT+dtg1')THEN 'AZT+3TC+DTG'
			WHEN CurrentRegimen in ('3TC+AZT+EFV','3TC+EFV+ZDV','') THEN 'AZT+3TC+EFV'
			WHEN CurrentRegimen in ('3TC+AZT+LPV/r','(3TC150mg)+(AZT300mg)+(LPV200mg)+(RTV50mg)','(3TC30mg)+(AZT60mg)+(LPV200mg)+(RTV50mg)','(3TC150mg)+(AZT300mg)+(LPV200mg)+(RTN50mg)','(3TC30mg)+(AZT60mg)+(LPV200mg)+(RTV50mg)','(3TC150mg)+(AZT300mg)+(LPV200mg)+(RTV50mg)','(3TC150mg)+(AZT300mg)+(LPV200mg)+(RTV50mg)') THEN 'AZT+3TC+LPV/r'
			WHEN CurrentRegimen in('3TC+AZT+NVP','3TC+NVP+ZDV') THEN 'AZT+3TC+NVP'
			WHEN CurrentRegimen in ('3TC+EFV+TDF','(3TC300mg)+(EFV400mg)+(TDF300mg)') THEN 'TDF+3TC+EFV'
			WHEN CurrentRegimen in ('3TC+LPV/r+TDF','(3TC300mg)+(LPV200mg)+(RTV50mg)+(TDF300mg)','(3TC300mg)+(LPV200mg)+(RTN50mg)+(TDF300mg)') THEN 'TDF+3TC+LPV/r'
			WHEN CurrentRegimen ='3TC+NVP+TDF' THEN 'TDF+3TC+NVP'
			WHEN CurrentRegimen ='3TC+TDF+ZDV' THEN 'TDF+3TC+AZT'
			WHEN CurrentRegimen in ('ABC+ATV+AZT+RTV','(3TC150mg)+(ABC300mg)+(ATV300mg)+(RTV100mg)') THEN 'ABC+3TC+ATV/r'
			WHEN CurrentRegimen in ('(NVP10mg/ml)','(NVP50mg/5ml)') THEN 'NVP'
			WHEN CurrentRegimen in ('(FTC300mg)+(TDF300mg)','(FTC200mg)+(TDF300mg)')THEN 'TDF+FTC'
			ELSE CurrentRegimen 
		END As LastRegimenClean
	from NDWH.Fact.FACTART ART
    INNER JOIN NDWH.Dim.DimAgeGroup b on ART.AgeGroupKey=b.AgeGroupKey
    INNER JOIN NDWH.Dim.DimPartner part ON art.PartnerKey = part.PartnerKey
    INNER JOIN NDWH.Dim.DimAgency a ON art.AgencyKey = a.AgencyKey
    INNER JOIN NDWH.Dim.DimFacility fac ON art.FacilityKey = fac.FacilityKey
    INNER JOIN NDWH.Dim.DimPatient pat ON art.PatientKey = pat.PatientKey
    LEFT JOIN NDWH.Fact.FactLatestObs obs ON obs.PatientKey = pat.PatientKey
    LEFT JOIN NDWH.Fact.FactViralLoads vl ON vl.PatientKey = pat.PatientKey 
    LEFT JOIN NDWH.Dim.DimDate as date on date.DateKey = art.StartARTDateKey 
	where IsTXCurr = 1
) H 
Group By 
    SiteCode, 
    FacilityName,
    County, 
    Subcounty, 
    PartnerName,
    AgencyName,CurrentRegimen, 
    StartRegimen, 
    Gender,
    StartARTMonth,
    StartARTYr,
    AsOfDate,
    Agegroup,
    DATIMAgeGroup,
    Gender,
    RegimenLine, 
    WeightBands,
    AgeBands, 
    LastRegimenClean,
    Lastregimen,
    CurrentVL
order by SiteCode;