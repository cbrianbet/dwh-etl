IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CSAggregateIndexEliciation]', N'U') IS NOT NULL 
	DROP TABLE  [HIVCaseSurveillance].[dbo].[CSAggregateIndexEliciation];

with initial_data as (
    select 
        elicitation.FactKey,
        elicitation.IndexPatientKey,
        elicitation.ContactPatientKey,
        patient.Gender,
        confirm_date.[Date] as DateConfirmedHIVPositive,
        date_created.[Date] as DateElicitated,
        facility.FacilityName,
        facility.County,
        facility.SubCounty,
        partenr.PartnerName,
        agency.AgencyName,
        DATIMAgeGroup as AgeGroup,
        patient.Gender,
        cast(patient.EveronART as int) as EveronART,
        elicitation.Tested
    from  [NDWH].[Fact].[FactContactElicitation] as elicitation 
    left join NDWH.Dim.DimPatient as patient on patient.PatientKey = elicitation.IndexPatientKey --joining on IndexPatientKey to get details of the index client
    left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = elicitation.FacilityKey
    left join NDWH.Dim.DimPartner as partenr on partenr.PartnerKey = elicitation.PartnerKey
    left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = elicitation.AgencyKey
    left join NDWH.Dim.DimAgeGroup as agegroup on agegroup.AgeGroupKey = elicitation.AgegroupKey
    left join NDWH.Dim.DimDate as confirm_date on confirm_date.DateKey = patient.DateConfirmedHIVPositiveKey
    left join NDWH.Dim.DimDate as date_created on date_created.DateKey = elicitation.DateCreatedKey
    where date_created.DateKey is not null
)
select
    eomonth(DateConfirmedHIVPositive) as CohortYearMonth,
    eomonth(DateElicitated) as DateELiciatedYearMonth,
    FacilityName,
    AgeGroup,
    Gender,
    County,
    SubCounty,
    AgencyName,
    PartnerName,
    Gender,
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
   Gender,
   County,
   SubCounty,
   AgencyName,
   PartnerName,
   Gender