IF OBJECT_ID(N'[NDWH].[dbo].[FactNCD]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactNCD]

GO

BEGIN

with ncd_source_data as (
    select 
        *
    from (
            select 
                distinct 
                case 
                    when value = 'Alzheimers Disease and other Dementias' then 'Alzheimer''s Disease and other Dementias' 
                    else value 
                end as value,
                PatientPKHash,
                PatientPK,               
                SiteCode,
                voided             
            from ODS.dbo.CT_AllergiesChronicIllness as chronic  
            cross apply STRING_SPLIT(chronic.ChronicIllness, '|')
            ) as chronic 
            pivot(
                count(value)
                for value IN (
                    "Alzheimers Disease and other Dementias",
                    "Alzheimer's Disease and other Dementias",
                    "Arthritis",
                    "Asthma",
                    "Cancer",
                    "Cardiovascular diseases",
                    "Chronic Hepatitis",
                    "Chronic Kidney Disease",
                    "Chronic Obstructive Pulmonary Disease(COPD)",
                    "Chronic Renal Failure",
                    "Cystic Fibrosis",
                    "Deafness and Hearing Impairment",
                    "Diabetes",
                    "Dyslipidemia",
                    "Endometriosis",
                    "Epilepsy",
                    "Glaucoma",
                    "Heart Disease",
                    "Hyperlipidaemia",
                    "Hypertension",
                    "Hypothyroidism",
                    "Mental illness",
                    "Multiple Sclerosis",
                    "Obesity",
                    "Osteoporosis",
                    "Sickle Cell Anaemia",
                    "Thyroid disease"
                )
            ) as pivot_table
    where voided = 0
),
MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency 
	from ODS.dbo.All_EMRSites 
),
visits_ordering as (
    select 
        PatientPKHash,
        PatientPK,               
        SiteCode,
        VisitDate,
        row_number() over (partition by PatientPK, Sitecode order by VisitDate desc) as rank
    from ODS.dbo.CT_AllergiesChronicIllness as chronic
    where chronic.voided = 0  
),
age_as_of_last_visit as (
    select 
        visits_ordering.PatientPKHash,
        visits_ordering.PatientPK,               
        visits_ordering.SiteCode,
        datediff(yy, patient.DOB, coalesce(visits_ordering.VisitDate, getdate() )) As  AgeLastVisit
    from visits_ordering
    inner join ODS.dbo.CT_Patient as patient on patient.PatientPKHash = visits_ordering.PatientPKHash 
	and patient.SiteCode = visits_ordering.SiteCode
    and patient.voided = 0
    where rank = 1 
),
hypertensives_ordering as (
    select 
        PatientPKHash,
        PatientPK,               
        SiteCode,
        VisitDate,
        ChronicIllness,
        row_number() over (partition by PatientPK, Sitecode order by VisitDate asc) as rank
    from ODS.dbo.CT_AllergiesChronicIllness as chronic
    where chronic.voided = 0 
        and ChronicIllness like '%Hypertension%' 
),
diabetes_ordering as (
    select 
        PatientPKHash,
        PatientPK,               
        SiteCode,
        VisitDate,
        ChronicIllness,
        row_number() over (partition by PatientPK, Sitecode order by VisitDate asc) as rank
    from ODS.dbo.CT_AllergiesChronicIllness as chronic
    where chronic.voided = 0 
        and ChronicIllness like '%Diabetes%' 
),
dyslipidemia_ordering as (
    select 
        PatientPKHash,
        PatientPK,               
        SiteCode,
        VisitDate,
        ChronicIllness,
        row_number() over (partition by PatientPK, Sitecode order by VisitDate asc) as rank
    from ODS.dbo.CT_AllergiesChronicIllness as chronic
    where chronic.voided = 0 
        and ChronicIllness like '%Dyslipidemia%' 
),
earliest_hpertension_recorded as (
    select 
        *
    from hypertensives_ordering
    where rank = 1
),
earliest_diabetes_recorded as (
    select 
        *
    from diabetes_ordering
    where rank = 1
),
earliest_dyslipidemia_recorded as (
    select 
        *
    from dyslipidemia_ordering
    where rank = 1
),
with_underlying_ncd_condition_indicators as (
    select 
        ncd_source_data.PatientPKHash,
        ncd_source_data.SiteCode,
        coalesce(ScreenedDiabetes, 0) as IsDiabeticAndScreenedDiabetes,
        coalesce(IsDiabetesControlledAtLastTest, 0) as IsDiabeticAndDiabetesControlledAtLastTest,
        coalesce(visit.ScreenedBPLastVisit,0) as IsHyperTensiveAndScreenedBPLastVisit,
        coalesce(visit.IsBPControlledAtLastVisit, 0) as IsHyperTensiveAndBPControlledAtLastVisit
    from ncd_source_data
    left join ODS.dbo.Intermediate_LatestDiabetesTests as latest_diabetes_test on latest_diabetes_test.PatientPKHash = ncd_source_data.PatientPKHash
        and latest_diabetes_test.SiteCode = ncd_source_data.SiteCode
        and ncd_source_data."Diabetes" = 1
    left join ODS.dbo.Intermediate_LastVisitDate as visit on visit.PatientPK = ncd_source_data.PatientPK
        and visit.SiteCode = ncd_source_data.SiteCode
        and ncd_source_data."Hypertension" = 1
)
select
    Factkey = IDENTITY(INT, 1, 1),
    patient.PatientKey,
    facility.FacilityKey,
    partner.PartnerKey,
    agency.AgencyKey,
    age_group.AgeGroupKey,
    ncd_source_data."Alzheimer's Disease and other Dementias",
    ncd_source_data."Arthritis",
    ncd_source_data."Asthma",
    ncd_source_data."Cancer",
    ncd_source_data."Cardiovascular diseases",
    ncd_source_data."Chronic Hepatitis",
    ncd_source_data."Chronic Kidney Disease",
    ncd_source_data."Chronic Obstructive Pulmonary Disease(COPD)",
    ncd_source_data."Chronic Renal Failure",
    ncd_source_data."Cystic Fibrosis",
    ncd_source_data."Deafness and Hearing Impairment",
    ncd_source_data."Diabetes",
    ncd_source_data."Dyslipidemia",
    ncd_source_data."Endometriosis",
    ncd_source_data."Epilepsy",
    ncd_source_data."Glaucoma",
    ncd_source_data."Heart Disease",
    ncd_source_data."Hyperlipidaemia",
    ncd_source_data."Hypertension",
    ncd_source_data."Hypothyroidism",
    ncd_source_data."Mental illness",
    ncd_source_data."Multiple Sclerosis",
    ncd_source_data."Obesity",
    ncd_source_data."Osteoporosis",
    ncd_source_data."Sickle Cell Anaemia",
    ncd_source_data."Thyroid disease",
    with_underlying_ncd_condition_indicators.IsDiabeticAndScreenedDiabetes,
    with_underlying_ncd_condition_indicators.IsDiabeticAndDiabetesControlledAtLastTest,
    with_underlying_ncd_condition_indicators.IsHyperTensiveAndScreenedBPLastVisit,
    with_underlying_ncd_condition_indicators.IsHyperTensiveAndBPControlledAtLastVisit,
    first_hypertension.DateKey as FirstHypertensionRecoredeDateKey,
    first_diabetes.DateKey as FirstDiabetesRecordedDateKey,
    first_dyslipidemia.DateKey as FirstDyslipidemiaRecordedDateKey
