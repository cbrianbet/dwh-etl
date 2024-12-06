MERGE ODS.[Care].CT_FacilityManifestCargo AS a
	USING
	(SELECT *
		FROM
			(SELECT
				ROW_NUMBER ( ) OVER ( PARTITION BY fm.Sitecode ORDER BY CAST ( DateRecieved AS DATE ) DESC, JSON_VALUE(Items, '$.Version') DESC ) AS NUM,
				fm.SiteCode,
				JSON_VALUE ( Items, '$.Version' ) AS DwapiVersion,
				JSON_VALUE ( Items, '$.Name' ) AS Docket,
				fc.ID as FacilityManifestCargoId,
				fc.CargoType
			FROM
				( SELECT DISTINCT p.SiteCode FROM ODS.dbo.CT_Patient p INNER JOIN ODS.dbo.ALL_EMRSites f ON f.MFL_Code= p.SiteCode AND p.Voided= 0 AND p.SiteCode > 1 ) p
				LEFT JOIN ODS.dbo.CT_FacilityManifest fm ON p.SiteCode= fm.SiteCode
				JOIN DWAPICentral.dbo.FacilityManifestCargo fc ON fc.FacilityManifestId= fm.Id
				AND CargoType = 2
                        ) Y
                WHERE Num = 1
			)As b
on a.sitecode = b.sitecode
		
WHEN NOT MATCHED THEN
		INSERT ([NUM],[SiteCode],[DwapiVersion],[Docket],FacilityManifestCargoId,CargoType)
		VALUES([NUM],[SiteCode],[DwapiVersion],[Docket],FacilityManifestCargoId,CargoType)
WHEN MATCHED THEN
		UPDATE SET 
								a.[DwapiVersion]			=b.[DwapiVersion],
								a.[Docket]					=b.[Docket],
								a.FacilityManifestCargoId	= b.FacilityManifestCargoId,
								a.CargoType					=b.CargoType;