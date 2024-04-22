IF OBJECT_ID(N'[NDWH].[dbo].[FactHTSClientTests]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactHTSClientTests];

BEGIN

with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency
	from ODS.dbo.All_EMRSites 
),
client_linkage_data as (
    select 
        Sitecode,
        PatientPk,
        DateEnrolled,
        ReportedCCCNumber,
        row_number() over(partition by Sitecode,PatientPK order by DateEnrolled desc) as row_num 
    from ODS.dbo.HTS_ClientLinkages 
)
select 
    Factkey = IDENTITY(INT, 1, 1),    
    patient.PatientKey,
    facility.FacilityKey,
    partner.PartnerKey,
    agency.AgencyKey,
    age_group.AgeGroupKey,
    datediff(yy, patient.DOB, hts_encounter.TestDate) as AgeAtTesting,
    testing.DateKey as DateTestedKey,
    hts_encounter.EverTestedForHiv,
    hts_encounter.MonthsSinceLastTest,
    hts_encounter.ClientTestedAs,
    hts_encounter.EntryPoint,
    hts_encounter.TestStrategy,
    hts_encounter.TestResult1,
    hts_encounter.TestResult2,
    hts_encounter.FinalTestResult,
    hts_encounter.PatientGivenResult,
    hts_encounter.TestType,
    hts_encounter.TBScreening,
    hts_encounter.ClientSelfTested,
    hts_encounter.CoupleDiscordant,
    hts_encounter.Consent,
    hts_encounter.EncounterId,
    hts_encounter.ReferredServices,
    case when hts_encounter.FinalTestResult is not null then 1 else 0 end as Tested,
    case when hts_encounter.FinalTestResult = 'Positive' then 1 else 0 end as Positive,
    case when (hts_encounter.FinalTestResult = 'Positive' and client_linkage_data.ReportedCCCNumber is not null) then 1 else 0 end as Linked,
    case when client_linkage_data.ReportedCCCNumber is not null then 1 else 0 end ReportedCCCNumber,
    case 
        when (hts_encounter.MonthsSinceLastTest < 3 and hts_encounter.MonthsSinceLastTest is not null) then '<3 Months' 
        when (hts_encounter.MonthsSinceLastTest >= 3 and hts_encounter.MonthsSinceLastTest < 6) then '3-6 Months' 
        when (hts_encounter.MonthsSinceLastTest >= 6 and hts_encounter.MonthsSinceLastTest < 9) then '6-9 Months' 
        when (hts_encounter.MonthsSinceLastTest >= 9 and hts_encounter.MonthsSinceLastTest < 12) then '9-12 Months' 
        when (hts_encounter.MonthsSinceLastTest >= 12 and hts_encounter.MonthsSinceLastTest < 18) then '12-18 Months' 
        when (hts_encounter.MonthsSinceLastTest >= 18 and hts_encounter.MonthsSinceLastTest < 24) then '18-24 Months' 
        when (hts_encounter.MonthsSinceLastTest >= 24 and hts_encounter.MonthsSinceLastTest < 36) then '24-36 Months' 
        when (hts_encounter.MonthsSinceLastTest >= 36 and (hts_encounter.MonthsSinceLastTest < 48)) then '36-48 Months' 
        when (hts_encounter.MonthsSinceLastTest >= 48 and hts_encounter.MonthsSinceLastTest is not null) then '>48Months' 
    end as MonthsLastTest,
    case 
        when (hts_encounter.EverTestedForHiv = 'Yes' and hts_encounter.MonthsSinceLastTest < 12) then 'Retest' 
    else 'New' end as TestedBefore,
    hts_encounter.Setting,
    cast(getdate() as date) as LoadDate
into NDWH.dbo.FactHTSClientTests
from ODS.dbo.Intermediate_EncounterHTSTests as hts_encounter
left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = hts_encounter.PatientPKHash
    and patient.SiteCode = hts_encounter.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = hts_encounter.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = hts_encounter.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age =  datediff(yy, patient.DOB, hts_encounter.TestDate)
left join NDWH.dbo.DimDate as testing on testing.Date = cast(hts_encounter.TestDate as date)
left join  client_linkage_data on client_linkage_data.PatientPk = hts_encounter.PatientPK
    and client_linkage_data.SiteCode = hts_encounter.SiteCode
    and client_linkage_data.row_num = 1
	WHERE patient.voided =0;

alter table NDWH.dbo.FactHTSClientTests add primary key(FactKey);

END