IF OBJECT_ID(N'[REPORTING].[dbo].AggregateARTHistory', N'U') IS NOT NULL 		
	truncate table [REPORTING].[dbo].AggregateARTHistory
GO

Insert into [REPORTING].[dbo].AggregateARTHistory
select 
    facility.MFLCode,
    facility.FacilityName,
    facility.SubCounty,
    facility.County,
    partner.PartnerName,
    agency.AgencyName,
    patient.Gender,
    count(*) NumOfPatients,
	ART.IsTXCurr,
	asofdate.Date as AsofDate,
    age_group.DATIMAgeGroup
 
from NDWH.Fact.FactARTHistory as ART
left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = ART.FacilityKey
left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = ART.PartnerKey
left join NDWH.Dim.DimPatient as patient on patient.PatientKey = ART.PatientKey
left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = ART.AgencyKey
left join NDWH.Dim.DimAgeGroup as age_group on age_group.AgeGroupKey = DATEDIFF(YY,patient.DOB,ART.AsOfDateKey)
left join NDWH.Dim.DimDate as asofdate on asofdate.DateKey = ART.AsOfDateKey

group by 
    facility.MFLCode,
    facility.FacilityName,
    facility.SubCounty,
    facility.County,
    partner.PartnerName,
    agency.AgencyName,
    patient.Gender,
	ART.IsTXCurr,
    DATIMAgeGroup,
	asofdate.Date 



