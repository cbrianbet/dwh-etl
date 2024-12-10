IF OBJECT_ID(N'[REPORTING].[dbo].AggregateAppointments', N'U') IS NOT NULL 
DROP TABLE [REPORTING].[dbo].AggregateAppointments

GO 

with Bookings AS (
  select
    Facilitykey,
    EOMONTH(ExpectedNextAppointmentDate) AS EndOfMonthBookings,
    PartnerKey,
    patient.Gender,
    age_group.DATIMAgeGroup,
    AgencyKey,
    COUNT(distinct apt.PatientKey) as NumBooked
  from
  NDWH.Fact.FACTAppointments apt
  left join NDWH.Dim.DimPatient as patient on patient.PatientKey = apt.PatientKey
  left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = DATEDIFF(YY, patient.DOB, apt.LastEncounterDate)
  group by
    Facilitykey,
    EOMONTH(ExpectedNextAppointmentDate),
    PartnerKey,
    patient.Gender,
    age_group.DATIMAgeGroup,
    AgencyKey
),
appointments_summary as (
    select
      apt.FacilityKey,
      apt.PartnerKey,
      apt.AgencyKey,
      patient.Gender,
      AppointmentStatus,
      EOMONTH(LastEncounterDate) as EndOfMonthEncounter,
      age_group.DATIMAgeGroup,
      count(distinct apt.PatientKey) NumOfPatients
    from NDWH.Fact.FACTAppointments as apt
    left join NDWH.Dim.DimPatient as patient on patient.PatientKey = apt.PatientKey
    left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = DATEDIFF(YY, patient.DOB, apt.LastEncounterDate)
    group by
      apt.FacilityKey,
      apt.PartnerKey,
      apt.AgencyKey,
      patient.Gender,
      apt.AppointmentStatus,
      EOMONTH(LastEncounterDate),
      age_group.DATIMAgeGroup
)
select
  facility.MFLCode,
  facility.FacilityName,
  facility.SubCounty,
  facility.County,
  partner.PartnerName,
  agency.AgencyName,
  appointments_summary.Gender,
  appointments_summary.DATIMAgeGroup,
  appointments_summary.EndOfMonthEncounter,
  appointments_summary.AppointmentStatus,
  appointments_summary.NumOfPatients as NumPatients,
  coalesce(Bookings.NumBooked, 0) as NumBooked,
  cast(getdate() as date) as LoadDate
into REPORTING.dbo.AggregateAppointments
from appointments_summary
left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = appointments_summary.FacilityKey
left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = appointments_summary.PartnerKey
left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = appointments_summary.AgencyKey
left join Bookings AS Bookings on Bookings.EndOfMonthBookings = appointments_summary.EndOfMonthEncounter
  and Bookings.FacilityKey = appointments_summary.FacilityKey
  and Bookings.PartnerKey = appointments_summary.PartnerKey
  and Bookings.Gender = appointments_summary.Gender
  and Bookings.AgencyKey = appointments_summary.AgencyKey
  and Bookings.DATIMAgeGroup = appointments_summary.DATIMAgeGroup
