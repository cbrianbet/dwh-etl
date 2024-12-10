
IF OBJECT_ID(N'[REPORTING].[dbo].AggregateAdverseEvents', N'U') IS NOT NULL 
	Drop TABLE [REPORTING].[dbo].AggregateAdverseEvents

GO

with AdverseEvents as (
    SELECT
            MFLCode,
            pat.PatientKey,
            g.DATIMAgeGroup,
            pat.Gender,
            f.FacilityName,
            County,
            SubCounty,
            p.PartnerName,
            a.AgencyName,
            AdverseEvent,
            AdverseEventCause,
            AdverseEventRegimen,
            AdverseEventActionTaken,
            Severity
        FROM
            [NDWH].Fact.FactAdverseEvents it
            INNER join NDWH.Dim.DimFacility f on f.FacilityKey = it.FacilityKey
            INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = it.AgencyKey
            INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = it.PatientKey
            INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = it.PartnerKey
            INNER JOIN NDWH.Fact.FactART art on art.PatientKey = it.PatientKey
            LEFT join NDWH.Dim.DimAgeGroup g on g.Age = art.AgeLastVisit
        WHERE
            pat.IsTXCurr = 1
)

SELECT
    MFLCode,
    DATIMAgeGroup,
    Gender,
    FacilityName,
    County,
    Subcounty,
    PartnerName,
    AgencyName,
    AdverseEvent,
    AdverseEventCause,
    AdverseEventActionTaken,
    AdverseEventRegimen,
    Severity,
	count(*) as AdverseEventsCount,
	count(DISTINCT PatientKey) as AdverseClientsCount,
    cast(getdate() as date) as LoadDate
INTO [REPORTING].[dbo].AggregateAdverseEvents 
FROM AdverseEvents
GROUP BY
    MFLCode,
    DATIMAgeGroup,
    Gender,
    FacilityName,
    County,
    Subcounty,
    PartnerName,
    AgencyName,
    AdverseEvent,
    AdverseEventCause,
    AdverseEventActionTaken,
    AdverseEventRegimen,
    Severity
GO
