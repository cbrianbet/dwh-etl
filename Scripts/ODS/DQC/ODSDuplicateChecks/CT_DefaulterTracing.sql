with cte AS (
							Select
							PatientPK,
							Sitecode,
							visitID,
							visitDate,

								ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
							PatientPK,Sitecode,visitID,visitDate) Row_Num
							FROM [ODS].[dbo].[CT_DefaulterTracing](NoLock))
							
							Select count(*) from cte 
								Where Row_Num >1 ;