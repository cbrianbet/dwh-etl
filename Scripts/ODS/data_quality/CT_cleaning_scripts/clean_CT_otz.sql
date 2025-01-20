-- clean OTZEnrollmentDate
UPDATE [ODS].[Care].[CT_Otz]
    SET OTZEnrollmentDate = NULL
WHERE OTZEnrollmentDate < CAST('2012-01-01' AS DATE) OR OTZEnrollmentDate >  GETDATE()

GO

-- clean TransferInStatus
UPDATE [ODS].[Care].[CT_Otz]
    SET TransferInStatus = CASE
                                WHEN TransferInStatus IN ('Yes', '1') THEN 'Yes'
                                WHEN TransferInStatus IN ('No', '0') THEN 'No'
                            END
WHERE TransferInStatus IN ('Yes', '1', 'No', '0')

GO


-- clean SupportGroupInvolvement
UPDATE [ODS].[Care].[CT_Otz]
    SET SupportGroupInvolvement = CASE
                                    WHEN SupportGroupInvolvement IN ('Yes', '1') THEN 'Yes'
                                    WHEN SupportGroupInvolvement IN ('No', '0') THEN 'No'
                                END
WHERE SupportGroupInvolvement IN ('Yes', '1', 'No', '0')

GO