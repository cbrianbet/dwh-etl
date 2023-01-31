Go
IF  EXISTS (SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateVLs]') AND type in (N'U'))
TRUNCATE TABLE [REPORTING].[dbo].[AggregateVLs]
GO

INSERT INTO REPORTING.dbo.AggregateVLs
SELECT DISTINCT
MFLCode,
f.FacilityName,
County,
SubCounty,
p.PartnerName as CTPartner,
a.AgencyName as CTAgency,
Gender,
age.DATIMAgeGroup as AgeGroup,
sum(CASE WHEN art.AgeLastVisit between 0 AND 18 THEN 1 ELSE 0 END) as number_children,
sum(CASE WHEN art.AgeLastVisit > 18 AND art.AgeLastVisit <= 120 THEN 1 ELSE 0 END) as number_adults,
count(pat.Nupi) as number_nupi

FROM NDWH.dbo.FactViralLoads vls
INNER join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey= vls.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = vls.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = vls.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = vls.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = vls.PartnerKey

WHERE pat.Nupi is not NULL AND pat.IsTXCurr = 1
GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, age.DATIMAgeGroup
