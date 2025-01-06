;
WITH Src_PatientConcat AS
(
	SELECT  DISTINCT F.Code
		,P.[PatientPID] AS PatientPK
		,CONCAT(F.Code,P.[PatientPID]) AS PatientConcatColumn
	FROM [DWAPICentral].[DBO].[PatientExtract] P WITH (NoLock)
	INNER JOIN [DWAPICentral].[DBO].[Facility] F WITH (NoLock) ON P.[FacilityId] = F.Id AND F.Voided = 0
	WHERE P.Voided = 0
		AND P.[Gender] is NOT NULL
		AND p.gender != 'Unknown' 
), ODS_PatientConcat AS
(
	SELECT  SiteCode
		,PatientPK
		,CONCAT(SiteCode,PatientPK) AS ODSPatient
	FROM [ODS].[Care].[CT_Patient]
) UPDATE [ODS].[Care].[CT_Patient]

SET VOIDED = 1
FROM [ODS].[Care].[CT_Patient] a
INNER JOIN ODS_PatientConcat b ON a.SiteCode = b.SiteCode AND a.PatientPK = b.PatientPK
WHERE b.ODSPatient NOT IN ( SELECT PatientConcatColumn FROM Src_PatientConcat);