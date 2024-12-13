-- clean FacilityLinkedTo
UPDATE ODS.[HTS].HTS_PartnerNotificationServices
    SET FacilityLinkedTo = NULL
WHERE FacilityLinkedTo = ''

--clean PnsApproach
UPDATE ODS.[HTS].HTS_PartnerNotificationServices
    SET PnsApproach = CASE PnsApproach
                        WHEN 'Pr: Provider Referral' THEN 'Provider Referral'
                        WHEN 'D: Dual Referral' THEN 'Provider Referral'
                        WHEN 'Cr: Passive Referral' THEN 'Passive Referral'
                    END 
WHERE PnsApproach IN ('Pr: Provider Referral', 'D: Dual Referral', 'Cr: Passive Referral')


--clean LinkedToCare 
UPDATE ODS.[HTS].HTS_PartnerNotificationServices
SET LinkedToCare = CASE LinkedToCare
                        WHEN 'Y'  THEN 'Yes'
                        WHEN 'N' THEN 'No'
                    END
WHERE LinkedToCare IN ('Y', 'N')

-- clean PnsConsent
UPDATE ODS.[HTS].HTS_PartnerNotificationServices
    SET PnsConsent = 'No'
WHERE PnsConsent = '0'

-- Clean ScreenedForIpv
UPDATE ODS.[HTS].HTS_PartnerNotificationServices
    SET ScreenedForIpv = NULL
WHERE ScreenedForIpv = 'NA'

--Clean CccNumber
UPDATE ODS.[HTS].HTS_PartnerNotificationServices
    SET CccNumber = NULL
WHERE CccNumber = ''

-- Clean Age
UPDATE ODS.[HTS].HTS_PartnerNotificationServices
    SET Age = NULL
WHERE Age < 0 and Age > 100

