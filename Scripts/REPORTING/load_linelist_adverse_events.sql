IF OBJECT_ID(N'[REPORTING].[dbo].LineListAdverseEvents', N'U') IS NOT NULL 		
	drop TABLE [REPORTING].[dbo].LineListAdverseEvents

GO

with AdverseEvents as (
 SELECT
            MFLCode,
            PatientIDHash,
            PatientPKHash,
            NUPI,
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
            Severity,
            CAST(GETDATE() AS DATE) AS LoadDate 
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
   *
 INTO [REPORTING].[dbo].LineListAdverseEvents
FROM AdverseEvents
GO
