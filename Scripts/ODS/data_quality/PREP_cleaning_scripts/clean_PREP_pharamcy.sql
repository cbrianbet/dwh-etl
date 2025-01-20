-- clean Duration
UPDATE ODS.PrEP.PrEP_Pharmacy
    SET Duration = NULL
WHERE Duration > 12.00

GO

-- clean DispenseDate
UPDATE ODS.PrEP.PrEP_Pharmacy
    SET DispenseDate = NULL
WHERE DispenseDate = '' OR DispenseDate < '1980-01-01'

GO

-- clean RegimenPrescribed
UPDATE ODS.PrEP.PrEP_Pharmacy
    SET RegimenPrescribed = NULL
WHERE RegimenPrescribed = '' 

GO

