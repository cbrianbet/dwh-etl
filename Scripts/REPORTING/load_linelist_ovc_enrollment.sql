IF OBJECT_ID(N'[REPORTING].[dbo].LineListOVCEnrollments', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].LineListOVCEnrollments
GO

SELECT 
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	art.Gender, 
	g.DATIMAgeGroup,
	enrld.Date as  OVCEnrollmentDate,
	rp.RelationshipWithPatient,
	EnrolledinCPIMS,
	CASE
	When EnrolledinCPIMS ='Yes' Then 'Yes'Else 'No'
	End as EnrolledinCPIMSCleaned,
	CPIMSUniqueIdentifier,
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
	ao.ARTOutcome,
	EligibleVL,
	HasValidVL as HasValidVL,
	ValidVLSup as VirallySuppressed,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO [REPORTING].[dbo].LineListOVCEnrollments
FROM [NDWH].[dbo].[FactOVC] it
INNER JOIN NDWH.dbo.DimDate enrld on enrld.DateKey = it.OVCEnrollmentDateKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.dbo.FactART art on art.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.FactViralLoads vl on vl.PatientKey = it.PatientKey
INNER join NDWH.dbo.DimAgeGroup g on g.Age = AgeLastVisit
LEFT JOIN NDWH.dbo.DimDate exd on exd.DateKey = it.OVCExitDateKey
LEFT JOIN NDWH.dbo.DimDate lvd on lvd.DateKey = vl.LastVLDateKey
LEFT JOIN NDWH.dbo.DimDate fvd on fvd.DateKey = vl.FirstVLDateKey
LEFT JOIN NDWH.dbo.DimDate validvl on validvl.DateKey = vl.ValidVLDateKey
LEFT JOIN NDWH.dbo.DimRelationshipWithPatient rp on rp.RelationshipWithPatientKey = it.RelationshipWithPatientKey
INNER JOIN NDWH.dbo.DimARTOutcome ao on ao.ARTOutcomeKey = art.ARTOutcomeKey
LEFT JOIN NDWH.dbo.FactLatestObs lo on lo.PatientKey = it.PatientKey
where art.AgeLastVisit between 0 and 17 and OVCExitReason is null