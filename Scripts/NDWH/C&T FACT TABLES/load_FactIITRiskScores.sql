
IF OBJECT_ID(N'[NDWH].[fact].[FactIITRiskScores]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[fact].[FactIITRiskScores];
BEGIN


with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
        SDP_Agency as Agency
	from ODS.Care.All_EMRSites 
),
iit_risk_scores_ordering as (
    select
        scores.PatientPK,
        scores.PatientPKHash,
        scores.SiteCode,
        cast(scores.RiskEvaluationDate as date) as RiskEvaluationDate,
        scores.RiskScore,
        case 
            when Try_cast(scores.RiskScore as decimal(9,8)) >= 0.0 and scores.RiskScore <= 0.04587387 then 'Low'
            when Try_cast(scores.RiskScore as decimal(9,9)) >= 0.04587388 and scores.RiskScore <= 0.1458252 then 'Medium'
            when Try_cast(scores.RiskScore as decimal(9, 8)) >= 0.1458253  and scores.RiskScore <= 1.0 then 'High'
        end as RiskCategory,
        row_number() over (partition by scores.PatientPK, scores.SiteCode order by scores.RiskEvaluationDate desc) as rank
    from ODS.Care.CT_IITRiskScores as scores 
    left join ODS.Care.CT_Patient as patient on patient.PatientPK = scores.PatientPK
        and patient.SiteCode = scores.PatientPK
),
appointments_from_last_visit as (
    select 
        lastencounter.PatientPK,
        lastencounter.SiteCode,
        lastencounter.LastEncounterDate as lastencounterDate,
        lastencounter.NextAppointmentDate as NextAppointment
    from ODS.Intermediate.Intermediate_LastPatientEncounter as lastencounter
),
active_clients as (
    select 
        PatientPk,
        SiteCode
    from ODS.Intermediate.Intermediate_ARTOutcomes
    where ARTOutcome = 'V'
)
select 
    Factkey = IDENTITY(INT, 1, 1),
    patient.PatientKey,
    facility.FacilityKey,
    partner.PartnerKey,
    agency.AgencyKey,
    agegroup.AgeGroupKey,
    evaluation.DateKey as RiskEvaluationDateKey,
    appointment.DateKey as LastVisitAppointmentGivenDateKey,
    RiskScore as LatestRiskScore,
    RiskCategory as LatestRiskCategory,
    art.ARTOutcomeKey
	into NDWH.dbo.FactIITRiskScores
from iit_risk_scores_ordering as risk_scores
left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = risk_scores.PatientPKHash
    and patient.SiteCode = risk_scores.SiteCode
left join NDWH.Fact.FACTART as art on art.PatientKey=Patient.Patientkey
left join NDWH.Dim.DimARTOutcome as outcome on outcome.ARTOutcomeKey=art.ARTOutcomeKey
left join NDWH.Dim.DimFacility as facility on facility.MFLCode = risk_scores.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = risk_scores.SiteCode
left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency 
left join NDWH.Dim.DimDate as evaluation on evaluation.Date = risk_scores.RiskEvaluationDate
left join NDWh.Dim.DimAgeGroup as agegroup on agegroup.Age = datediff(yy, patient.DOB, risk_scores.RiskEvaluationDate)
left join appointments_from_last_visit on appointments_from_last_visit.PatientPK = risk_scores.PatientPK
    and appointments_from_last_visit.SiteCode = risk_scores.SiteCode
left join NDWH.Dim.DimDate as appointment on appointment.Date = appointments_from_last_visit.NextAppointment
where rank = 1 and patient.voided = 0

alter table NDWH.dbo.FactIITRiskScores add primary key(FactKey)

END
