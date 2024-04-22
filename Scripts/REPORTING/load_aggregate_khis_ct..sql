IF Object_id(N'[REPORTING].[dbo].[AggregateKHIS_CT]', N'U') IS NOT NULL
  DROP TABLE [REPORTING].[dbo].[aggregatekhis_ct];

SELECT dhisorgid,
       mflcode,
       facilityname,
       facility.county,
       facility.subcounty,
       ward,
       reportmonth_year,
       enrolled_total,
       startedart_total,
       currentonart_total,
       ctx_total,
       onart_12months,
       netcohort_12months,
       vlsuppression_12months,
       vlresultavail_12months,
       createdat,
       updatedat,
       start_art_under_1,
       start_art_1_9,
       start_art_10_14_m,
       start_art_10_14_f,
       start_art_15_19_m,
       start_art_15_19_f,
       start_art_20_24_m,
       start_art_20_24_f,
       start_art_25_plus_m,
       start_art_25_plus_f,
       on_art_under_1,
       on_art_1_9,
       on_art_10_14_m,
       on_art_10_14_f,
       on_art_15_19_m,
       on_art_15_19_f,
       on_art_20_24_m,
       on_art_20_24_f,
       on_art_25_plus_m,
       on_art_25_plus_f,
       partnername,
       agency                  AS AgencyName,
       Cast(Getdate() AS DATE) AS LoadDate
INTO   reporting.dbo.aggregatekhis_ct
FROM   ndwh.dbo.fact_ct_dhis2 CT
       LEFT JOIN ndwh.dbo.dimfacility facility
              ON facility.facilitykey = CT.facilitykey
       LEFT JOIN ndwh.dbo.dimpartner partner
              ON partner.partnerkey = ct.partnerkey
WHERE  mflcode IS NOT NULL; 