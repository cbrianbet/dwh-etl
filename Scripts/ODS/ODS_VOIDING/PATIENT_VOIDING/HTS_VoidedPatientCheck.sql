;
WITH Src_PatientConcat AS
(
	SELECT  DISTINCT a.Sitecode
		,a.PatientPK
		,CONCAT(a.Sitecode,a.PatientPK) AS PatientConcatColumn
	FROM [HTSCentral].[dbo].[Clients] (NoLock) a
	INNER JOIN
	(
		SELECT  SiteCode
			,PatientPK
			,MAX(datecreated) AS Maxdatecreated
		FROM [HTSCentral].[dbo].[Clients] (NoLock)
		GROUP BY SiteCode, PatientPK
	) tm
	ON a.[SiteCode] = tm.[SiteCode] AND a.PatientPK = tm.PatientPK AND a.datecreated = tm.Maxdatecreated
	WHERE a.DateExtracted > '2019-09-08' 
), ODS_PatientConcat AS
(
	SELECT  SiteCode
		,PatientPK
		,CONCAT(SiteCode,PatientPK) AS ODSPatient
	FROM [ODS].[HTS].[HTS_clients]
) UPDATE [ODS].[HTS].[HTS_clients]

SET VOIDED = 1
FROM [ODS].[HTS].[HTS_clients] a
INNER JOIN ODS_PatientConcat b
ON a.SiteCode = b.SiteCode AND a.PatientPK = b.PatientPK
WHERE b.ODSPatient NOT IN ( SELECT PatientConcatColumn FROM Src_PatientConcat); 