IF OBJECT_ID(N'[REPORTING].[dbo].Aggregate_Concordance_HTSPOS', N'U') IS NOT NULL drop table [REPORTING].[dbo].Aggregate_Concordance_HTSPOS
Select
   MFLCode,
   FacilityName,
   County,
   PartnerName,
   Agency,
   KHIS_HTSPos,
   DWH_HTSPos,
   EMR_HTSPos,
   Diff_EMR_DWH,
   DiffKHISDWH,
   DiffKHISEMR,
   Proportion_variance_EMR_DWH,
   Proportion_variance_KHIS_DWH,
   Proportion_variance_KHIS_EMR,
   Reporting_Month,
   DwapiVersion
   into Reporting.dbo.Aggregate_Concordance_HTSPOS
from
   NDWH.dbo.FactHTSPosConcordance as htspos 
   LEFT join
      NDWH.dbo.DimFacility fac 
      on fac.FacilityKey = htspos.FacilityKey 
   LEFT JOIN
      NDWH.dbo.DimAgency agency 
      on agency.AgencyKey = htspos.AgencyKey 
   LEFT JOIN
      NDWH.dbo.DimPartner pat 
      on pat.PartnerKey = htspos.PartnerKey 
ORDER BY
   Proportion_variance_EMR_DWH DESC

 