IF OBJECT_ID(N'NDWH.Fact.Fact_manifest ', N'U') IS NOT NULL 
	DROP TABLE NDWH.Fact.Fact_manifest ;
BEGIN
	with MFL_partner_agency_combination as (
    select 
        distinct MFL_Code,
        SDP ,
        SDP_Agency  as Agency
    from ODS.Care.All_EMRSites 
    ),
    Fact_manifest  as(
		Select
			ID as  manifestId,
			Cast(max(m.DateRecieved) as date) timeId,
			max(m.SiteCode) facilityId,
			max(coalesce(h.emr,'Unkown')) emrId,
			'CT' docketId,
			1 upload,
			[Start],
			[End],
			cast(getdate() as date) as LoadDate
		from ODS.Care.CT_FacilityManifest m 
			inner join ODS.Care.ALL_EMRSites h
		on m.SiteCode=h.MFL_Code
						GROUP BY ID,[start],[end],YEAR(m.DateRecieved), 
					MONTH(m.DateRecieved), SiteCode 

		UNION ALL 

		SELECT  Id  AS manifestId, 
				CAST(MAX(m.DateArrived) AS DATE) AS timeId,
				MAX(m.SiteCode) AS facilityId, 
				MAX(COALESCE(h.emr, 'Unknown')) AS emrId, 
				'HTS' AS docketId, 
				1 AS upload,
				[Start],
			    [End],
				cast(getdate() as date) as LoadDate
		FROM ODS.HTS.HTS_FacilityManifest m 
			INNER JOIN ODS.Care.ALL_EMRSites h ON m.SiteCode = h.MFL_Code 
		GROUP BY    ID,[start],[end],
        YEAR(DateArrived), 
					MONTH(DateArrived), SiteCode 

			UNION ALL 

		SELECT Id AS manifestId, 
				CAST(MAX(m.DateArrived) AS DATE) AS timeId, 
				MAX(m.SiteCode) AS facilityId,
				MAX(COALESCE(h.emr, 'Unknown')) AS emrId,
				'PKV' AS docketId, 
				1 AS upload ,
				[Start],
			    [End],
				 cast(getdate() as date) as LoadDate
		FROM ODS.Care.CBS_FacilityManifest m INNER JOIN ODS.Care.all_emrsites h ON m.SiteCode = h.MFL_Code 
		GROUP BY ID,[start],[end],
        YEAR(DateArrived), 
					MONTH(DateArrived), SiteCode
	)
	SELECT 
			FactKey= IDENTITY(INT,1,1),
	         manifestId,
			 timeId,
			 facilityId,
			 emrId,
			 docketId,
			 upload,
			 partner.PartnerKey,
             agency.AgencyKey,
             started.DateKey as StartDateKey,
             ended.DateKey as EndDateKey,
			 cast (GETDATE() as date) as Loaddate
	INTO NDWH.Fact.Fact_manifest
	FROM Fact_manifest as  manifest
	left join NDWH.Dim.DimFacility as facility on facility.MFLCode=manifest.facilityId
    left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code=manifest.facilityId
    left join NDWH.Dim.DimPartner as partner on partner.PartnerName=MFL_partner_agency_combination.SDP collate Latin1_General_CI_AS
    left join NDWH.Dim.DimAgency as agency on Agency.AgencyName=MFL_partner_agency_combination.Agency collate Latin1_General_CI_AS
    left join NDWH.Dim.DimDate as UploadDates on UploadDates.Date = manifest.timeId
    left join NDWH.Dim.DimDate as started on started.Date = manifest.[Start]
    left join NDWH.Dim.DimDate as ended on ended.Date = manifest.[End]

    alter table NDWH.Fact.Fact_manifest add primary key(FactKey)
END
