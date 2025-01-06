-- clean AdverseEventRegimen
UPDATE ODS.PrEP.PrEP_AdverseEvent
    SET AdverseEventRegimen = NULL
WHERE AdverseEventRegimen = ''

GO

-- clean AdverseEventIsPregnant
UPDATE ODS.PrEP.PrEP_AdverseEvent
    SET AdverseEventIsPregnant = NULL
WHERE AdverseEventIsPregnant = ''

GO

-- clean AdverseEventClinicalOutcome
UPDATE ODS.PrEP.PrEP_AdverseEvent
    SET AdverseEventClinicalOutcome = NULL
WHERE AdverseEventClinicalOutcome = ''

GO

-- clean AdverseEventActionTaken
UPDATE ODS.PrEP.PrEP_AdverseEvent
    SET AdverseEventActionTaken = NULL
WHERE AdverseEventActionTaken = ''

GO

-- clean Severity
UPDATE ODS.PrEP.PrEP_AdverseEvent
    SET Severity = NULL
WHERE Severity = ''

GO

-- clean AdverseEventEndDate
UPDATE ODS.PrEP.PrEP_AdverseEvent
    SET AdverseEventEndDate = NULL
WHERE AdverseEventEndDate = ''

GO

-- clean AdverseEventStartDate
UPDATE ODS.PrEP.PrEP_AdverseEvent
    SET AdverseEventStartDate = NULL
WHERE AdverseEventStartDate = ''

GO

-- clean AdverseEvent
UPDATE ODS.PrEP.PrEP_AdverseEvent
    SET AdverseEvent = NULL
WHERE AdverseEvent = ''

GO