into NDWH.dbo.FactNCD
from ncd_source_data
left join with_underlying_ncd_condition_indicators on with_underlying_ncd_condition_indicators.PatientPKHash = ncd_source_data.PatientPKHash
    and with_underlying_ncd_condition_indicators.SiteCode = ncd_source_data.SiteCode
left join age_as_of_last_visit on age_as_of_last_visit.PatientPKHash = ncd_source_data.PatientPKHash
    and age_as_of_last_visit.SiteCode = ncd_source_data.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = ncd_source_data.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = ncd_source_data.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = age_as_of_last_visit.AgeLastVisit
left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = ncd_source_data.PatientPKHash
    and patient.SiteCode = ncd_source_data.SiteCode
left join earliest_hpertension_recorded on earliest_hpertension_recorded.PatientPKHash = ncd_source_data.PatientPKHash
    and earliest_hpertension_recorded.SiteCode = ncd_source_data.Sitecode
left join earliest_diabetes_recorded on earliest_diabetes_recorded.PatientPKHash = ncd_source_data.PatientPKHash
    and earliest_diabetes_recorded.SiteCode = ncd_source_data.SiteCode
left join earliest_dyslipidemia_recorded on earliest_dyslipidemia_recorded.PatientPKHash = ncd_source_data.PatientPKHash
    and earliest_dyslipidemia_recorded.SiteCode = ncd_source_data.SiteCode
left join NDWH.dbo.DimDate as first_hypertension on first_hypertension.Date = cast(earliest_hpertension_recorded.VisitDate as date)
left join NDWH.dbo.DimDate as first_diabetes on first_diabetes.Date = cast(earliest_diabetes_recorded.VisitDate as date)
left join NDWH.dbo.DimDate as first_dyslipidemia on first_dyslipidemia.Date = cast(earliest_dyslipidemia_recorded.VisitDate as date)

;


alter table NDWH.dbo.FactNCD add primary key(FactKey);

END

