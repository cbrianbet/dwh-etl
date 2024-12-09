-- clean Covid19AssessmentDate
UPDATE [ODS].[Care].[CT_Covid]
    SET Covid19AssessmentDate = NULL
WHERE Covid19AssessmentDate < CAST('1980-01-01' AS DATE) OR Covid19AssessmentDate > GETDATE()

GO

-- clean DateGivenFirstDose
UPDATE [ODS].[Care].[CT_Covid]
    SET DateGivenFirstDose = NULL
WHERE DateGivenFirstDose < CAST('1980-01-01' AS DATE) OR DateGivenFirstDose > GETDATE()

GO

-- clean DateGivenSecondDose
UPDATE [ODS].[Care].[CT_Covid]
    SET DateGivenSecondDose = NULL
WHERE DateGivenSecondDose < CAST('1980-01-01' AS DATE) OR DateGivenSecondDose > GETDATE()


GO