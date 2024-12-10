IF OBJECT_ID(N'[REPORTING].[dbo].[LinelistIITRiskScores]', N'U') IS NOT NULL 
	DROP TABLE [REPORTING].[dbo].[LinelistIITRiskScores];
BEGIN

select 
    patient.PatientIDHash,
    patient.PatientPKHash,
    patient.NUPI,
    patient.Gender,
    agegroup.DATIMAgeGroup,
    agegroup.Age,
    facility.MFLCode,
    facility.FacilityName,
    facility.County,
    facility.SubCounty,
    partner.PartnerName,
    agency.AgencyName,
    evaluation.Date as RiskEvaluationDate,    
    appointment.Date as LastVisitAppointmentGivenDate,
    scores.LatestRiskScore,
    scores.LatestRiskCategory
into REPORTING.dbo.LinelistIITRiskScores
from NDWH.Fact.FactIITRiskScores as scores
left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = scores.FacilityKey
left join NDWH.Dim.DimPatient as patient on patient.PatientKey = scores.PatientKey
left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = scores.AgencyKey
left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = scores.PartnerKey
left join NDWH.Dim.DimAgeGroup as agegroup on agegroup.AgeGroupKey = scores.AgeGroupKey
left join NDWH.Dim.DimDate as appointment on appointment.DateKey = scores.LastVisitAppointmentGivenDateKey
left join NDWH.Dim.DimDate as evaluation on evaluation.DateKey = scores.RiskEvaluationDateKey

END
