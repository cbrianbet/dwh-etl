
MERGE [NDWH].[Dim].[DimRegimenLine] AS a
		USING(	SELECT DISTINCT StartRegimenLine as RegimenLine 
				FROM ODS.Care.CT_ARTPatients 
				WHERE 	StartRegimenLine IS NOT NULL
						AND StartRegimenLine <>''
				UNION 
				SELECT 
					DISTINCT LTRIM(RTRIM(LastRegimenLine)) AS RegimenLine 
				FROM ODS.Care.CT_ARTPatients
				WHERE LastRegimenLine IS NOT NULL AND LastRegimenLine<>''
				) AS b 
						ON(
						a.RegimenLine = b.RegimenLine
						  )
		WHEN NOT MATCHED THEN 
						INSERT(RegimenLine,LoadDate) 
						VALUES(RegimenLine,GetDate())
		WHEN MATCHED THEN
						UPDATE SET 						
						a.RegimenLine =b.RegimenLine;

UPDATE source_regimen_line
	SET RegimenLineCategory = CASE 
							WHEN RegimenLine IN ('1st line','Adult ART FirstLine','Adult first line','Adult FirstLine','Child first line','First line','First line substitute','Paeds ART FirstLine','1st Alternative', 'Child FirstLine') THEN 'First Line'
							WHEN RegimenLine IN ('Adult ART SecondLine','Adult second line','Adult SecondLine','Child SecondLine','Paeds ART Secondline','Second line','Second line substitute', '2nd Line') THEN 'Second Line'
							WHEN RegimenLine IN ('Adult ART ThirdLine ','Adult ThirdLine','Child ThirdLine','Third line','Adult ART ThirdLine') THEN 'Third Line'
							WHEN RegimenLine IN ('unknown') THEN 'Unknown'
							WHEN RegimenLine IN ('PMTCT Maternal Regimens', 'PMTCT Regimens') THEN 'PMTCT'
							WHEN RegimenLine IN ('Other') THEN 'Other'
							ELSE 'Unknown'
					  END
FROM [NDWH].[Dim].[DimRegimenLine] source_regimen_line


						 