----------------------------------HTS_ClientLinkages-------------------------------------------
------------------Update ReferralDate to NULL  where dates are missing--------------------

Update ODS.[HTS].HTS_ClientLinkages Set ReferralDate = NULL where ReferralDate is null
GO
------------------Update DateEnrolled to missing  where dates are missing--------------------

Update ODS.[HTS].HTS_ClientLinkages Set DateEnrolled = NULL where DateEnrolled is null
GO
------------------Update DatePrefferedToBeEnrolled to missing  where dates are missing--------------------
Update ODS.[HTS].HTS_ClientLinkages Set DatePrefferedToBeEnrolled = NULL where DatePrefferedToBeEnrolled is null