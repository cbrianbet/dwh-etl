IF OBJECT_ID(N'[REPORTING].[dbo].AggregateOVCCount', N'U') IS NOT NULL 	
	drop TABLE [REPORTING].[dbo].AggregateOVCCount
GO

SELECT 
    MFLCode,
    f.FacilityName,
    County,
    SubCounty,
    p.PartnerName,
    a.AgencyName,
    Gender, 
    g.DATIMAgeGroup,
    pat.IsTXCurr as TXCurr,
    case 
	    when ao.ARTOutcome is null then 'Others'
		else ao.ARTOutcomeDescription 
	end as ARTOutcomeDescription,
    EOMONTH(enrld.Date) as AsofDate,
    SUM(CASE WHEN CPIMSUniqueIdentifierHash IS NOT NULL THEN 1 ELSE 0 END) AS CPIMSUniqueIdentifierCount,
    count(*) as OVCElligiblePatientCount,
    CAST(GETDATE() AS DATE) AS LoadDate 
    into [REPORTING].[dbo].AggregateOVCCount
FROM [NDWH].[Fact].[FactOVC] it
INNER JOIN NDWH.Dim.DimDate enrld on enrld.DateKey = it.OVCEnrollmentDateKey
INNER join NDWH.Dim.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.Fact.FactART art on art.PatientKey = it.PatientKey
INNER JOIN NDWH.Dim.DimARTOutcome ao on ao.ARTOutcomeKey = art.ARTOutcomeKey
LEFT join NDWH.Dim.DimAgeGroup g on g.Age = art.AgeLastVisit
where art.AgeLastVisit between 0 and 17 and OVCExitReason is null and pat.IsTXCurr = 1
GROUP BY 
	MFLCode,
	f.FacilityName,
	County,
	Subcounty,
	p.PartnerName,
	a.AgencyName
	,Gender,
	g.DATIMAgeGroup,
	pat.IsTXCurr,
	ao.ARTOutcome,
    EOMONTH(enrld.Date),
	case 
		when ao.ARTOutcome is null then 'Others'
		else ao.ARTOutcomeDescription
	end