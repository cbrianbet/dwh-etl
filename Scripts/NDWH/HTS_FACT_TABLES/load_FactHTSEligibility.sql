IF OBJECT_ID(N'[NDWH].[Fact].[FactHTSEligibilityextract]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[Fact].[FactHTSEligibilityextract];

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
            PatientPKHash,
            SiteCode,
            EncounterId,
            VisitID,
            Department,
            IsHealthWorker,
            RelationshipWithContact,
            TestedHIVBefore,
            WhoPErformedTest,
            ResultOfHIV,
            cast(VisitDate as date) as VisitDate,
            cast (DateTestedSelf as date) As DateTestedSelf,
            StartedOnART,
            CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(CCCNumber as NVARCHAR(36))), 2) As CCCNumberHash,
            EverHadSex,
            SexuallyActive,
            NewPartner,
            PartnerHIVStatus,
            CoupleDiscordant,
            MultiplePartners,
            NumberOfPartners,
            AlcoholSex,
            MoneySex,
            CondomBurst,
            UnknownStatusPartner,
            KnownStatusPartner,
            Pregnant,
            BreastfeedingMother,
            ExperiencedGBV,
            ContactWithTBCase,
            Lethargy,
            EverOnPrep,
            CurrentlyOnPep,
            EverHadSTI,
            CurrentlyHasSTI,
            EverHadTB,
            SharedNeedle,
            NeedleStickInjuries,
            TraditionalProcedures,
            ChildReasonsForIneligibility,
            EligibleForTest,
            ReasonsforIneligibility,
            specificReasonForIneligibility,
            Cough,
            cast (DateTestedProvider as date) As DateTestedProvider,
            Fever,
            MothersStatus,
            NightSweats,
            ReferredForTesting,
            ResultOfHIVSelf,
            ScreenedTB,
            TBStatus,
            WeightLoss,
            AssessmentOutcome,
            ForcedSex,
            ReceivedServices,
            TypeGBV,
			HIVRiskCategory,
			HtsRiskScore,
            ReasonRefferredForTesting,
            ReasonNotReffered,
            HTSStrategy,
            HTSEntryPoint,
            CurrentlyOnPrep
        from ODS.HTS.HTS_EligibilityExtract
    )
    select 
        Factkey = IDENTITY(INT, 1, 1),
        patient.PatientKey,
        facility.FacilityKey,
        partner.PartnerKey,
        agency.AgencyKey,
        VisitDate.DateKey As VisitDateKey,
        DateTestedSelf.DateKey as DateTestedSelfKey,
        source_data.Department,
        source_data.IsHealthWorker,
        source_data.RelationshipWithContact,
        source_data.TestedHIVBefore,
        source_data.WhoPErformedTest,
        source_data.ResultOfHIV,
        source_data.StartedOnART,
        source_data.CCCNumberHash,
        source_data.EverHadSex,
        source_data.SexuallyActive,
        source_data.NewPartner,
        source_data.PartnerHIVStatus,
        source_data.CoupleDiscordant,
        source_data.MultiplePartners,
        source_data.NumberOfPartners,
        source_data.AlcoholSex,
        source_data.MoneySex,
        source_data.CondomBurst,
        source_data.UnknownStatusPartner,
        source_data.KnownStatusPartner,
        source_data.Pregnant,
        source_data.BreastfeedingMother,
        source_data.ExperiencedGBV,
        source_data.ContactWithTBCase,
        source_data.Lethargy,
        source_data.EverOnPrep,
        source_data.CurrentlyOnPep,
        source_data.EverHadSTI,
        source_data.CurrentlyHasSTI,
        source_data.EverHadTB,
        source_data.SharedNeedle,
        source_data.NeedleStickInjuries,
        source_data.TraditionalProcedures,
        source_data.ChildReasonsForIneligibility,
        source_data.EligibleForTest,
        source_data.ReasonsforIneligibility,
        source_data.specificReasonForIneligibility,
        source_data.Cough,
        cast (DateTestedProvider as date) As DateTestedProvider,
        source_data.Fever,
        source_data.MothersStatus,
        source_data.NightSweats,
        source_data.ReferredForTesting,
        source_data.ResultOfHIVSelf,
        source_data.ScreenedTB,
        source_data.TBStatus,
        source_data.WeightLoss,
        source_data.AssessmentOutcome,
        source_data.ForcedSex,
        source_data.ReceivedServices,
        source_data.TypeGBV,
        source_data.HIVRiskCategory,
        source_data.HtsRiskScore,
        source_data.ReasonRefferredForTesting,
        source_data.ReasonNotReffered,
        source_data.HTSStrategy,
        source_data.CurrentlyOnPrep,
        source_data.HTSEntryPoint,
        cast(getdate() as date) as LoadDate
    into NDWH.Fact.FactHTSEligibilityextract
    from source_data
    left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = source_data.PatientPKHash
        and patient.SiteCode = source_data.SiteCode
    left join NDWH.Dim.DimFacility as facility on facility.MFLCode = source_data.SiteCode
    left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = source_data.SiteCode
    left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
    left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
    left join NDWH.Dim.DimDate as VisitDate on VisitDate.Date = source_data.VisitDate
    left join NDWH.Dim.DimDate as DateTestedSelf on DateTestedSelf.Date = source_data.DateTestedSelf
    left join NDWH.Dim.DimDate as DateTestedProvider on DateTestedProvider.Date = source_data.DateTestedProvider
	WHERE patient.voided =0;


    alter table NDWH.Fact.FactHTSEligibilityextract add primary key(FactKey);

END