IF OBJECT_ID(N'[NDWH].[dbo].[FactContactElicitation]', N'U') IS NOT NULL 
	DROP TABLE  [NDWH].[dbo].[FactContactElicitation];

BEGIN

with MFL_partner_agency_combination as (
    select 
        distinct MFL_Code,
        SDP,
        [SDP_Agency]  as Agency
    from ODS.dbo.All_EMRSites 
),
subset_data as (
    select 
        PatientPK,
        CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(PatientPK as NVARCHAR(36))), 2) as PatientPKHash,
        SiteCode,
        ContactPatientPK,
        CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(ContactPatientPK as NVARCHAR(36))), 2) as ContactPatientPKHash,
        ContactSex,
        ContactAge,
        ContactMaritalStatus,
        RelationshipWithPatient,
		KnowledgeOfHivStatus,
        DateCreated
    from ODS.dbo.CT_ContactListing
    where voided = 0 
),
tested_contacts as (
    select 
        ContactPatientPK,
        subset_data.SiteCode,
		FinalTestResult,
        TestDate,
        row_number() over (partition by subset_data.ContactPatientPK, subset_data.SiteCode order by TestDate desc) as rank
    from subset_data
    inner join ODS.dbo.HTS_ClientTests as tests on tests.PatientPk = subset_data.ContactPatientPK
        and tests.SiteCode =subset_data.SiteCode
),
latest_test_for_tested_contacts as (
    select 
        *
    from tested_contacts
    where rank = 1
)
select 
	Factkey = IDENTITY(INT, 1, 1),
    index_pat.PatientKey as IndexPatientKey,
    contact_pat.PatientKey as ContactPatientKey,
    facility.FacilityKey,
    age_group.AgeGroupKey,
    partner.PartnerKey,
    agency.AgencyKey,
    ContactSex,
    ContactAge,
    ContactMaritalStatus,
    RelationshipWithPatient,
	case 
		when KnowledgeOfHivStatus = 'Positive' then 'Positive'
		when KnowledgeOfHivStatus = 'Negative' then 'Negative'
	end as ContactHIVStatusAtElicitation,
    created.DateKey as DateCreatedKey,
    case when latest_test_for_tested_contacts.ContactPatientPK is not null then 1 else 0 end as Tested,
	latest_test_for_tested_contacts.FinalTestResult as ContactHIVStatusAfterTesting
into [NDWH].[dbo].[FactContactElicitation]
from subset_data
left join latest_test_for_tested_contacts on latest_test_for_tested_contacts.ContactPatientPK = subset_data.ContactPatientPK
    and latest_test_for_tested_contacts.SiteCode = subset_data.SiteCode
left join NDWH.dbo.DimPatient as index_pat on index_pat.PatientPKHash = subset_data.PatientPKHash
    and index_pat.SiteCode = subset_data.SiteCode
left join NDWH.dbo.DimPatient as contact_pat on contact_pat.PatientPKHash = subset_data.ContactPatientPKHash
    and contact_pat.SiteCode = subset_data.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = subset_data.SiteCode
left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = datediff(year, index_pat.DOB,eomonth(dateadd(mm,-1,getdate())))
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = subset_data.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimDate as created on created.[Date] = subset_data.DateCreated

alter table [NDWH].[dbo].[FactContactElicitation] add primary key(FactKey);

END