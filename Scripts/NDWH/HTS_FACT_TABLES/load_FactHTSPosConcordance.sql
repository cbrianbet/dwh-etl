
IF OBJECT_ID(N'[NDWH].[dbo].FactHTSPosConcordance', N'U') IS NOT NULL 		
	drop table [NDWH].[dbo].FactHTSPosConcordance
GO

WITH HTSPos AS (
                SELECT
                     SiteCode,
                    SUM(CASE WHEN FinalTestResult = 'Positive' THEN 1 ELSE 0 END) AS HTSPos_total,
                    TestDate
                FROM ODS.dbo.Intermediate_EncounterHTSTests link
                where link.TestDate  between  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0) and DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1) and FinalTestResult='Positive' and SiteCode is not null and TestType in ('Initial Test', 'Initial')
                GROUP BY SiteCode, TestDate
            ),

 MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency
	from ODS.dbo.All_EMRSites 
),

NDW_HTSPos As (Select 
  hts_encounter.SiteCode,
Facility_Name,
SDP as PartnerName,
emr.County,
count (*) as HTSPos_total
from ODS.dbo.Intermediate_EncounterHTSTests as hts_encounter
left join ODS.dbo.ALL_EMRSites as emr on emr.MFL_Code = hts_encounter.SiteCode
WHERE  TestDate  between  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0) and DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1) and FinalTestResult='Positive' and SiteCode is not null and TestType in ('Initial Test', 'Initial')
   Group by SiteCode, Facility_Name, SDP, County	

),

                AllUpload as (
                SELECT
                   DateRecieved as DateUploaded,
                    [SiteCode],
                    ROW_NUMBER()OVER(Partition by Sitecode Order by DateRecieved Desc) as Num
                FROM ods.dbo.CT_FacilityManifest m
                ),
            Upload As (
				SELECT distinct
					SiteCode,
					DateUploaded
                from AllUpload
				WHERE Num = 1
            ),
            EMR As (SELECT
                Row_Number () over (partition by FacilityCode order by statusDate desc) as Num,
                    facilityCode
                    ,facilityName
                    ,[value]
                    ,statusDate
                    ,indicatorDate
                FROM ODS.dbo.livesync_Indicator
                where stage like '%EMR' and name like '%HTS_TESTED_POS' and indicatorDate=EOMONTH(DATEADD(mm,-1,GETDATE())) and facilityCode is not null
            ),
            Facilityinfo AS (
                Select
                    MFL_Code,
                    County,
                    SDP,
                    EMR
                from ODS.dbo.All_EMRSites
            ),
            DHIS2_HTSPos AS (
                SELECT
                    try_cast([SiteCode] as int) SiteCode,
                    [FacilityName] As  FacilityName,
                    [County],
                    Positive_Total,
                    ReportMonth_Year
                FROM [ODS].[dbo].HTS_DHIS2
               WHERE ReportMonth_Year =CONVERT(VARCHAR(6), DATEADD(MONTH, -1, GETDATE()), 112) and ISNUMERIC(SiteCode) >0
            ),
            LatestEMR AS (
                Select
                    Emr.facilityCode 
                    ,Emr.facilityName
                    ,CONVERT (varchar,Emr.[value] ) As EMRValue
                    ,Emr.statusDate
                    ,Emr.indicatorDate
                from EMR
                where Num=1 and Emr.facilityCode is not null
            ),
            DWAPI AS (
                SELECT
                Sitecode,
                 DwapiVersion,
                 Docket
                        From ODS.dbo.CT_FacilityManifestCargo 
            ) ,
            Summary As (Select
                coalesce (DHIS2_HTSPos.SiteCode, NDW_HTSPos.sitecode,LatestEMR.facilityCode ) As MFLCode,
                Coalesce (NDW_HTSPos.Facility_Name, DHIS2_HTSPos.FacilityName) As FacilityName,
                fac.SDP As SDP,
                fac.emr as EMR,
                Coalesce (NDW_HTSPos.County, DHIS2_HTSPos.County) As County,
                DHIS2_HTSPos.Positive_Total As KHIS_HTSPos,
                coalesce (NDW_HTSPos.HTSPos_total, 0 )AS DWH_HTSPos,
                LatestEMR.EMRValue As EMR_HTSPos,
                LatestEMR.EMRValue-HTSPos_total As Diff_EMR_DWH,
                DHIS2_HTSPos.Positive_Total-HTSPos_total As DiffKHISDWH,
                DHIS2_HTSPos.Positive_Total-LatestEMR.EMRValue As DiffKHISEMR,
				CAST(ROUND((CAST(LatestEMR.EMRValue AS DECIMAL(7,2)) - CAST(coalesce(NDW_HTSPos.HTSPos_total, null) AS DECIMAL(7,2)))
                /NULLIF(CAST(LatestEMR.EMRValue  AS DECIMAL(7,2)),0)* 100, 2) AS float) AS Percent_variance_EMR_DWH,
                CAST(ROUND((CAST(DHIS2_HTSPos.Positive_Total AS DECIMAL(7,2)) - CAST(NDW_HTSPos.HTSPos_total AS DECIMAL(7,2)))
                /CAST(DHIS2_HTSPos.Positive_Total  AS DECIMAL(7,2))* 100, 2) AS float) AS Percent_variance_KHIS_DWH,
                CAST(ROUND((CAST(DHIS2_HTSPos.Positive_Total AS DECIMAL(7,2)) - CAST(LatestEMR.EMRValue AS DECIMAL(7,2)))
                /CAST(DHIS2_HTSPos.Positive_Total  AS DECIMAL(7,2))* 100, 2) AS float) AS Percent_variance_KHIS_EMR,
                cast (Upload.DateUploaded as date) As DateUploaded,
                DWAPI.DwapiVersion
            from DHIS2_HTSPos
            left join LatestEMR on DHIS2_HTSPos.sitecode=LatestEMR.facilityCode
			LEFT JOIN DWAPI ON DWAPI.SiteCode= LatestEMR.facilityCode
            left join NDW_HTSPos on NDW_HTSPos.sitecode=DHIS2_HTSPos.SiteCode
            left join Upload on NDW_HTSPos.SiteCode=Upload.SiteCode
            left join Facilityinfo fac on DHIS2_HTSPos.SiteCode=fac.MFL_Code
            where DHIS2_HTSPos.Positive_Total is not null
           
            )
            Select 
            FactKey = IDENTITY(INT, 1, 1),
		    facility.FacilityKey,
		    partner.PartnerKey,
		    agency.AgencyKey ,
            Summary.EMR,
            KHIS_HTSPos,
            DWH_HTSPos,
            EMR_HTSPos,
            Diff_EMR_DWH,
            DiffKHISDWH,
            DiffKHISEMR,
            Percent_variance_EMR_DWH as Proportion_variance_EMR_DWH,
            Percent_variance_KHIS_DWH as Proportion_variance_KHIS_DWH,
            Percent_variance_KHIS_EMR as Proportion_variance_KHIS_EMR,
            EOMONTH(DATEADD(mm,-1,GETDATE())) as Reporting_Month,
            dwapi.DwapiVersion,
           Cast(getdate() as date) as LoadDate
        into NDWH.dbo.FactHTSPosConcordance
        from Summary
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = Summary.MFLCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = Summary.MFLCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = Summary.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join DWAPI on DWAPI.SiteCode=Summary.MFLCode
 ORDER BY Percent_variance_EMR_DWH DESC



