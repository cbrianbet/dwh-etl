IF OBJECT_ID(N'[NDWH].[Fact].[FactOTZ]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[Fact].[FactOTZ];
BEGIN
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency
	from ODS.Care.All_EMRSites 
),
otz_and_last_encounter_combined as (
select
    otz.PatientIDHash,
    otz.PatientPKHash,
    otz.SiteCode,
	otz.OTZEnrollmentDate,
	otz.LastVisitDate,
	otz.TransferInStatus,
	otz.TransitionAttritionReason,
	otz.ModulesPreviouslyCovered,
	otz.ModulesCompletedToday_OTZ_Orientation,
	otz.ModulesCompletedToday_OTZ_Participation,
	otz.ModulesCompletedToday_OTZ_Leadership,
	otz.ModulesCompletedToday_OTZ_MakingDecisions,
	otz.ModulesCompletedToday_OTZ_Transition,
	otz.ModulesCompletedToday_OTZ_TreatmentLiteracy,
	otz.ModulesCompletedToday_OTZ_SRH,
	otz.ModulesCompletedToday_OTZ_Beyond,
    datediff(yy, patient.DOB, coalesce(last_encounter.LastEncounterDate, getdate() )) As  AgeLastVisit,
	 cast(getdate() as date) as LoadDate
from ODS.[Intermediate].Intermediate_LastOTZVisit as otz
left join ODS.[Intermediate].Intermediate_LastPatientEncounter as last_encounter on last_encounter.PatientPKHash = otz.PatientPKHash 
		and last_encounter.SiteCode = otz.SiteCode
left join ODS.Care.CT_Patient as patient on patient.PatientPKHash = otz.PatientPKHash 
	and patient.SiteCode = otz.SiteCode
)
select 
	Factkey = IDENTITY(INT, 1, 1),
    patient.PatientKey,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    age_group.AgeGroupKey,
    otz_enrollment.DateKey as OTZEnrollmentDateKey,
    last_visit.DateKey as LastVisitDateKey,
	otz_and_last_encounter_combined.TransitionAttritionReason,
    otz_and_last_encounter_combined.TransferInStatus,
	otz_and_last_encounter_combined.ModulesPreviouslyCovered,
	otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_Orientation,
	otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_Participation,
	otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_Leadership,
	otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_MakingDecisions,
	otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_Transition,
	otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_TreatmentLiteracy,
	otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_SRH,
	otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_Beyond,
	cast(getdate() as date) as LoadDate
into NDWH.Fact.FactOTZ
from otz_and_last_encounter_combined
left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = otz_and_last_encounter_combined.PatientPKHash 
    and patient.SiteCode = otz_and_last_encounter_combined.SiteCode
left join NDWH.Dim.DimFacility as facility on facility.MFLCode = otz_and_last_encounter_combined.SiteCode
left join NDWH.Dim.DimDate as otz_enrollment on otz_enrollment.Date = otz_and_last_encounter_combined.OTZEnrollmentDate
left join NDWH.Dim.DimDate as last_visit on last_visit.Date = otz_and_last_encounter_combined.LastVisitDate
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = otz_and_last_encounter_combined.SiteCode
left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = otz_and_last_encounter_combined.AgeLastVisit
WHERE patient.voided =0;

alter table NDWH.Fact.FactOTZ add primary key(FactKey);
END


