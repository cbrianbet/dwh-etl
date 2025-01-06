
-- clean bWHODate
UPDATE [ODS].[Care].[CT_PatientBaselines]
    SET bWHODate = NULL
WHERE bWHODate < CAST('1980-01-01' AS DATE) OR bWHODate > GETDATE()

GO

-- clean bCD4
UPDATE [ODS].[Care].[CT_PatientBaselines]
    SET bCD4 = 999
WHERE bCD4 < 0 

GO

-- clean bCD4Date
UPDATE [ODS].[Care].[CT_PatientBaselines]
    SET bCD4Date = NULL
WHERE bCD4Date < CAST('1980-01-01' AS DATE) OR bCD4Date > GETDATE()

GO
