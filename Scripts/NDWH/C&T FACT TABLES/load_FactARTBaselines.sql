
IF OBJECT_ID(N'[NDWH].[Fact].[FactARTBaselines]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[Fact].[FactARTBaselines];

ALTER TABLE ODS.Care.All_EMRSites  ALTER COLUMN SDP_Agency nvarchar(4000) ;

BEGIN	
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency 
	from ODS.Care.All_EMRSites 
)
select 
	Factkey = IDENTITY(INT, 1, 1),
	patient.PatientKey,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    age_group.AgeGroupKey as AgeATARTStart,
    WHOStageAtART,
	cast(getdate() as date) as LoadDate
into NDWH.[Fact].FactARTBaselines
from ODS.[intermediate].intermediate_ARTBaselines art
left join NDWH.Dim.DimPatient as patient on art.PatientPKHash = patient.PatientPKHash 
    and art.SiteCode = patient.SiteCode
left join NDWH.Dim.DimFacility as facility on facility.MFLCode = art.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = art.SiteCode
left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = art.AgeATARTStart



alter table NDWH.[Fact].FactARTBaselines add primary key(FactKey);
END


