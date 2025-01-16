if OBJECT_ID(N'[REPORTING].[dbo].[AggregateHEI]', N'U') is not null 
	drop table [REPORTING].[dbo].[AggregateHEI]
go

select   
    facility.FacilityName,
    facility.MFLCode,
    facility.County,
    facility.SubCounty,
    partner.PartnerName,
    agency.AgencyName,
    age_group.DATIMAgeGroup as AgeGroup,
    patient.Gender,
    sum(OnProhylaxis) as CountOnProphylaxis,
    sum(TestedAt6wksOrFirstContact) as CountTestedAt6monthsOrFirstContact,
    sum(TestedAt6months) as CountTestedAt6months,
    sum(TestedAt12months) as CountTestedAt12months,
    sum(InitialPCRLessThan8wks) as CountInitialPCRLessThan8wks, 
    sum(InitialPCRBtwn8wks_12mnths) as CountInitialPCRBtwn8wks_12mnths,
    sum(HasFinalAntibody) as CountHasFinalAntibody,
    sum(EBF6mnths) as CountEBF6mnths,
    sum(ERF6mnths) as CountERF6mnths,
    sum(BF12mnths) as CountBF12mnths,
    sum(BF18mnths) as CountBF18mnths,
    sum(InfectedAt24mnths) as CountInfectedAt24mnths,
    sum(case when InfectedAt24mnths = 0 then 1 else 0 end) as CountUninfectedAt24mnths,
    sum(UnknownOutocomeAt24months) as CountUnknownOutocomeAt24months,
    sum(InfectedOnART) as CountInfectedOnART,
    sum(case when InfectedOnART = 0 then 1 else 0 end) as CountInfectedNotOnART
into REPORTING.dbo.AggregateHEI
from NDWH.Fact.FactHEI as hei
left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = hei.FacilityKey
left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = hei.PartnerKey
left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = hei.AgencyKey
left join NDWH.Dim.DimAgeGroup as age_group on age_group.AgeGroupKey = hei.AgeGroupKey
left join NDWH.Dim.DimPatient as patient on patient.PatientKey = hei.PatientKey
group by 
    facility.FacilityName,
    facility.MFLCode,
    facility.County,
    facility.SubCounty,
    partner.PartnerName,
    agency.AgencyName,
    age_group.DATIMAgeGroup,
    patient.Gender
go
