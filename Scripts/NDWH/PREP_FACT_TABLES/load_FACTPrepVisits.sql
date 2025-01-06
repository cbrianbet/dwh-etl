IF OBJECT_ID(N'[NDWH].[Fact].[FactPrepVisits]', N'U') IS NOT NULL 
DROP TABLE [NDWH].[Fact].[FactPrepVisits];

BEGIN

    with MFL_partner_agency_combination as (
        select 
            distinct MFL_Code,
            SDP,
        SDP_Agency  as Agency
        from ODS.Care.All_EMRSites 
    ),
    prep_patients as
    (
        select
            distinct convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK as nvarchar(36))), 2) as PatientPK,
            SiteCode,
            PrepEnrollmentDate
        from ODS.PrEP.PrEP_Patient
        where ODS.PrEP.PrEP_Patient.PrepNumber is not null
    ),

PrepVisits as (
        select 
            convert(nvarchar(64), hashbytes('SHA2_256', cast(prepvisits.PatientPK as nvarchar(36))), 2) as PatientPK,
            prepvisits.SiteCode,    
            VisitID,
            VisitDate,
            BloodPressure,
            Temperature,
            Weight,
            Height,
            BMI,
            STIScreening,
            STISymptoms,
            STITreated,
            Circumcised,
            VMMCReferral,
            LMP,
            MenopausalStatus,
            PregnantAtThisVisit,
            EDD,
            PlanningToGetPregnant,
            PregnancyPlanned,
            PregnancyEnded,
            PregnancyEndDate,
            PregnancyOutcome,
            BirthDefects,
            Breastfeeding,
            FamilyPlanningStatus,
            FPMethods,
            AdherenceDone,
            AdherenceOutcome,
            AdherenceReasons,
            SymptomsAcuteHIV,
            ContraindicationsPrep,
            PrepTreatmentPlan,
            PrepPrescribed,
            RegimenPrescribed,
            MonthsPrescribed,
            CondomsIssued,
            Tobegivennextappointment,
            Reasonfornotgivingnextappointment,
            HepatitisBPositiveResult,
            HepatitisCPositiveResult,
            VaccinationForHepBStarted,
            TreatedForHepB,
            VaccinationForHepCStarted,
            TreatedForHepC,
            NextAppointment,
            ClinicalNotes
        from ODS.PrEP.PrEP_Visits as prepvisits
        where VisitDate is not null

    )

    select 
        FactKey = IDENTITY(INT, 1, 1),
        patient.PatientKey,
        facility.FacilityKey,
        agency.AgencyKey,
        partner.PartnerKey,
        age_group.AgeGroupKey,
        visit.DateKey as VisitDateKey,
        appointment.DateKey as NextAppointmentDateKey,
        pregnancy.DateKey as PregnancyEndDateKey,
        PrepVisits.VisitID,
        PrepVisits.BloodPressure,
        PrepVisits.Temperature,
        PrepVisits.Weight,
        PrepVisits.Height,
        PrepVisits.BMI,
        PrepVisits.STIScreening,
        PrepVisits.STISymptoms,
        case when   PrepVisits.STISymptoms  is not null then 1 else 0 end as STIPositive,
        case when   PrepVisits.STISymptoms  is  null then 1 else 0 end as STINegative,
        PrepVisits.STITreated,
        PrepVisits.Circumcised,
        PrepVisits.VMMCReferral,
        PrepVisits.LMP,
        PrepVisits.MenopausalStatus,
        PrepVisits.PregnantAtThisVisit,
        PrepVisits.EDD,
        PrepVisits.PlanningToGetPregnant,
        PrepVisits.PregnancyPlanned,
        PrepVisits.PregnancyEnded,
        PrepVisits.PregnancyEndDate,
        PrepVisits.PregnancyOutcome,
        PrepVisits.BirthDefects,
        PrepVisits.Breastfeeding,
        PrepVisits.FamilyPlanningStatus,
        PrepVisits.FPMethods,
        PrepVisits.AdherenceDone,
        PrepVisits.AdherenceOutcome,
        PrepVisits.AdherenceReasons,
        PrepVisits.SymptomsAcuteHIV,
        PrepVisits.ContraindicationsPrep,
        PrepVisits.PrepTreatmentPlan,
        PrepVisits.PrepPrescribed,
        PrepVisits.RegimenPrescribed,
        PrepVisits.MonthsPrescribed,
        PrepVisits.CondomsIssued,
        PrepVisits.Tobegivennextappointment,
        PrepVisits.Reasonfornotgivingnextappointment,
        PrepVisits.HepatitisBPositiveResult,
        PrepVisits.HepatitisCPositiveResult,
        PrepVisits.VaccinationForHepBStarted,
        PrepVisits.TreatedForHepB,
        PrepVisits.VaccinationForHepCStarted,
        PrepVisits.TreatedForHepC,
        PrepVisits.NextAppointment,
        PrepVisits.ClinicalNotes,
        patient.PrepEnrollmentDateKey,
        cast(getdate() as date) as LoadDate
    into NDWH.Fact.FactPrepVisits
    from prep_patients
    left join PrepVisits as  PrepVisits on PrepVisits.PatientPK = prep_patients.PatientPK
        and PrepVisits.SiteCode = prep_patients.SiteCode
    left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = prep_patients.PatientPK
        and patient.SiteCode = prep_patients.SiteCode
    left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = prep_patients.SiteCode
    left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP 
    left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
    left join NDWH.Dim.DimFacility as facility on facility.MFLCode = prep_patients.SiteCode
    left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = datediff(yy, patient.DOB, coalesce(PrepVisits.VisitDate, getdate()))
    left join NDWH.Dim.DimDate as visit on visit.Date = PrepVisits.VisitDate
    left join NDWH.Dim.DimDate as pregnancy on pregnancy.Date = PrepVisits.PregnancyEndDate
    left join NDWH.Dim.DimDate as appointment on appointment.Date= PrepVisits.NextAppointment
   
	WHERE patient.voided =0;
    
    alter table NDWH.Fact.FactPrepVisits add primary key(FactKey);

END
