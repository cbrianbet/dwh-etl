
IF OBJECT_ID(N'[NDWH].[Fact].[FactLatestObs]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[Fact].[FactLatestObs];

ALTER TABLE ODS.Care.All_EMRSites  ALTER COLUMN SDP_Agency nvarchar(4000) ;

BEGIN	
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency 
	from ODS.Care.All_EMRSites 
),
distinct_alcohol_drug_use_patients as (
	select 
		distinct PatientPKHash,
    	SiteCode
	from ODS.[Intermediate].[IntermediateAlcoholDrugUseLastOneYear]
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
	case when alcohol_drug_use.PatientPKHash is not null then 1 else 0 end as HasAlcoholOrDrugUseLastOneYear,
	cast(getdate() as date) as LoadDate
into NDWH.[Fact].FactLatestObs
from ODS.[intermediate].intermediate_LatestObs as  obs
left join distinct_alcohol_drug_use_patients as alcohol_drug_use on alcohol_drug_use.PatientPKHash = obs.PatientPKHash
	and alcohol_drug_use.SiteCode = obs.SiteCode
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
