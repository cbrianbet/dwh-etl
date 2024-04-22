IF OBJECT_ID(N'[NDWH].[dbo].[FactHTSPartnerNotificationServices]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactHTSPartnerNotificationServices];

BEGIN

    with MFL_partner_agency_combination as (
        select 
            distinct MFL_Code,
            SDP,
            SDP_Agency as Agency
        from ODS.dbo.All_EMRSites 
    ),
    source_data as (
        select 
            PatientPK,
            SiteCode,
            FacilityName,
            HtsNumber,
            Emr,
            Project,
			CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(PartnerPatientPk as NVARCHAR(36))), 2) As PartnerPatientPk,
            IndexPatientPkHash,
            KnowledgeOfHivStatus,
            PartnerPersonID,            
            CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(CccNumber as NVARCHAR(36))), 2) As CCCNumber,
            IpvScreeningOutcome,
            ScreenedForIpv,
            PnsConsent,
            RelationsipToIndexClient,
            LinkedToCare,
            MaritalStatus,
            PnsApproach,
            FacilityLinkedTo,
            Gender,
            CurrentlyLivingWithIndexClient,
            Age,
            DateElicited,
            Dob,
            LinkDateLinkedToCare,
			dateDiff(yy,Dob,DateElicited) as AgeAtElicitation,
            cast(getdate() as date) as LoadDate
            
            


        from ODS.dbo.HTS_PartnerNotificationServices
    )
    select 
        Factkey = IDENTITY(INT, 1, 1),
        patient.PatientKey,
        facility.FacilityKey,
        partner.PartnerKey,
        agency.AgencyKey,
		age_group.AgeGroupKey,
        PartnerPatientPk,
        IndexPatientPkHash,
        KnowledgeOfHivStatus,
        PartnerPersonID,
        CCCNumber,
        IpvScreeningOutcome,
        ScreenedForIpv,
        PnsConsent,
        RelationsipToIndexClient,
        LinkedToCare,
        source_data.MaritalStatus As PartnerMaritalStatus,
        PnsApproach,
        FacilityLinkedTo,
        CurrentlyLivingWithIndexClient,
        DateElicited.Datekey as DateElicitedKey,
        LinkDateLinkedToCare.DateKey as DateLinkedToCareKey,
        cast(getdate() as date) as LoadDate
    into NDWH.dbo.FactHTSPartnerNotificationServices
    from source_data
    left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(source_data.PatientPK as nvarchar(36))), 2)
        and patient.SiteCode = source_data.SiteCode
    left join NDWH.dbo.DimFacility as facility on facility.MFLCode = source_data.SiteCode
    left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = source_data.SiteCode
    left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
    left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
    left join NDWH.dbo.DimDate as DateElicited on DateElicited.Date = source_data.DateElicited
    left join NDWH.dbo.DimDate as LinkDateLinkedToCare on LinkDateLinkedToCare.Date = source_data.LinkDateLinkedToCare
    left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = source_data.AgeAtElicitation
	WHERE patient.voided =0;


    alter table NDWH.dbo.FactHTSPartnerNotificationServices add primary key(FactKey);

END