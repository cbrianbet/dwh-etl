
IF OBJECT_ID(N'[NDWH].[Fact].[FactTPT]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[Fact].[FactTPT];
BEGIN
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency  as Agency
	from ODS.Care.All_EMRSites
),
distinct_patients_date_started_TB_treatment as (
    select 
        distinct PatientPk,
		PatientPKHash,
        SiteCode,
		null As StartTBTreatmentDate
    from  ODS.Care.CT_IPT
union
    select 
        distinct PatientPK,
		PatientPKHash,
        SiteCode,
        cast(TBRxStartDate as Date) as StartTBTreatmentDate 
    from ODS.Care.CT_IPT
    where TBRxStartDate is not null
)
,
patient_TB_Diagnosis as (
    select 
        PatientPk,
        SiteCode, 
        min(ReportedbyDate) as TBDiagnosisDate
    from ODS.Care.CT_PatientLabs 
    where (TestName like '%TB%' or TestName like '%Sput%' or TestName like '%TB%' or TestName like '%Tuber%')
    and  TestName <> 'SputumGramStain'
    and (TestResult like '%Positive%' or TestResult like '%HIGH%' or TestResult like '%+%')
    group by  
        PatientID,
        PatientPk,
        SiteCode
),
ipt_visits_ordered as (
 SELECT
                    *
                FROM(   
					select 
						row_number() over (partition by  SiteCode, PatientPK order by VisitDate desc) as rank,
						SiteCode,
						PatientPK,
						OnIPT,
						OnTBDrugs
					from ODS.Care.CT_IPT) y
					where rank = 1
),
combined_ipt_data as (
    select
       distinct_patients.PatientPK,
       patient.PatientPKHash,
       distinct_patients.SiteCode,
       distinct_patients.StartTBTreatmentDate,
       patient_TB_Diagnosis.TBDiagnosisDate,
       latest_visit.OnIPT,
        case 
            when latest_visit.OnTBDrugs = 'Yes' then 1
            else 0
        end as hasTB,
    datediff(yy, patient.DOB, last_encounter.LastEncounterDate) as AgeLastVisit
    from distinct_patients_date_started_TB_treatment distinct_patients
    left join patient_TB_Diagnosis on 
	patient_TB_Diagnosis.SiteCode = distinct_patients.SiteCode and
	patient_TB_Diagnosis.PatientPk = distinct_patients.PatientPK

    left join ipt_visits_ordered latest_visit on 
	latest_visit.SiteCode = distinct_patients.SiteCode and
	latest_visit.PatientPK = distinct_patients.PatientPK

    left join ODS.[Intermediate].Intermediate_LastPatientEncounter as last_encounter on 
	last_encounter.SiteCode = distinct_patients.SiteCode and
	last_encounter.PatientPK = distinct_patients.PatientPK

    left join ODS.[Care].CT_Patient as patient on
	patient.SiteCode = distinct_patients.SiteCode and
	patient.PatientPK = distinct_patients.PatientPK

)
select 
    patient.PatientKey,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    age_group.AgeGroupKey,
    tb_start_treatment.DateKey as StartTBTreatmentDateKey,
    tb_diagnosis.DateKey as TBDiagnosisDateKey,
    combined_ipt_data.OnIPT,
    combined_ipt_data.hasTB,
    cast(getdate() as date) as LoadDate
into NDWH.Fact.FactTPT
from combined_ipt_data
left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = combined_ipt_data.PatientPKHash
    and patient.SiteCode = combined_ipt_data.SiteCode
left join NDWH.Dim.DimFacility as facility on facility.MFLCode = combined_ipt_data.SiteCode
left join NDWH.Dim.DimDate as tb_start_treatment on tb_start_treatment.Date = combined_ipt_data.StartTBTreatmentDate
left join NDWH.Dim.DimDate as tb_diagnosis on tb_diagnosis.Date = combined_ipt_data.TBDiagnosisDate
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = combined_ipt_data.SiteCode
left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = combined_ipt_data.AgeLastVisit
WHERE patient.voided =0;
 
END

 