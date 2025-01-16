	with cte AS (
								Select
								PatientPK,
								sitecode,
								lastvisit,
								 ROW_NUMBER() OVER (PARTITION BY PatientPK,sitecode ORDER BY
								lastvisit desc) Row_Num
								FROM [ODS].[dbo].[CT_ARTPatients](NoLock)
								)
							Select count(*) from cte 
								Where Row_Num >1;