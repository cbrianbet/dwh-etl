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
   NDWH.Fact.FactHTSPosConcordance as htspos 
   LEFT join
      NDWH.Dim.DimFacility fac 
      on fac.FacilityKey = htspos.FacilityKey 
   LEFT JOIN
      NDWH.Dim.DimAgency agency 
      on agency.AgencyKey = htspos.AgencyKey 
   LEFT JOIN
      NDWH.Dim.DimPartner pat 
      on pat.PartnerKey = htspos.PartnerKey 
ORDER BY
   Proportion_variance_EMR_DWH DESC

 