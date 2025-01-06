BEGIN

		MERGE [ODS].[Care].[livesync_Indicator] AS a
			USING(SELECT DISTINCT [id],[facilityCode],
								  CAST([facilityName] AS NVARCHAR(150)) AS facilityName,CAST([name]AS NVARCHAR(150)) AS [Name],
						          CAST([value] AS NVARCHAR(150)) AS [value],[indicatorDate],
					              CAST([stage] AS NVARCHAR(150)) AS [stage],[facilityManifestId],
					              CAST([status] AS NVARCHAR(150)) AS [status],[statusDate],
					              CAST([statusInfo]  AS NVARCHAR(150)) AS [statusInfo]
					FROM [livesync].[dbo].[indicator] ) AS b 
					ON(
						a.ID = b.ID						
					)

				WHEN NOT MATCHED THEN 
					INSERT(id,facilityCode,facilityName,name,value,indicatorDate,stage,facilityManifestId,status,statusDate,statusInfo,LoadDate)  
					VALUES(id,facilityCode,facilityName,name,value,indicatorDate,stage,facilityManifestId,status,statusDate,statusInfo,Getdate());
				
					
	END
