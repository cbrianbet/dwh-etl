IF OBJECT_ID(N'[NDWH].[dbo].FACTAppointments', N'U') IS NOT NULL 		
	drop table [NDWH].[dbo].FACTAppointments
GO
With MFL_partner_agency_combination as (
		select 
			distinct MFL_Code,
			SDP,
			SDP_Agency as Agency
		from ODS.dbo.All_EMRSites 
),
patient_info as (
	select 
		patient.PatientPK,
		patient.SiteCode,
		patient.Patienttype,
		art.StartARTDate
	from ODS.dbo.CT_Patient as patient
	inner join ODS.dbo.CT_ARTPatients as art on art.PatientPk  = patient.PatientPK
		and art.SiteCode = patient.Sitecode
)
Select 
        FactKey = IDENTITY(INT, 1, 1),
		facility.FacilityKey,
		partner.PartnerKey,
		agency.AgencyKey,
		patient.PatientKey,
		as_of.DateKey as AsOfDateKey,
		LastEncounterDate,
		ExpectedNextAppointmentDate,
		AppointmentStatus,
		DiffExpectedTCADateLastEncounter,
        age_group.AgeGroupKey,
        AsofDate,
		RegimenAsof,
		coalesce(NoOfUnscheduledVisits, 0) as NoOfUnscheduledVisitsAsOf,
        patient_info.StartARTDate,
        patient_info.Patienttype,
        cast(getdate() as date) as LoadDate		
into NDWH.dbo.FACTAppointments
from Historical.dbo.[HistoricalAppointmentStatus] as apt
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = apt.MFLCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code=apt.MFLCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = apt.PatientPKhash and patient.SiteCode=apt.MFLCode
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimAgeGroup as age_group on age_group.age = DATEDIFF(YY,patient.DOB,apt.AsOfDate)
left join NDWH.dbo.DimDate as as_of on as_of.Date = apt.AsOfDate
left join patient_info on patient_info.PatientPK = apt.PatientPK 
    and patient_info.SiteCode = apt.MFLCode
WHERE patient.voided =0;


alter table NDWH.dbo.FACTAppointments add primary key(FactKey);