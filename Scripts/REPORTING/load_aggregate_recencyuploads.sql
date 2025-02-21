IF OBJECT_ID(N'REPORTING.DBO.AggregateRecencyUploads', N'U') IS NOT NULL 
	DROP TABLE REPORTING.DBO.AggregateRecencyUploads ;

BEGIN
	with uploads as (
		SELECT 
			COUNT(DISTINCT g.MFLCode) AS recency,
			g.docket AS docket,
			g.year AS year,
			g.month AS month,
            EOMONTH(CAST(CONCAT(g.year, '-', g.month, '-01') AS DATE)) AS AsofDate,
			g.county AS county,
			g.subcounty AS subcounty,
			g.agency AS agency,
			g.partner AS partner,
            CAST(GETDATE() AS DATE) AS LoadDate 
		FROM
			(SELECT 
				fm.facilityId AS MFLCode,
				CASE
					WHEN
						(f.isCT = 1 AND fm.docketId = 'CT')
					THEN
						'CT'
					WHEN
						(f.isPkv = 1 AND fm.docketId = 'PKV')
					THEN
						'PKV'
					WHEN
						(f.isHts = 1 AND fm.docketId = 'HTS')
					THEN
						'HTS'
				END AS docket,
				year(timeId) AS year,
				month(timeId) AS month,
				f.county AS county,
				f.subCounty AS subcounty,
				a.SDP_Agency AS agency,
				a.SDP AS partner
			FROM
				NDWH.Fact.fact_manifest fm
				JOIN NDWH.Dim.DimFacility f ON fm.facilityId = f.MFLCode
				JOIN ODS.Care.All_EMRSites a on a.MFL_Code = fm.facilityId
			) g
		WHERE
			g.docket IS NOT NULL
		GROUP BY 
            g.docket,
            g.year, 
            g.month, 
            g.county, 
            g.subcounty, 
            g.agency, 
            g.partner,
            EOMONTH(CAST(CONCAT(g.year, '-', g.month, '-01') AS DATE))
	) 
	select
         * 
    into REPORTING.DBO.AggregateRecencyUploads  
    from uploads
END