with cte AS (
				Select
				PatientPK,
				sitecode,

				 ROW_NUMBER() OVER (PARTITION BY PatientPK,sitecode ORDER BY
				PatientPK,sitecode) Row_Num
				FROM [ODS].[DBO].CT_PatientBaselines(NoLock)
				)
			select count(*)  from cte 
				Where Row_Num >1;