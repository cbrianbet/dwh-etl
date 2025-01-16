-- clean DateOfFirstSession
UPDATE [ODS].[Care].[CT_EnhancedAdherenceCounselling]
    SET DateOfFirstSession = NULL
WHERE DateOfFirstSession < CAST('1900-01-01' AS DATE) OR DateOfFirstSession > GETDATE()

GO

-- clean EACFollowupDate
UPDATE [ODS].[Care].[CT_EnhancedAdherenceCounselling]
    SET EACFollowupDate = NULL
WHERE EACFollowupDate < CAST('1900-01-01' AS DATE) OR DATEDIFF(day, GETDATE(), EACFollowupDate) > 365

GO