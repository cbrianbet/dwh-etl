with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						visitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
						PatientPK,Sitecode,visitID,visitDate) Row_Num
						FROM [ODS].[dbo].[CT_Otz](NoLock)
						)
					delete from cte 
						Where Row_Num >1 ;

					INSERT INTO [ODS_Logs].[dbo].[CT_OtzCount_Log]([SiteCode],[CreatedDate],[OtzCount])
					SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS OtzCount 
					FROM [ODS].[dbo].[CT_Otz]
					GROUP BY SiteCode;