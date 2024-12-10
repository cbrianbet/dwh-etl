IF OBJECT_ID(N'[REPORTING].[dbo].LineListOVCEligibilityAndEnrollments', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].LineListOVCEligibilityAndEnrollments
GO

SELECT 
	pat.PatientPKHash,
	pat.PatientIDHash,
	pat.NUPI,
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	pat.Gender, 
	g.DATIMAgeGroup,
	g.Age,
	enrld.Date as  OVCEnrollmentDate,
	rp.RelationshipWithPatient,
	EnrolledinCPIMS,
	CASE
	When EnrolledinCPIMS ='Yes' Then 'Yes'Else 'No'
	End as EnrolledinCPIMSCleaned,
	CPIMSUniqueIdentifierHash,
	PartnerOfferingOVCServices,
	OVCExitReason,
	exd.Date as ExitDate,
	FirstVL,
	fvd.Date as FirstVLDate,
	lastVL,
	lvd.Date as lastVLDate,
	ValidVLResultCategory1 as ValidVLResultCategory,
	validvl.Date as ValidVLDate,
	pat.IsTXCurr as TXCurr,
	CurrentRegimen,
	case 
	when CurrentRegimen like '%DTG%' then CurrentRegimen 
	else 'non DTG' 
	end as LastRegimen,
	onMMD,
	case 
		when ao.ARTOutcome is null then 'Others'
		else ao.ARTOutcomeDescription
	end as ARTOutcomeDescription,
	EligibleVL,
	HasValidVL as HasValidVL,
	ValidVLSup as VirallySuppressed,
	CAST(GETDATE() AS DATE) AS LoadDate,
	CASE 
		WHEN OVCExitReason is null and enrld.Date is not null then 1
		ELSE 0
	END AS isEnrolled
INTO [REPORTING].[dbo].LineListOVCEligibilityAndEnrollments
FROM [NDWH].[Fact].[FactART] art
LEFT JOIN [NDWH].[Fact].[FactOVC] it on it.PatientKey = art.PatientKey
LEFT JOIN NDWH.Dim.DimDate enrld on enrld.DateKey = it.OVCEnrollmentDateKey
LEFT JOIN NDWH.Dim.DimFacility f on f.FacilityKey = art.FacilityKey
LEFT JOIN NDWH.Dim.DimAgency a on a.AgencyKey = art.AgencyKey
LEFT JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = art.PatientKey
LEFT JOIN NDWH.Dim.DimPartner p on p.PartnerKey = art.PartnerKey
LEFT JOIN NDWH.[Fact].FactViralLoads vl on vl.PatientKey = art.PatientKey
LEFT JOIN NDWH.Dim.DimAgeGroup g on g.Age = AgeLastVisit
LEFT JOIN NDWH.Dim.DimDate exd on exd.DateKey = it.OVCExitDateKey
LEFT JOIN NDWH.Dim.DimDate lvd on lvd.DateKey = vl.LastVLDateKey
LEFT JOIN NDWH.Dim.DimDate fvd on fvd.DateKey = vl.FirstVLDateKey
LEFT JOIN NDWH.Dim.DimDate validvl on validvl.DateKey = vl.ValidVLDateKey
LEFT JOIN NDWH.Dim.DimRelationshipWithPatient rp on rp.RelationshipWithPatientKey = it.RelationshipWithPatientKey
LEFT JOIN NDWH.Dim.DimARTOutcome ao on ao.ARTOutcomeKey = art.ARTOutcomeKey
LEFT JOIN NDWH.Fact.FactLatestObs lo on lo.PatientKey = art.PatientKey
where art.AgeLastVisit between 0 and 17 and IsTXCurr = 1