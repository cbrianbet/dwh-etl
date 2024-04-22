IF OBJECT_ID(N'[NDWH].[dbo].FactTxCurrConcordance', N'U') IS NOT NULL 		
	drop table [NDWH].[dbo].FactTxCurrConcordance
GO

WITH NDW_CurTx AS (
                SELECT
                     SiteCode,
                   Count(*) AS CurTx_total
                FROM NDWH.dbo.DimPatient as Patient
                WHERE isTXcurr =1
                group by SiteCode
            
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
            Facilityinfo AS (
                Select
                    MFL_Code,
                    Facility_Name,
                    County,
                    SDP as PartnerName,
                    SDP_Agency as Agency,
                    EMR
                from ODS.dbo.All_EMRSites
            ),
            EMR As (
                SELECT
                    Row_Number () over (partition by FacilityCode order by statusDate desc) as Num,
                    facilityCode
                    ,facilityName
                    ,[value]
                    ,statusDate
                    ,indicatorDate
                FROM ODS.dbo.livesync_Indicator
                where stage like '%EMR' and name like '%TX_CURR' and indicatorDate= EOMONTH(DATEADD(mm,-1,GETDATE()))
            ),
            DHIS2_CurTx AS (
                SELECT
                    [SiteCode],
                    [FacilityName],
                    [County],
                    [CurrentOnART_Total],
                    ReportMonth_Year
                FROM [ODS].[dbo].[CT_DHIS2]
                WHERE ReportMonth_Year =CONVERT(VARCHAR(6), DATEADD(MONTH, -1, GETDATE()), 112) and ISNUMERIC(SiteCode) >0
            ),
            LatestEMR AS (
                Select
                    Emr.facilityCode
                    ,Emr.facilityName
                    ,CAST(CONVERT (varchar,Emr.[value] ) AS DECIMAL(10, 4)) As EMRValue
                    ,Emr.statusDate
                    ,Emr.indicatorDate
                from EMR
                where Num=1
            ),
            Uploads as (
                Select  [DateRecieved],ROW_NUMBER()OVER(Partition by Sitecode Order by [DateRecieved] Desc) as Num ,
                    SiteCode,
                    cast( [DateRecieved]as date) As DateReceived,
                    EmrName as   Emr,
                    Name,
                    Start,
                    PatientCount
                from ODS.dbo.CT_FacilityManifest
                where cast  (DateRecieved as date)> DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0) --First day of previous month
                and cast (DateRecieved as date) <= DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1) --Last Day of previous month
            ),
            LatestUploads AS (
                Select
                    SiteCode,
                    cast( [DateRecieved]as date) As DateReceived,
                    Emr,
                    Name,
                    Start,
                    PatientCount
                from Uploads
                where Num=1
            ),
            Received As (
                Select distinct
                Fac.MFL_Code,
                fac.Facility_Name,
                Count (*) As Received
            FROM [ODS].[dbo].[CT_Patient](NoLock) Patient
            INNER JOIN [ODS].[dbo].[all_EMRSites](NoLock) Fac ON Patient.[SiteCode] = Fac.MFL_Code AND Patient.Voided=0 and Patient.SiteCode>0
            group by
                Fac.MFL_Code,
                fac.Facility_Name
            ),
            Facilities AS (
                Select distinct
                    MFL_Code ,
                    Facility_Name,
                    SDP as PartnerName,
                    SDP_Agency as AgencyName
                from ODS.dbo.all_EMRSites
            ),
            Combined AS (
                Select distinct
                   MFL_Code ,
                    Facility_Name,
                    PartnerName,
                    AgencyName,
                    LatestUploads.DateReceived,
                    LatestUploads.PatientCount As ExpectedPatients
                from Facilities
                left join LatestUploads on Facilities.MFL_Code =LatestUploads.SiteCode
            ),
            Uploaddata AS (
                Select
                    Combined.MFL_Code ,
                    Combined.Facility_Name,
                    PartnerName,
                    AgencyName,
                    DateReceived,
                    ExpectedPatients,
                    Received.Received as CompletenessStatus
                from Combined
                left join Received on Combined.MFL_Code=Received.MFL_Code
                where Received<ExpectedPatients
            ),
            DWAPI AS (
                SELECT
                Sitecode,
                 DwapiVersion,
                 Docket
                        From ODS.dbo.CT_FacilityManifestCargo 
            ),
            Summary As (Select
                coalesce (NDW_CurTx.SiteCode, null ) As MFLCode,
                fac.Facility_Name As FacilityName,
                fac.PartnerName,
                fac.County,
                fac.emr as EMR,
                DHIS2_CurTx.CurrentOnART_Total As KHIS_TxCurr,
                NDW_CurTx.CurTx_total AS DWH_TXCurr,
                CAST(ROUND(LatestEMR.EMRValue, 2) AS float) AS EMR_TxCurr,
                CAST(ROUND(LatestEMR.EMRValue - CurTx_total, 2) AS float) AS Diff_EMR_DWH,
                DHIS2_CurTx.CurrentOnART_Total-CurTx_total As DiffKHISDWH,
                CAST(ROUND(DHIS2_CurTx.CurrentOnART_Total - LatestEMR.EMRValue, 2) AS FLOAT) AS DiffKHISEMR,
                CAST(ROUND((CAST(LatestEMR.EMRValue AS DECIMAL(7,2)) - CAST(NDW_CurTx .CurTx_total AS DECIMAL(7,2)))
                /NULLIF(CAST(LatestEMR.EMRValue  AS DECIMAL(7,2)),0)* 100, 2) AS float) AS Percent_variance_EMR_DWH,
                CAST(ROUND((CAST(DHIS2_CurTx.CurrentOnART_Total AS DECIMAL(7,2)) - CAST(NDW_CurTx .CurTx_total AS DECIMAL(7,2)))
                /CAST(DHIS2_CurTx.CurrentOnART_Total  AS DECIMAL(7,2))* 100, 2) AS float) AS Percent_variance_KHIS_DWH,
                CAST(ROUND((CAST(DHIS2_CurTx.CurrentOnART_Total AS DECIMAL(7,2)) - CAST(LatestEMR.EMRValue AS DECIMAL(7,2)))
                /CAST(DHIS2_CurTx.CurrentOnART_Total  AS DECIMAL(7,2))* 100, 2) AS float) AS Percent_variance_KHIS_EMR,
                cast (Upload.DateUploaded as date) As DateUploaded,
                case when CompletenessStatus is null then 'Complete' else 'Incomplete' End As Completeness,
                DWAPI.DwapiVersion
            from NDW_CurTx
            left join LatestEMR on NDW_CurTx.SiteCode=LatestEMR.facilityCode
            LEFT JOIN DWAPI ON DWAPI.SiteCode= LatestEMR.facilityCode
            left join DHIS2_CurTx on NDW_CurTx.SiteCode=DHIS2_CurTx.SiteCode COLLATE Latin1_General_CI_AS
            left join Upload on NDW_CurTx.SiteCode=Upload.SiteCode
            left join Uploaddata on NDW_CurTx.SiteCode=Uploaddata.MFL_Code COLLATE Latin1_General_CI_AS
            left join Facilityinfo fac on NDW_CurTx.SiteCode=fac.MFL_Code
            

            )
            Select 
            FactKey = IDENTITY(INT, 1, 1),
		    facility.FacilityKey,
		    partner.PartnerKey,
		    agency.AgencyKey ,
            Summary.EMR,
             KHIS_TxCurr,
             DWH_TXCurr,
             EMR_TxCurr,
            Diff_EMR_DWH,
            DiffKHISDWH,
            DiffKHISEMR,
            Percent_variance_EMR_DWH as Proportion_variance_EMR_DWH,
            Percent_variance_KHIS_DWH as Proportion_variance_KHIS_DWH ,
            Percent_variance_KHIS_EMR as Proportion_variance_KHIS_EMR,
            dwapi.DwapiVersion
            into [NDWH].[dbo].FactTxCurrConcordance
            from Summary
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = Summary.MFLCode
left join Facilityinfo on Facilityinfo.MFL_Code=Summary.MFLCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = Facilityinfo.PartnerName
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = Facilityinfo.Agency
left join DWAPI on DWAPI.SiteCode=Summary.MFLCode
alter table NDWH.dbo.FactTxCurrConcordance add primary key(FactKey);

