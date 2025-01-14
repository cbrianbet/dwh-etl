IF OBJECT_ID(N'[NDWH].[dbo].[FactVLLastTwoYears]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].FactVLLastTwoYears;


BEGIN	
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency 
	from ODS.dbo.All_EMRSites 
)
select 
	Factkey = IDENTITY(INT, 1, 1),
	patient.PatientKey,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    Orderedby.DateKey As OrderedbyDateKey,
    TestName,
	TestResult,
	cast(getdate() as date) as LoadDate
into NDWH.dbo.FactVLLastTwoYears
from ODS.dbo.Intermediate_OrderedViralLoads as vls
left join NDWH.dbo.DimPatient as patient on vls.PatientPKHash = patient.PatientPKHash and vls.SiteCode = patient.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = vls.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = vls.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimDate as Orderedby on Orderedby.Date=vls.OrderedbyDate
WHERE vls.OrderedbyDate >= EOMONTH(DATEADD(MONTH, -24, GETDATE()))


alter table NDWH.dbo.FactVLLastTwoYears add primary key(FactKey);
END
