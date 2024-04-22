--clean TestResults2
UPDATE ODS.dbo.HTS_TestKits
    SET TestResult2 = NULL
WHERE TestResult2 = 'N/A'

--clean TestKitName2
UPDATE ODS.dbo.HTS_TestKits
    SET TestKitName2 = NULL
WHERE TestKitName2 = ''

--clean TestKitName1
UPDATE ODS.dbo.HTS_TestKits
    SET TestKitName1 = NULL
WHERE TestKitName1 = ''

-- clean TestKitLotNumber1
-- clean TestKitLotNumber2
DROP FUNCTION IF EXISTS [dbo].[Remove_SpecialCharacters];
GO

CREATE FUNCTION dbo.Remove_SpecialCharacters( @str VARCHAR(MAX))
    RETURNS VARCHAR(MAX) AS
    BEGIN
        DECLARE @expres  VARCHAR(50) = '%[~,@,#,$,%,&,*,(,),.,!,+,-,'', ?]%'

        WHILE PATINDEX( @expres, @str ) > 0
        SET @str = Replace(REPLACE( @str, SUBSTRING( @str, PATINDEX( @expres, @str ), 1 ),''),'-',' ')
        RETURN @str
        
    END
GO

UPDATE ODS.dbo.HTS_TestKits
    SET TestKitLotNumber1 = dbo.Remove_SpecialCharacters(TestKitLotNumber1);


UPDATE ODS.dbo.HTS_TestKits
    SET TestKitLotNumber2 = dbo.Remove_SpecialCharacters(TestKitLotNumber2);


GO

-- clean TestKitExpiry1
with cleaned_up_dates as (
    select
        TestKitExpiry1,
        try_cast(TestKitExpiry1 as datetime) as TestKitExpiryCleanedVersion1
    from ODS.dbo.HTS_TestKits
),
dd_mm_yyyy_data as (
    select 
        TestKitExpiry1,
        try_convert(datetime, TestKitExpiry1, 103) as TestKitExpiryCleanedVersion2
    from cleaned_up_dates
    where TestKitExpiryCleanedVersion1 is null  
        and TestKitExpiry1 is not null 
        and len(substring(TestKitExpiry1, 7, 4)) = 4
),
combined_dates as (
    select TestKitExpiry1, TestKitExpiryCleanedVersion1 as TestKitExpiry1Cleaned from cleaned_up_dates
    union
    select TestKitExpiry1, TestKitExpiryCleanedVersion2 as TestKitExpiry1Cleaned from dd_mm_yyyy_data
)
update ODS.dbo.HTS_TestKits
    set TestKitExpiry1 =  combined_dates.TestKitExpiry1Cleaned
from ODS.dbo.HTS_TestKits as kits
inner join combined_dates on combined_dates.TestKitExpiry1 = kits.TestKitExpiry1



-- clean TestKitExpiry2
;with cleaned_up_dates as (
    select
        TestKitExpiry2,
        try_cast(TestKitExpiry2 as datetime) as TestKitExpiryCleanedVersion1
    from ODS.dbo.HTS_TestKits
),
dd_mm_yyyy_data as (
    select 
        TestKitExpiry2,
        convert(datetime, TestKitExpiry2, 103) as TestKitExpiryCleanedVersion2
    from cleaned_up_dates
    where TestKitExpiryCleanedVersion1 is null  
        and TestKitExpiry2 is not null 
        and len(substring(TestKitExpiry2, 7, 4)) = 4
),
combined_dates as (
    select TestKitExpiry2, TestKitExpiryCleanedVersion1 as TestKitExpiry2Cleaned from cleaned_up_dates
    union
    select TestKitExpiry2, TestKitExpiryCleanedVersion2 as TestKitExpiry2Cleaned from dd_mm_yyyy_data
)
update ODS.dbo.HTS_TestKits
   set TestKitExpiry2 =  combined_dates.TestKitExpiry2Cleaned
from ODS.dbo.HTS_TestKits as kits
inner join combined_dates on combined_dates.TestKitExpiry2 = kits.TestKitExpiry2
