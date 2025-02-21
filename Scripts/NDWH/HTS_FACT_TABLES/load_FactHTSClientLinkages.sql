IF OBJECT_ID(N'[NDWH].[Fact].[FactHTSClientLinkages]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[Fact].[FactHTSClientLinkages];

BEGIN

with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
        SDP_Agency as Agency
	from ODS.Care.All_EMRSites 
),
source_data as (
select 
    SiteCode,
    PatientPK,
    EnrolledFacilityName,
    ReferralDate,
    DateEnrolled,
    DatePrefferedToBeEnrolled,
    FacilityReferredTo,
    HandedOverTo,
    HandedOverToCadre,
    convert(nvarchar(64), hashbytes('SHA2_256', cast(ReportedCCCNumber as nvarchar(36))), 2) as ReportedCCCNumber,
    row_number() over(partition by Sitecode,PatientPK order by DateEnrolled desc) as row_num
from ODS.HTS.HTS_ClientLinkages 
)
select 
    Factkey = IDENTITY(INT, 1, 1),
    patient.PatientKey,
    facility.FacilityKey,
    partner.PartnerKey,
    agency.AgencyKey,
    referral.DateKey as ReferralDateKey,
    enrolled.DateKey as DateEnrolledKey,
    preferred.DateKey as DatePrefferedToBeEnrolledKey,
    FacilityReferredTo,
    HandedOverTo,
    HandedOverToCadre,
    ReportedCCCNumber,
    cast(getdate() as date) as LoadDate
into NDWH.[Fact].FactHTSClientLinkages
from source_data
left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(source_data.PatientPK as nvarchar(36))), 2)
    and patient.SiteCode = source_data.SiteCode
left join NDWH.Dim.DimFacility as facility on facility.MFLCode = source_data.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = source_data.SiteCode
left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.Dim.DimDate as referral on referral.Date = source_data.ReferralDate
left join NDWH.Dim.DimDate as enrolled on enrolled.Date = source_data.DateEnrolled
left join NDWH.Dim.DimDate as preferred on preferred.Date = source_data.DatePrefferedToBeEnrolled
where row_num = 1 and patient.voided =0;

alter table NDWH.[Fact].FactHTSClientLinkages add primary key(FactKey);

END