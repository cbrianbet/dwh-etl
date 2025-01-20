-- clean DateOfLastPrepDose
UPDATE ODS.PrEP.PrEP_CareTermination
    SET DateOfLastPrepDose = NULL
WHERE DateOfLastPrepDose = ''

GO

-- clean ExitReason
UPDATE ODS.PrEP.PrEP_CareTermination
    SET ExitReason = NULL
WHERE ExitReason = ''

GO
