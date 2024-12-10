
IF OBJECT_ID(N'[NDWH].[Fact].[FactLatestObs]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[Fact].[FactLatestObs];

ALTER TABLE ODS.Dim.All_EMRSites  ALTER COLUMN SDP_Agency nvarchar(4000) ;

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
    age_group.AgeGroupKey,
	diff_care.DifferentiatedCareKey,
	LatestHeight,
	LatestWeight,
	AgeLastVisit,
	Adherence,
	obs.DifferentiatedCare,
	onMMD,
	StabilityAssessment,
	Pregnant,
    breastfeeding,
    TBScreening,
    OnIPT,
    StartIPT,
    EverOnIPT,
	cast(getdate() as date) as LoadDate
into NDWH.[Fact].FactLatestObs
from ODS.[intermediate].intermediate_LatestObs obs
left join NDWH.Dim.DimPatient as patient on obs.PatientPKHash = patient.PatientPKHash 
    and obs.SiteCode = patient.SiteCode
left join NDWH.Dim.DimFacility as facility on facility.MFLCode = obs.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = obs.SiteCode
left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = obs.AgeLastVisit
left join NDWH.Dim.DimDifferentiatedCare as diff_care on diff_care.DifferentiatedCare = obs.DifferentiatedCare
WHERE patient.voided =0;

alter table NDWH.Fact.FactLatestObs add primary key(FactKey);
END
