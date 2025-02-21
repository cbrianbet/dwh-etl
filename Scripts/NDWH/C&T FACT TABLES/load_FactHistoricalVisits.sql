
IF OBJECT_ID(N'[NDWH].[fact].[FactHistoricalVisits]', N'U') IS NOT NULL 
	DROP TABLE NDWH.[fact].[FactHistoricalVisits];


BEGIN	
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency
	from ODS.Care.All_EMRSites 
),
UniqueVisits as (
Select   row_number() OVER (PARTITION BY SiteCode,Patientpkhash, VisitDate ORDER BY VisitDate DESC) AS NUM,
	Patientpkhash,
	Sitecode,
	VisitDate,
	BP,
	WHOStage,
	NextAppointmentDate,
	voided
	from ODS.Care.CT_PatientVisits as visits
	
),
ChronicIllnessScreening as (
	select 
		distinct SiteCode,
		PatientPKHash,
	    VisitID,
		VisitDate 
	from ODS.Care.CT_AllergiesChronicIllness 
)

select 
	Factkey = IDENTITY(INT, 1, 1),
	patient.PatientKey,
	patient.PatientPKHash,
	patient.SiteCode,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    StartARTDate.DateKey As StartARTDateKey,
    VisitDate.DateKey As VisitDateKey,
    NextAppointmentDate.DateKey As NextAppointmentDateKey,
	WHOStage,
	CASE
		WHEN ChronicIllnessScreening.PatientPKHash IS NOT NULL THEN 1
		ELSE 0
	END As ScreenedForChronicIllness,
	CASE
		WHEN visits.BP IS NOT NULL THEN 1
		ELSE 0
	END As ScreenedForHypertension,
	cast(getdate() as date) as LoadDate
into NDWH.fact.FactHistoricalVisits
from UniqueVisits as  visits
inner join ODS.Care.CT_ARTPatients as art on art.PatientPKHash=visits.PatientPKHash and art.SiteCode=visits.SiteCode
inner join NDWH.Dim.DimPatient as patient on visits.PatientPKHash = patient.PatientPKHash and visits.SiteCode = patient.SiteCode
left join ChronicIllnessScreening on visits.PatientPKHash=ChronicIllnessScreening.PatientPKHash and visits.SiteCode=ChronicIllnessScreening.SiteCode and visits.VisitDate=ChronicIllnessScreening.VisitDate
left join NDWH.Dim.DimFacility as facility on facility.MFLCode = visits.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = visits.SiteCode
left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.Dim.DimDate as VisitDate on VisitDate.Date=visits.VisitDate
left join NDWH.Dim.DimDate as StartARTDate on StartARTDate.Date=art.StartARTDate
left join NDWH.Dim.DimDate as NextAppointmentDate on NextAppointmentDate.Date=visits.NextAppointmentDate
WHERE Visits.voided =0 and Visits.NUM=1 and visits.VisitDate >= EOMONTH(DATEADD(MONTH, -11, GETDATE())) 

alter table NDWH.fact.FactHistoricalVisits add primary key(FactKey);
END



 