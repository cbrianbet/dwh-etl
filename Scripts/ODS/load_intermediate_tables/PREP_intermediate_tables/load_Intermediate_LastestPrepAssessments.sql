IF OBJECT_ID(N'[ODS].[Intermediate].[Intermediate_LastestPrepAssessments]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[Intermediate].[Intermediate_LastestPrepAssessments];
BEGIN

    with source_data as (
        select 
            row_number () over (partition by PatientPk, SiteCode order by VisitDate desc) As num,
            PatientPk,
            SiteCode,
            VisitDate,
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
        from ODS.[PrEP].PrEP_BehaviourRisk
    )
    select 
        source_data.*,cast( '' as nvarchar(100)) PatientPKHash,cast( '' as nvarchar(100)) HIVPartnerCCCnumberHash,
        cast(getdate() as date) as LoadDate
    into ODS.[Intermediate].Intermediate_LastestPrepAssessments
    from  source_data
    where num = 1;

END