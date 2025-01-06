IF OBJECT_ID(N'[NDWH].[Fact].[FactPrepAssessments]', N'U') IS NOT NULL 
DROP TABLE [NDWH].[Fact].[FactPrepAssessments];

BEGIN

with MFL_partner_agency_combination as (
    select 
        distinct MFL_Code,
        SDP,
    SDP_Agency  as Agency
    from ODS.Care.All_EMRSites 
),
source_data as (
    select 
        patient.PatientPKHash,
        patient.SiteCode,
        VisitID,
        SexPartnerHIVStatus,
        IsHIVPositivePartnerCurrentonART,
        IsPartnerHighrisk,
        PartnerARTRisk,
        ClientAssessments,
        ClientWillingToTakePrep,
        PrEPDeclineReason,
        RiskReductionEducationOffered,
        ReferralToOtherPrevServices,
        FirstEstablishPartnerStatus,
        PartnerEnrolledtoCCC,
        HIVPartnerCCCnumber,
        HIVPartnerARTStartDate,
        MonthsknownHIVSerodiscordant,
        SexWithoutCondom,
        NumberofchildrenWithPartner,
        ClientRisk,
        case 
            when ClientRisk='Risk' then 1 else 0 end as EligiblePrep,
        VisitDate As AssessmentVisitDate,
        case 
            when VisitDate is not null then 1 else 0 end as ScreenedPrep
    from ODS.PrEP.PrEP_Patient as patient
    left join ODS.PrEP.PrEP_BehaviourRisk as risk on patient.PatientPk = risk.PatientPk
        and patient.SiteCode = risk.SiteCode
)
select 
    distinct 
    FactKey = IDENTITY(INT, 1, 1),
    patient.PatientKey,
    facility.FacilityKey,
    agency.AgencyKey,
    partner.PartnerKey,
    age_group.AgeGroupKey,
    patient.Gender,
    VisitID,
    SexPartnerHIVStatus,
    IsHIVPositivePartnerCurrentonART,
    IsPartnerHighrisk,
    PartnerARTRisk,
    ClientAssessments,
    ClientWillingToTakePrep,
    PrEPDeclineReason,
    RiskReductionEducationOffered,
    ReferralToOtherPrevServices,
    FirstEstablishPartnerStatus,
    PartnerEnrolledtoCCC,
    HIVPartnerCCCnumber,
    HIVPartnerARTStartDate,
    MonthsknownHIVSerodiscordant,
    SexWithoutCondom,
    NumberofchildrenWithPartner,
    ClientRisk,
    assessment_date.DateKey As AssessmentVisitDateKey,
    patient.PrepEnrollmentDateKey,
    EligiblePrep,
    ScreenedPrep,
    cast(getdate() as date) as LoadDate
into NDWH.Fact.FactPrepAssessments
from source_data
left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = source_data.PatientPKHash
    and patient.SiteCode = source_data.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = source_data.SiteCode
left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP 
left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.Dim.DimFacility as facility on facility.MFLCode = source_data.SiteCode
left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = datediff(yy, patient.DOB, coalesce(source_data.AssessmentVisitDate, getdate()))
left join NDWH.Dim.DimDate as assessment_date on assessment_date.Date = source_data.AssessmentVisitDate
WHERE patient.voided =0;

alter table NDWH.Fact.FactPrepAssessments add primary key(FactKey);

END
