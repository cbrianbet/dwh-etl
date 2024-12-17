-- clean TraceOutcome

UPDATE [ODS].[HTS].[HTS_PartnerTracings]
    SET TraceOutcome = NULL
WHERE TraceOutcome = 'null'