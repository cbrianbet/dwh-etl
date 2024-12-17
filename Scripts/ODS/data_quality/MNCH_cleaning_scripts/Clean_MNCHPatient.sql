UPDATE a
    SET Voided = 0             
    from [ODS].[MNCH].[MNCH_Patient] a
WHERE Voided is null
GO