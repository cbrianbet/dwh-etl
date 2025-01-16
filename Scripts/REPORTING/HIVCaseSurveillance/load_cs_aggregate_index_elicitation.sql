IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CSAggregateIndexEliciation]', N'U') IS NOT NULL 
	DROP TABLE  [HIVCaseSurveillance].[dbo].[CSAggregateIndexEliciation];

with initial_data as (
    select 
        elicitation.FactKey,
        elicitation.IndexPatientKey,
        elicitation.ContactPatientKey,
        confirm_date.[Date] as DateConfirmedHIVPositive,
        date_created.[Date] as DateElicitated,
        facility.FacilityName,
        facility.County,
        facility.SubCounty,
        partenr.PartnerName,
        agency.AgencyName,
        DATIMAgeGroup as Agegroup,
        cast(patient.EveronART as int) as EveronART,
        elicitation.Tested
    from  [NDWH].[dbo].[FactContactElicitation] as elicitation 
    left join NDWH.dbo.DimPatient as patient on patient.PatientKey = elicitation.IndexPatientKey --joining on IndexPatientKey to get details of the index client
    left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = elicitation.FacilityKey
    left join NDWH.dbo.DimPartner as partenr on partenr.PartnerKey = elicitation.PartnerKey
    left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = elicitation.AgencyKey
    left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.AgeGroupKey = elicitation.AgegroupKey
    left join NDWH.dbo.DimDate as confirm_date on confirm_date.DateKey = patient.DateConfirmedHIVPositiveKey
    left join NDWH.dbo.DimDate as date_created on date_created.DateKey = elicitation.DateCreatedKey
    where date_created.DateKey is not null
)
select
    eomonth(DateConfirmedHIVPositive) as CohortYearMonth,
    eomonth(DateElicitated) as DateELiciatedYearMonth,
    FacilityName,
    AgeGroup,
    County,
    SubCounty,
    AgencyName,
    PartnerName,
    count(FactKey) as NoElicited,
    sum(Tested) as NoTested,
    count(distinct case when EverOnART = 1 then IndexPatientKey end) as NoOfIndexLinkedToTX,
    count(distinct case when EverOnART = 0 then IndexPatientKey end) as NoOffIndexNotLinkedToTX
into HIVCaseSurveillance.dbo.CSAggregateIndexEliciation
from initial_data
group by
   eomonth(DateConfirmedHIVPositive),
   eomonth(DateElicitated),
   FacilityName,
   AgeGroup,
   County,
   SubCounty,
   AgencyName,
   PartnerName