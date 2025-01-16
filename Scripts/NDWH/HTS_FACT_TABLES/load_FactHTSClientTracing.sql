IF OBJECT_ID(N'[NDWH].[Fact].[FactHTSClientTracing]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[Fact].[FactHTSClientTracing];

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
            SiteCode,
            PatientPk,
            TracingType,
            cast(TracingDate as date) as TracingDate,
            TracingOutcome
    from ODS.HTS.HTS_ClientTracing
    )
    select 
        Factkey = IDENTITY(INT, 1, 1),
        patient.PatientKey,
        facility.FacilityKey,
        partner.PartnerKey,
        agency.AgencyKey,
        tracing.DateKey as TracingDateKey,
        outcome.TraceOutcomeKey,
        trace_type.TraceTypeKey,
        cast(getdate() as date) as LoadDate
    into NDWH.Fact.FactHTSClientTracing
    from source_data
    left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(source_data.PatientPK as nvarchar(36))), 2)
        and patient.SiteCode = source_data.SiteCode
    left join NDWH.Dim.DimFacility as facility on facility.MFLCode = source_data.SiteCode
    left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = source_data.SiteCode
    left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
    left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
    left join NDWH.Dim.DimDate as tracing on tracing.Date = source_data.TracingDate
    left join NDWH.Dim.DimHTSTraceOutcome as outcome on outcome.TraceOutcome = source_data.TracingOutcome
    left join NDWH.Dim.DimHTSTraceType as trace_type on trace_type.TraceType = source_data.TracingType
	WHERE patient.voided =0;

    alter table NDWH.Fact.FactHTSClientTracing add primary key(FactKey);

END