IF OBJECT_ID(N'HIVCaseSurveillance.dbo.CsAggregateAlcoholSexSTIRiskFactors', N'U') IS NOT NULL 
	DROP TABLE HIVCaseSurveillance.dbo.CsAggregateAlcoholSexSTIRiskFactors;

with cases as (
  select 
    art.PatientKey,
    art.FacilityKey,
    art.AgeGroupKey,
    art.PartnerKey,
    art.AgencyKey,
    pat.Gender,
    confirm_date.[Date] as DateConfirmedHIVPos
  from NDWH.dbo.FactART as art 
  left join NDWH.dbo.DimPatient as pat on pat.PatientKey = art.PatientKey
  left join NDWH.dbo.DimDate as confirm_date on confirm_date.DateKey = pat.DateConfirmedHIVPositiveKey
),
eligibility_indicators as (
  select
    row_number() over (partition by eligibility_data.PatientKey order by eligibilitydate.date desc) as rank,
    eligibility_data.PatientKey,
    eligibilitydate.Date as ELigibilityVisitDate,
    case 
      when AlcoholSex in ('Always', 'Sometimes') then 1
      else 0
    end as SexwithAlcohoDrugs,
    case 
      when CurrentlyHasSTI = 'YES' then 1 
      else 0 
    end as CurrentlyHasSTI
from NDWH.dbo.FactHTSEligibilityextract as eligibility_data
left join NDWH.dbo.DimDate as eligibilitydate on eligibilitydate.DateKey = eligibility_data.VisitDateKey
),
latest_eligibility_indicators_per_patient as (
  select 
    *
  from eligibility_indicators
  where rank = 1
),
joined_data as (
  select 
    cases.PatientKey,
    cases.FacilityKey,
    cases.AgeGroupKey,
    cases.PartnerKey,
    cases.AgencyKey,
    cases.Gender,
    cases.DateConfirmedHIVPos,
    eligibility.ELigibilityVisitDate,
    SexwithAlcohoDrugs,
    CurrentlyHasSTI
  from cases
  inner join latest_eligibility_indicators_per_patient as eligibility on eligibility.PatientKey = cases.PatientKey
)
select 
  eomonth(confirm_date.Date) as CohortYearMonth,
  facility.FacilityName,
  facility.County,
  facility.SubCounty,
  partner.PartnerName,
  agency.AgencyName,
  count(joined_data.PatientKey) as NoOfCases,
  sum(SexwithAlcohoDrugs) HasSexwithAlcohoDrugs,
  sum(CurrentlyHasSTI) as CurrentlyHasSTI
into HIVCaseSurveillance.dbo.CsAggregateAlcoholSexSTIRiskFactors
from joined_data
left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = joined_data.PartnerKey
left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = joined_data.AgencyKey
left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.AgeGroupKey = joined_data.AgeGroupKey
left join NDWH.dbo.DimPatient as patient on patient.PatientKey = joined_data.PatientKey
left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = joined_data.FacilityKey
left join NDWH.dbo.DimDate as confirm_date on confirm_date.DateKey = patient.DateConfirmedHIVPositiveKey
group by 
    eomonth(confirm_date.Date),
    facility.FacilityName,
    facility.County,
    facility.SubCounty,
    partner.PartnerName,
    agency.AgencyName; 