with cte AS (
						Select
						Sitecode,
						PatientPK,
						Contactage,
						RelationshipWithPatient,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,Contactage,RelationshipWithPatient ORDER BY
						PatientPK,Sitecode,Contactage,RelationshipWithPatient) Row_Num
						FROM [ODS].[dbo].[CT_ContactListing](NoLock)
						)
						Select count(*) from cte 
						Where Row_Num >1 ;