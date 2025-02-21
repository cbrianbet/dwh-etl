IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CSAggregateIndexEliciationCascade]', N'U') IS NOT NULL 
	DROP TABLE  [HIVCaseSurveillance].[dbo].[CSAggregateIndexEliciationCascade];

select
	eomonth(confirm_date.Date) as CohortYearMonth,
	partner.PartnerName,
	agency.AgencyName,
	patient.Gender,
	agegroup.DATIMAgeGroup as AgeGroup,
    fac.FacilityName,
    fac.County,
    fac.SubCounty,
 	count(distinct IndexPatientKey) as count_index_clients,
	count(distinct ContactPatientKey) + sum(case when ContactPatientKey is null then 1 else 0 end) as count_elicited, ---making sure we count unique contacts, for cases without contactPatientkey we assume a unique client
	count(distinct case when ContactHIVStatusAtElicitation = 'Positive' and ContactHIVStatusAfterTesting <> 'Negative'  then ContactPatientKey end) as KnownPositiveAtElicitation,
	count(distinct case when ContactHIVStatusAfterTesting = 'Positive' and ContactHIVStatusAtElicitation <> 'Positive' then ContactPatientKey end) as NewPositives,
	count(distinct case when ContactHIVStatusAfterTesting = 'Negative' then ContactPatientKey end) as TestedNegative,
 	sum(case when ContactHIVStatusAfterTesting is null then 1 else 0 end) as ContactsNotTested
into [HIVCaseSurveillance].[dbo].[CSAggregateIndexEliciationCascade]
from  [NDWH].[Fact].[FactContactElicitation] as elicitation
left join NDWH.Dim.DimPatient as patient on patient.PatientKey = elicitation.IndexPatientKey
left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = elicitation.PartnerKey
left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = elicitation.AgencyKey
left join NDWH.Dim.DimDate as confirm_date on confirm_date.DateKey = patient.DateConfirmedHIVPositiveKey
left join NDWH.Dim.DimAgeGroup as agegroup on agegroup.AgeGroupKey = elicitation.AgeGroupKey 
left join NDWH.Dim.DimFacility as fac on fac.FacilityKey = elicitation.FacilityKey 
where patient.DateConfirmedHIVPositiveKey is not null
group by 
	eomonth(confirm_date.Date),
	partner.PartnerName,
	agency.AgencyName,
	patient.Gender,
	agegroup.DATIMAgeGroup,
    fac.FacilityName,
    fac.County,
    fac.SubCounty
;