IF OBJECT_ID(N'[REPORTING].[dbo].AggregateTXCurr', N'U') IS NOT NULL 		
	drop table [REPORTING].[dbo].AggregateTXCurr
GO


select 
    facility.MFLCode,
    facility.FacilityName,
    facility.SubCounty,
    facility.County,
    partner.PartnerName,
    agency.AgencyName,
    patient.Gender,
    age_group.DATIMAgeGroup,
    count(*) as CountClientsTXCur,
    CAST(GETDATE() AS DATE) AS LoadDate   
  into [REPORTING].[dbo].AggregateTXCurr
from NDWH.Fact.FactArt as art
left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = art.FacilityKey
left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = art.PartnerKey
left join NDWH.Dim.DimPatient as patient on patient.PatientKey = art.PatientKey
left join NDWH.Dim.DimAgeGroup as age_group on age_group.AgeGroupKey = art.AgeGroupKey
left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = art.AgencyKey
left join NDWH.Dim.DimARTOutcome as outcome on outcome.ARTOutcomeKey = art.ARTOutcomeKey
where outcome.ARTOutcomeDescription = 'Active'
group by 
    facility.MFLCode,
    facility.FacilityName,
    facility.SubCounty,
    facility.County,
    partner.PartnerName,
    agency.AgencyName,
    patient.Gender,
    age_group.DATIMAgeGroup
