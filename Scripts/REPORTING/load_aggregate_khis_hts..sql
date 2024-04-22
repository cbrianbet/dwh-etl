If Object_id(N'[REPORTING].[dbo].[Aggregate_khis_hts]', N'U') Is Not Null
  Drop Table [Reporting].[Dbo].[Aggregate_khis_hts];

Begin
    Select [Mflcode],
           [Facility].Facilityname,
           Facility.County,
           Facility.Subcounty,
           [Reportmonth_year],
           [Tested_total],
           [Positive_total],
           [Createdat],
           [Updatedat],
           [Tested_1_9],
           [Tested_10_14_m],
           [Tested_10_14_f],
           [Tested_15_19_m],
           [Tested_15_19_f],
           [Tested_20_24_m],
           [Tested_20_24_f],
           [Tested_25_plus_m],
           [Tested_25_plus_f],
           [Positive_1_9],
           [Positive_10_14_m],
           [Positive_10_14_f],
           [Positive_15_19_m],
           [Positive_15_19_f],
           [Positive_20_24_m],
           [Positive_20_24_f],
           [Positive_25_plus_m],
           [Positive_25_plus_f],
           Partner.Partnername,
           Agency                  As AgencyName,
           Cast(Getdate() As Date) As LoadDate
    Into   Reporting.Dbo.Aggregate_khis_hts
    From   Ndwh.Dbo.Fact_hts_dhis2 Ct
           Left Join Ndwh.Dbo.Dimfacility Facility
                  On Facility.Facilitykey = Ct.Facilitykey
           Left Join Ndwh.Dbo.Dimpartner Partner
                  On Partner.Partnerkey = Ct.Partnerkey
           Left Join Ndwh.Dbo.Dimagency Agency
                  On Agency.Agencykey = Ct.Agencykey
    Where  Mflcode Is Not Null
End 