IF OBJECT_ID(N'[REPORTING].[dbo].Aggregate_Concordance_Txcurr', N'U') IS NOT NULL drop table [REPORTING].[dbo].Aggregate_Concordance_Txcurr 
Select
   MFLCode,
   FacilityName,
   County,
   PartnerName,
   Agency,
   txcurr.EMR,
   date.Date as SiteAbstractionDate,
   KHIS_TxCurr,
   DWH_TxCurr,
   EMR_TxCurr,
   Diff_EMR_DWH,
   DiffKHISDWH,
   DiffKHISEMR,
   Proportion_variance_EMR_DWH,
   Proportion_variance_KHIS_DWH,
   Proportion_variance_KHIS_EMR ,
   DwapiVersion
   into Reporting.dbo.Aggregate_Concordance_Txcurr
  
from
   NDWH.Fact.FACTTxCurrConcordance as txcurr 
   LEFT join
      NDWH.Dim.DimFacility fac 
      on fac.FacilityKey = txcurr.FacilityKey 
   LEFT JOIN
      NDWH.Dim.DimAgency agency 
      on agency.AgencyKey = txcurr.AgencyKey 
   LEFT JOIN
      NDWH.Dim.DimPartner pat 
      on pat.PartnerKey = txcurr.PartnerKey
   LEFT JOIN 
      NDWH.Dim.DimDate as date 
      on date.DateKey =  txcurr.SiteAbstractionDateKey
ORDER BY
   Proportion_variance_EMR_DWH DESC