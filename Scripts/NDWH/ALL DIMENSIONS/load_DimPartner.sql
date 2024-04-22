MERGE [NDWH].[dbo].[DimPartner] AS a
		USING	(	SELECT DISTINCT SDP as PartnerName
					FROM [ODS].[dbo].[All_EMRSites](NoLock)
					WHERE SDP IS NOT NULL
				) AS b 
						ON(
							a.PartnerName = b.PartnerName
						  )
		WHEN NOT MATCHED THEN 
						INSERT(PartnerName,LoadDate) 
						VALUES(PartnerName,GetDate())
		WHEN MATCHED THEN
						UPDATE  						
							SET a.PartnerName =b.PartnerName;
