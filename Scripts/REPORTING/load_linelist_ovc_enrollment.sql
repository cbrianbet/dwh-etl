IF OBJECT_ID(N'[REPORTING].[dbo].LineListOVCEnrollments', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].LineListOVCEnrollments
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
	enrld.Date as OVCEnrollmentDate,
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
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO [REPORTING].[dbo].LineListOVCEnrollments
FROM [NDWH].[Fact].[FactOVC] it
LEFT JOIN NDWH.Dim.DimDate enrld on enrld.DateKey = it.OVCEnrollmentDateKey
LEFT JOIN NDWH.Dim.DimFacility f on f.FacilityKey = it.FacilityKey
LEFT JOIN NDWH.Dim.DimAgency a on a.AgencyKey = it.AgencyKey
LEFT JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = it.PatientKey
LEFT JOIN NDWH.Dim.DimPartner p on p.PartnerKey = it.PartnerKey
LEFT JOIN NDWH.[Fact].FactART art on art.PatientKey = it.PatientKey
LEFT JOIN NDWH.[Fact].FactViralLoads vl on vl.PatientKey = it.PatientKey
LEFT JOIN NDWH.Dim.DimAgeGroup g on g.Age = AgeLastVisit
LEFT JOIN NDWH.Dim.DimDate exd on exd.DateKey = it.OVCExitDateKey
LEFT JOIN NDWH.Dim.DimDate lvd on lvd.DateKey = vl.LastVLDateKey
LEFT JOIN NDWH.Dim.DimDate fvd on fvd.DateKey = vl.FirstVLDateKey
LEFT JOIN NDWH.Dim.DimDate validvl on validvl.DateKey = vl.ValidVLDateKey
LEFT JOIN NDWH.Dim.DimRelationshipWithPatient rp on rp.RelationshipWithPatientKey = it.RelationshipWithPatientKey
LEFT JOIN NDWH.Dim.DimARTOutcome ao on ao.ARTOutcomeKey = art.ARTOutcomeKey
LEFT JOIN NDWH.[Fact].FactLatestObs lo on lo.PatientKey = it.PatientKey
where art.AgeLastVisit between 0 and 17 and OVCExitReason is null and IsTXCurr = 1