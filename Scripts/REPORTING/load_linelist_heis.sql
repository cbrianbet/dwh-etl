if OBJECT_ID(N'[REPORTING].[dbo].[LinelistHEI]', N'U') is not null 
	drop table [REPORTING].[dbo].[LinelistHEI]
go

select
    patient.PatientIDHash,
    patient.PatientPKHash,
    patient.DOB,
    patient.NUPI,
    facility.FacilityName,
    facility.MFLCode,
    facility.County,
    facility.SubCounty,
    partner.PartnerName,
    agency.AgencyName,
    age_group.DATIMAgeGroup as AgeGroup,
    patient.Gender,
    OnProhylaxis, 
    TestedAt6wksOrFirstContact,
    TestedAt6months,
    TestedAt12months,
    InitialPCRLessThan8wks, 
    InitialPCRBtwn8wks_12mnths,
    HasFinalAntibody,
    EBF6mnths,
    ERF6mnths,
    BF12mnths,
    BF18mnths,
    InfectedAt24mnths,
    UnknownOutocomeAt24months,
    InfectedOnART,
    HEIExitCriteria,
    HEIHIVStatus
into REPORTING.dbo.LinelistHEI
from NDWH.Fact.FactHEI as hei
left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = hei.FacilityKey
left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = hei.PartnerKey
left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = hei.AgencyKey
left join NDWH.Dim.DimAgeGroup as age_group on age_group.AgeGroupKey = hei.AgeGroupKey
left join NDWH.Dim.DimPatient as patient on patient.PatientKey = hei.PatientKey

go