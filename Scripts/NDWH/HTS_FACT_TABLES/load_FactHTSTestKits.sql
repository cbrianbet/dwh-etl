IF OBJECT_ID(N'[NDWH].[Fact].[FactHTSTestKits]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[Fact].[FactHTSTestKits];
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
        distinct SiteCode,
        PatientPk,
        EncounterId,
        TestKitName1,
        TestKitLotNumber1,
        TestKitExpiry1,
        TestResult1,
        TestKitName2,
        TestKitLotNumber2,
        TestKitExpiry2,
        TestResult2
    from ODS.HTS.HTS_TestKits
    )
    select 
        FactKey = IDENTITY(INT, 1, 1),
        patient.PatientKey,
        facility.FacilityKey,
        partner.PartnerKey,
        agency.AgencyKey,
        kit_name1.TestKitNameKey as TestKitName1Key,
        TestKitLotNumber1,
        TestResult1,
        kit_name2.TestKitNameKey as TestKitName2Key,
        TestKitLotNumber2,
        TestResult2,
         cast(getdate() as date) as LoadDate
    into NDWH.Fact.FactHTSTestKits
    from source_data
    left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(source_data.PatientPK as nvarchar(36))), 2)
        and patient.SiteCode = source_data.SiteCode
    left join NDWH.Dim.DimFacility as facility on facility.MFLCode = source_data.SiteCode
    left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = source_data.SiteCode
    left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
    left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
    left join NDWH.Dim.DimTestKitName as kit_name1 on kit_name1.TestKitName = source_data.TestKitName1
    left join NDWH.Dim.DimTestKitName as kit_name2 on kit_name2.TestKitName = source_data.TestKitName2
	WHERE patient.voided =0;

alter table NDWH.Fact.FactHTSTestKits add primary key(FactKey); 

END