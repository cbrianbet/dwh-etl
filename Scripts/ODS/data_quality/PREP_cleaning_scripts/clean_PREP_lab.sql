-- clean Reason
UPDATE ODS.PrEP.PrEP_Lab
    SET Reason = NULL
WHERE Reason = ''

GO

-- clean SampleDate
UPDATE ODS.PrEP.PrEP_Lab
    SET SampleDate = NULL
WHERE SampleDate = ''

GO