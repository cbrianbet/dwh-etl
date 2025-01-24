if object_id(N'[NDWH].[Fact].[FactEACVisitsLastTwoYears]', N'U') is not null
	drop table [NDWH].[Fact].FactEACVisitsLastTwoYears;
begin 

    with MFL_partner_agency_combination as (
        select 
            distinct MFL_Code,
            SDP,
            [SDP_Agency]  as Agency
        from ODS.Care.All_EMRSites 
    )
    select 
        Factkey = IDENTITY(INT, 1, 1),
        patient.PatientKey,
        facility.FacilityKey,
        partner.PartnerKey,
        agency.AgencyKey,
        age_group.AgeGroupKey,
        visit_date.DateKey as VisitDateKey,
        PillCountAdherence,
        EACRecievedVL,
        EACVL,
        EACAdherencePlan
    into NDWH.Fact.FactEACVisitsLastTwoYears
    from ODS.Care.CT_EnhancedAdherenceCounselling as eac 
    left join NDWH.Dim.DimFacility as facility on facility.MFLCode = eac.SiteCode
    left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = eac.PatientPKHash
        and patient.SiteCode = eac.SiteCode
    left join NDWH.Dim.DimDate as visit_date on visit_date.[Date] = cast(eac.VisitDate as date)
    left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = eac.SiteCode
    left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
    left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
    left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = datediff(year, patient.DOB, cast(eac.VisitDate as date))
    where eac.VisitDate >= eomonth(dateadd(month, -24, getdate())) -- filtering EAC sessions for the last 2 years


    alter table NDWH.Fact.FactEACVisitsLastTwoYears add primary key(FactKey);

end