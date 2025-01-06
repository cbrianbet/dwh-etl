IF OBJECT_ID(N'[REPORTING].[dbo].[LineListViralLoad]', N'U') IS NOT NULL 			
	drop  TABLE [REPORTING].[dbo].[LineListViralLoad]
GO

SELECT DISTINCT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	Gender,
	age.DATIMAgeGroup as AgeGroup,
	pat.PatientPKHash,
	pat.PatientIDHash,
	LatestVL1,
	vl.LatestVLDate1Key,
	LatestVL2,
	vl.LatestVLDate2Key,
	LatestVL3,
	vl.LatestVLDate3Key,
	PBFW_ValidVL,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO REPORTING.dbo.LineListViralLoad
FROM NDWH.Fact.FactViralLoads vl
INNER join NDWH.Dim.DimAgeGroup age on age.AgeGroupKey=vl.AgeGroupKey
INNER join NDWH.Dim.DimFacility f on f.FacilityKey = vl.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = vl.AgencyKey
INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = vl.PatientKey
INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = vl.PartnerKey

GO
