with cte AS (
						Select
						PatientPK,
						sitecode,
						visitID,
						DispenseDate,
						drug,
						 ROW_NUMBER() OVER (PARTITION BY PatientPK,sitecode,visitID,DispenseDate,drug ORDER BY
						DispenseDate desc) Row_Num
						FROM [ODS].[dbo].[CT_PatientPharmacy](NoLock)
						)
					Select count(*) from cte 
						Where Row_Num >1;
