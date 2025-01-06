IF OBJECT_ID(N'[NDWH].[Fact].[FactPrepDiscontinuation]', N'U') IS NOT NULL 
DROP TABLE [NDWH].[Fact].[FactPrepDiscontinuation];

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
            PatientPKHash,
            SiteCode
        from ODS.PrEP.PrEP_Patient
        where ODS.PrEP.PrEP_Patient.PrepNumber is not null
    ),

PrepDiscontinuation as (
        select 
             PatientPKHash,
                SiteCode,
                ExitDate,
                ExitReason                  
        from ODS.PrEP.PrEP_CareTermination
        

    )


    select 
        FactKey = IDENTITY(INT, 1, 1),
        patient.PatientKey,
        facility.FacilityKey,
        agency.AgencyKey,
        partner.PartnerKey,
        age_group.AgeGroupKey,
        Discontinuation.DateKey as ExitDateKey,
        PrepDiscontinuation.ExitDate,
        PrepDiscontinuation.ExitReason,
        cast(getdate() as date) as LoadDate
    into NDWH.Fact.FactPrepDiscontinuation
    from prep_patients
    left join PrepDiscontinuation on PrepDiscontinuation.PatientPKHash =  prep_patients.PatientPKHash
        and PrepDiscontinuation.SiteCode = prep_patients.SiteCode
    left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = prep_patients.PatientPKHash
        and patient.SiteCode = prep_patients.SiteCode
    left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = prep_patients.SiteCode
    left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP 
    left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
    left join NDWH.Dim.DimFacility as facility on facility.MFLCode = prep_patients.SiteCode
    left join NDWH.Dim.DimDate as Discontinuation on Discontinuation.Date = PrepDiscontinuation.ExitDate
    left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = datediff(yy, patient.DOB, PrepDiscontinuation.ExitDate)
	WHERE patient.voided =0;

    alter table NDWH.Fact.FactPrepDiscontinuation add primary key(FactKey);
END