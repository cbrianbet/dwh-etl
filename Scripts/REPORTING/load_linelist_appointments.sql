IF OBJECT_ID(N'[REPORTING].[dbo].LinelistAppointments', N'U') IS NOT NULL 		
drop table [REPORTING].[dbo].LinelistAppointments

GO

with dsd_models_as_of as (
	select 
		PatientKey,
		DifferentiatedCare,
    AsofDateKey
	from NDWH.dbo.FactARTHistory
	where DifferentiatedCare is not null and DifferentiatedCare <> ''
)
select 
  Patient.PatientIDHash,
  Patient.PatientPKHash,
  Patient.NUPI,
  Patient.DOB,
  Patient.MaritalStatus,
  facility.MFLCode,
  facility.FacilityName,
  facility.SubCounty,
  facility.County,
  partner.PartnerName,
  agency.AgencyName,
  patient.Gender,
  ExpectedNextAppointmentDate,
  LastEncounterDate,
  DiffExpectedTCADateLastEncounter,
  apt.AppointmentStatus,
  apt.AsOfDate,
  RegimenAsof,
	StartARTDate,
  Patienttype,
  NoOfUnscheduledVisitsAsOf,
  age_group.DATIMAgeGroup,
  dsd_models_as_of.DifferentiatedCare as DSDModelAsOf,
  CAST(GETDATE() AS DATE) AS LoadDate 
into [REPORTING].[dbo].LinelistAppointments
from NDWH.dbo.FACTAppointments as apt
left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = apt.FacilityKey
left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = apt.PartnerKey
left join NDWH.dbo.DimPatient as patient on patient.PatientKey = apt.PatientKey
left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = apt.AgencyKey
left join NDWH.dbo.DimAgeGroup as age_group on age_group.age = DATEDIFF(YY,patient.DOB,apt.AsOfDate)
left join dsd_models_as_of on dsd_models_as_of.PatientKey = apt.PatientKey
  and dsd_models_as_of.AsofDateKey = apt.AsOfDateKey