IF OBJECT_ID(N'[ODS].[intermediate].[intermediate_LatestObs]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[intermediate].[intermediate_LatestObs];

BEGIN	
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency 
	from ODS.care.All_EMRSites 
),

latest_weight_height as (
select 
	PatientPKHash,
	SiteCode,
	Weight as LatestWeight,
	Height as LatestHeight
from ODS.[intermediate].Intermediate_LastestWeightHeight
),
age_of_last_visit as (
	select 
		last_encounter.PatientPK,
		last_encounter.SiteCode,
		datediff(yy, patient.DOB, last_encounter.LastEncounterDate) as AgeLastVisit
	from ODS.care.CT_Patient as patient
	left join ODS.[intermediate].Intermediate_LastPatientEncounter as last_encounter on last_encounter.PatientPK = patient.PatientPK
		and last_encounter.SiteCode = patient.SiteCode
	WHERE patient.VOIDED=0
),
latest_adherence as (
	select
		distinct  
		visits.SiteCode,
		visits.PatientPK,
		visits.Adherence
	from ODS.Care.CT_PatientVisits as visits
	inner join ODS.[intermediate].Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK 
		and visits.VisitDate = last_visit.LastVisitDate  
		and visits.VisitID = last_visit.visitID
		and AdherenceCategory in ('ARVAdherence', 'ART','ART|CTX','ARV','ARV Adherence')
	WHERE  VISITS.VOIDED=0
),
latest_differentiated_care as (
	select
		distinct visits.SiteCode,
		visits.PatientPK,
		visits.DifferentiatedCare
	from ODS.Care.CT_PatientVisits as visits
	inner join ODS.[intermediate].Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK 
		and visits.VisitDate = last_visit.LastVisitDate 
		and visits.VisitID = last_visit.visitID
		where DifferentiatedCare is not null AND  VISITS.VOIDED=0
),
latest_mmd as (
	select
		distinct PatientPK,
		SiteCode,
		case 
			when abs(datediff(day,LastEncounterDate, NextAppointmentDate)) <=89 then 0
			when abs(datediff(day,LastEncounterDate, NextAppointmentDate))  >= 90 THEN  1 
		end as onMMD
	from ODS.[intermediate].Intermediate_LastPatientEncounter
),
lastest_stability_assessment as (
	select
		distinct  
		visits.SiteCode,
		visits.PatientPK,
		visits.StabilityAssessment
	from ODS.Care.CT_PatientVisits as visits
	inner join ODS.[intermediate].Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK 
		and visits.VisitDate = last_visit.LastVisitDate  
		and visits.VisitID = last_visit.visitID
	WHERE  VISITS.VOIDED=0
),
latest_pregnancy as (
	select
		distinct visits.PatientPK, 
		visits.SiteCode,
		visits.Pregnant
	from ODS.Care.CT_PatientVisits as visits
	inner join ODS.[intermediate].Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK 
		and visits.VisitDate = last_visit.LastVisitDate
		and visits.VisitID = last_visit.visitID
	    and Pregnant is not null
		WHERE  VISITS.VOIDED=0
),
latest_fp_method as (
	select
		distinct visits.PatientPK, 
		visits.SiteCode,
		visits.FamilyPlanningMethod
	from ODS.Care.CT_PatientVisits as visits
	inner join ODS.[intermediate].Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK 
		and visits.VisitDate = last_visit.LastVisitDate
		and visits.VisitID = last_visit.visitID
	    and FamilyPlanningMethod is not null
		and FamilyPlanningMethod <> ''
	WHERE  VISITS.VOIDED=0
),
latest_breastfeeding as (
	select
		distinct visits.PatientPK,  
		visits.SiteCode,
		visits.Breastfeeding,
        visits.LMP,
        visits.GestationAge
	from ODS.Care.CT_PatientVisits as visits
	inner join ODS.[intermediate].Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK 
		and visits.VisitDate = last_visit.LastVisitDate
		and visits.VisitID = last_visit.visitID
	    and Breastfeeding is not null
		and Breastfeeding <> ''
	WHERE  VISITS.VOIDED=0
),
latest_Who as (
	select
		distinct visits.PatientPK, 
		visits.WhoStage,
        visits.SiteCode
	from ODS.Care.CT_PatientVisits as visits
	inner join ODS.[intermediate].Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK 
		and visits.VisitDate = last_visit.LastVisitDate
		and visits.VisitID = last_visit.visitID
	WHERE  VISITS.VOIDED=0
 ),
 last_TBScreening as (

	SELECT  row_number() OVER (PARTITION BY visits.SiteCode,visits.PatientPK ORDER BY VisitDate DESC) AS NUM,
		visits.PatientPK, 
		visits.TBScreening,
        visits.SiteCode,
		visits.VisitDate,
		visits.VisitID,
        visits.OnIPT,
        visits.StartIPT,
        visits.EverOnIPT
	from ODS.Care.CT_IPT as visits
	WHERE  VISITS.VOIDED=0
	),
 latest_TBScreening as (
	select
		distinct Screening.PatientPK, 
		Screening.TBScreening,
        Screening.OnIPT,
        Screening.StartIPT,
        Screening.EverOnIPT,
        Screening.SiteCode
	from last_TBScreening as Screening
	inner join ODS.[intermediate].Intermediate_LastVisitDate as last_visit on Screening.SiteCode = last_visit.SiteCode 
		and Screening.PatientPK = last_visit.PatientPK 
		and Screening.VisitDate = last_visit.LastVisitDate
		and Screening.VisitID = last_visit.visitID
	where 	Screening.NUM=1
 ),
 eac as (
    SELECT 
        Row_number()
                OVER (
                Partition BY Sitecode, Patientpk
                ORDER BY Visitdate DESC) as num,
        Patientpkhash,
        Sitecode,
        Patientpk,
        Visitdate
    FROM Ods.Care.Ct_enhancedadherencecounselling 
),
latest_EAC_session as (
    select 
        Eac1.Patientpkhash,
        Eac1.Sitecode,
        Eac1.Patientpk,
        VisitDate
    from eac AS Eac1
    where num = 1
)
	select 
		patient.PatientPKHash,
        patient.PatientPK,
		patient.SiteCode,
		latest_weight_height.LatestHeight,
		latest_weight_height.LatestWeight,
		age_of_last_visit.AgeLastVisit,
		latest_adherence.Adherence,
		latest_differentiated_care.DifferentiatedCare,
		latest_mmd.onMMD,
		lastest_stability_assessment.StabilityAssessment,
		latest_pregnancy.Pregnant,
        latest_breastfeeding.Breastfeeding,
        latest_breastfeeding.LMP,
        latest_breastfeeding.GestationAge,
        latest_Who.WhoStage,
        latest_TBScreening.TBScreening,
        latest_TBScreening.OnIPT,
        latest_TBScreening.StartIPT,
        latest_TBScreening.EverOnIPT,
		latest_EAC_session.VisitDate as LastEACSessionDate,
        cast(getdate() as date) as LoadDate
        into ODS.[intermediate].intermediate_LatestObs
	from ODS.Care.CT_Patient as patient
	left join latest_weight_height on latest_weight_height.PatientPKHash = patient.PatientPKHash
		and latest_weight_height.SiteCode = patient.SiteCode
	left join age_of_last_visit on age_of_last_visit.PatientPK = patient.PatientPK
		and age_of_last_visit.SiteCode = patient.SiteCode
	left join latest_adherence on latest_adherence.PatientPK = patient.PatientPK
		and latest_adherence.SiteCode = patient.SiteCode
	left join latest_differentiated_care on latest_differentiated_care.PatientPK = patient.PatientPK
		and latest_differentiated_care.SiteCode = patient.SiteCode
	left join latest_mmd on latest_mmd.PatientPK = patient.PatientPK
		and latest_mmd.SiteCode = patient.SiteCode
	left join lastest_stability_assessment on lastest_stability_assessment.PatientPK = patient.PatientPK
		and lastest_stability_assessment.SiteCode = patient.SiteCode
	left join latest_pregnancy on latest_pregnancy.PatientPK = patient.PatientPK
		and latest_pregnancy.SiteCode = patient.SiteCode
	left join latest_fp_method on latest_fp_method.PatientPK = patient.PatientPK
		and latest_fp_method.SiteCode = patient.SiteCode
    left join latest_breastfeeding on latest_breastfeeding.PatientPK=patient.PatientPK
        and latest_breastfeeding.Sitecode=patient.SiteCode
    left join latest_Who on latest_Who.PatientPK=patient.PatientPK and latest_Who.Sitecode=patient.Sitecode
    left join latest_TBScreening on latest_TBScreening.PatientPK = patient.PatientPK and latest_TBScreening.SiteCode = patient.SiteCode
    left join latest_EAC_session on latest_EAC_session.PatientPK = patient.PatientPK and latest_EAC_session.SiteCode = patient.SiteCode
	Where patient.voided = 0

END