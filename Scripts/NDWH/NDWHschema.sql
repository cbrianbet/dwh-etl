USE [master]
GO
/****** Object:  Database [NDWH_DB]    Script Date: 9/29/2022 8:56:23 PM ******/
CREATE DATABASE [NDWH_DB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'NDWH_DB', FILENAME = N'D:\PathWays International\Backups\NDWH_DB.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'NDWH_DB_log', FILENAME = N'D:\PathWays International\Backups\NDWH_DB_log.ldf' , SIZE = 794624KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [NDWH_DB] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [NDWH_DB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [NDWH_DB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [NDWH_DB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [NDWH_DB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [NDWH_DB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [NDWH_DB] SET ARITHABORT OFF 
GO
ALTER DATABASE [NDWH_DB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [NDWH_DB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [NDWH_DB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [NDWH_DB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [NDWH_DB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [NDWH_DB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [NDWH_DB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [NDWH_DB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [NDWH_DB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [NDWH_DB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [NDWH_DB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [NDWH_DB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [NDWH_DB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [NDWH_DB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [NDWH_DB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [NDWH_DB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [NDWH_DB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [NDWH_DB] SET RECOVERY FULL 
GO
ALTER DATABASE [NDWH_DB] SET  MULTI_USER 
GO
ALTER DATABASE [NDWH_DB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [NDWH_DB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [NDWH_DB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [NDWH_DB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [NDWH_DB] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'NDWH_DB', N'ON'
GO
ALTER DATABASE [NDWH_DB] SET QUERY_STORE = OFF
GO
USE [NDWH_DB]
GO
/****** Object:  Table [dbo].[Dim_Agency]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Agency](
	[AgencyKey] [int] IDENTITY(1,1) NOT NULL,
	[AgencyAlternateID] [varchar](50) NULL,
	[AgencyName] [varchar](50) NULL,
	[Load_DTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_Date]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Date](
	[DateKey] [int] NOT NULL,
	[DateAlternateKey] [date] NOT NULL,
	[DayNumberOfWeek] [tinyint] NULL,
	[DayNameOfWeek] [nvarchar](9) NULL,
	[DayNumberOfMonth] [smallint] NULL,
	[DayOfMonth] [nvarchar](2) NULL,
	[DayNumberOfYear] [smallint] NULL,
	[DayOfYear] [nvarchar](3) NULL,
	[WeekNumberOfMonth] [tinyint] NULL,
	[ISOWeekNumberOfYear] [tinyint] NULL,
	[ISOWeekOfYear] [nvarchar](2) NULL,
	[WeekNumberOfYear] [tinyint] NULL,
	[WeekOfYear] [nvarchar](2) NULL,
	[MonthName] [nvarchar](9) NULL,
	[MonthNumberOfYear] [tinyint] NULL,
	[MonthOfYear] [nvarchar](2) NULL,
	[CalendarQuarter] [tinyint] NULL,
	[CalendarQuarterName] [nvarchar](2) NULL,
	[CalendarSemester] [tinyint] NULL,
	[CalendarSemesterName] [nvarchar](2) NULL,
	[CalendarYear] [smallint] NULL,
	[FiscalQuarter] [tinyint] NULL,
	[FiscalQuarterName] [nvarchar](2) NULL,
	[FiscalSemester] [tinyint] NULL,
	[FiscalSemesterName] [nvarchar](2) NULL,
	[FiscalYear] [smallint] NULL,
	[EffectiveDate] [datetime] NULL,
	[LastUpdateDate] [datetime] NULL,
	[AllowAutoUpdateBitFlag] [bit] NULL,
	[WorkDay] [varchar](8) NULL,
	[IsWorkDay] [bit] NULL,
	[EOMONTHDATE] [date] NULL,
	[workingDays] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_Drug]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Drug](
	[DrugKey] [int] IDENTITY(1,1) NOT NULL,
	[DrugAlternateID] [nvarchar](5) NULL,
	[DrugName] [nvarchar](15) NULL,
	[Load_DTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_EMRType]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_EMRType](
	[EMRTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[EMRTypeAlternateID] [nvarchar](5) NULL,
	[EMRName] [nvarchar](15) NULL,
	[Load_DTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_ExitReason]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_ExitReason](
	[ExitReasonKey] [int] IDENTITY(1,1) NOT NULL,
	[ExitReasonAlternateID] [nvarchar](5) NULL,
	[ExitReasonDescription] [nvarchar](15) NULL,
	[Load_DTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_Facility]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Facility](
	[FacilityKey] [int] IDENTITY(1,1) NOT NULL,
	[CountyKey] [int] NULL,
	[SubCountyKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[MFL_Code] [varchar](50) NULL,
	[Facility Name] [varchar](250) NULL,
	[County] [varchar](50) NULL,
	[SubCounty] [varchar](50) NULL,
	[Owner] [varchar](250) NULL,
	[Latitude] [varchar](50) NULL,
	[Longitude] [varchar](50) NULL,
	[SDP] [varchar](250) NULL,
	[SDP Agency] [varchar](50) NULL,
	[Implementation] [varchar](50) NULL,
	[EMR] [varchar](50) NULL,
	[EMR Status] [varchar](50) NULL,
	[HTS Use] [varchar](50) NULL,
	[HTS Deployment] [varchar](50) NULL,
	[HTS Status] [varchar](50) NULL,
	[IL Status] [varchar](50) NULL,
	[Registration IE] [varchar](50) NULL,
	[Phamarmacy IE] [varchar](50) NULL,
	[mlab] [varchar](50) NULL,
	[Ushauri] [varchar](50) NULL,
	[Nishauri] [varchar](50) NULL,
	[Appointment Management IE] [varchar](50) NULL,
	[OVC] [varchar](50) NULL,
	[OTZ] [varchar](50) NULL,
	[PrEP] [varchar](50) NULL,
	[3PM] [varchar](50) NULL,
	[AIR] [varchar](50) NULL,
	[KP] [varchar](50) NULL,
	[MCH] [varchar](50) NULL,
	[TB] [varchar](50) NULL,
	[Lab Manifest] [varchar](50) NULL,
	[Comments] [varchar](250) NULL,
	[Project] [nvarchar](100) NULL,
	[Load_DTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_IsBoosterGiven]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_IsBoosterGiven](
	[IsBoosterGivenKey] [int] IDENTITY(1,1) NOT NULL,
	[IsBoosterGivenAlternateID] [nvarchar](5) NULL,
	[IsBoosterGiven] [nvarchar](5) NULL,
	[Load_DTS] [timestamp] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_MOHAgeBand]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_MOHAgeBand](
	[MOHAgeBandBandKey] [int] IDENTITY(1,1) NOT NULL,
	[AgeBandLowerLimit] [nvarchar](20) NULL,
	[AgeBandUpperLimit] [nvarchar](20) NULL,
	[MOHAgeBandDescription] [nvarchar](50) NULL,
	[Load_DTS] [timestamp] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_Partner]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Partner](
	[PartnerKey] [int] IDENTITY(1,1) NOT NULL,
	[PartnerAlternateID] [varchar](100) NULL,
	[PartnerName] [varchar](100) NULL,
	[Load_DTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_Patient]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Patient](
	[PatientKey] [int] IDENTITY(1,1) NOT NULL,
	[FacilityKey] [int] NULL,
	[GenderKey] [int] NULL,
	[MaritalStatusKey] [int] NULL,
	[EmrTypeKey] [int] NULL,
	[EducationLevelKey] [int] NULL,
	[CountyKey] [int] NULL,
	[SubCountyKey] [int] NULL,
	[PatientTypeKey] [int] NULL,
	[PopulationTypeKey] [int] NULL,
	[OccupationKey] [int] NULL,
	[PatientID] [nvarchar](100) NULL,
	[PatientPK] [int] NULL,
	[SiteCode] [varchar](50) NULL,
	[FacilityName] [varchar](50) NULL,
	[Gender] [varchar](250) NULL,
	[DOB] [datetime2](7) NULL,
	[RegistrationDate] [date] NULL,
	[RegistrationAtCCC] [date] NULL,
	[RegistrationAtPMTCT] [date] NULL,
	[RegistrationAtTBClinic] [date] NULL,
	[PatientSource] [varchar](250) NULL,
	[Region] [varchar](250) NULL,
	[District] [varchar](250) NULL,
	[Village] [varchar](250) NULL,
	[ContactRelation] [varchar](250) NULL,
	[LastVisit] [date] NULL,
	[MaritalStatus] [varchar](250) NULL,
	[EducationLevel] [varchar](250) NULL,
	[DateConfirmedHIVPositive] [date] NULL,
	[PreviousARTExposure] [varchar](250) NULL,
	[PreviousARTStartDate] [date] NULL,
	[Emr] [varchar](100) NULL,
	[Project] [varchar](100) NULL,
	[DateImported] [date] NULL,
	[PKV] [varchar](250) NULL,
	[PatientUID] [uniqueidentifier] NULL,
	[RegistrationYear] [int] NULL,
	[MPIPKV] [varchar](250) NULL,
	[Orphan] [varchar](250) NULL,
	[Inschool] [varchar](250) NULL,
	[PatientType] [varchar](250) NULL,
	[PopulationType] [varchar](250) NULL,
	[KeyPopulationType] [varchar](250) NULL,
	[PatientResidentCounty] [varchar](250) NULL,
	[PatientResidentSubCounty] [varchar](250) NULL,
	[PatientResidentLocation] [varchar](250) NULL,
	[PatientResidentSubLocation] [varchar](250) NULL,
	[PatientResidentWard] [varchar](250) NULL,
	[PatientResidentVillage] [varchar](250) NULL,
	[TransferInDate] [date] NULL,
	[Occupation] [nvarchar](150) NULL,
	[NUPI] [nvarchar](50) NULL,
	[Load_DTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_PatientSource]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_PatientSource](
	[PatientSourceKey] [int] IDENTITY(1,1) NOT NULL,
	[PatientSourceAlternateID] [nvarchar](20) NULL,
	[PatientSourceDescription] [nvarchar](20) NULL,
	[Load_DTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_PatientType]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_PatientType](
	[PatientTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[PatientTypeAlternateID] [nvarchar](5) NULL,
	[PatientTypeDescription] [nvarchar](15) NULL,
	[Load_DTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_PopulationType]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_PopulationType](
	[PopulationTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[PopulationTypeAlternateID] [nvarchar](15) NULL,
	[PopulationTypeDescription] [nvarchar](250) NULL,
	[Load_DTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_Regimen]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Regimen](
	[RegimenKey] [int] IDENTITY(1,1) NOT NULL,
	[RegimenAlternateID] [nvarchar](50) NULL,
	[RegimenDescription] [nvarchar](250) NULL,
	[Load_DTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimGender]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimGender](
	[GenderKey] [int] IDENTITY(1,1) NOT NULL,
	[GenderAlternateID] [nvarchar](5) NULL,
	[GenderDescription] [nvarchar](15) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimIsBoosterGiven]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimIsBoosterGiven](
	[IsBoosterGivenKey] [int] IDENTITY(1,1) NOT NULL,
	[IsBoosterGivenAlternateID] [nvarchar](5) NULL,
	[IsBoosterGiven] [nvarchar](5) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimMaritalStatus]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimMaritalStatus](
	[MaritalStatusKey] [int] IDENTITY(1,1) NOT NULL,
	[MaritalStatusAlternateID] [nvarchar](50) NULL,
	[MaritalStatusDescription] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimPatientSource]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimPatientSource](
	[PatientSourceKey] [int] IDENTITY(1,1) NOT NULL,
	[PatientSourceAlternateID] [nvarchar](20) NULL,
	[PatientSourceDescription] [nvarchar](20) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimPopulationType]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimPopulationType](
	[PopulationTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[PopulationTypeAlternateID] [nvarchar](15) NULL,
	[PopulationTypeDescription] [nvarchar](15) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimStatusAtCCC]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimStatusAtCCC](
	[StatusAtCCCKey] [int] IDENTITY(1,1) NOT NULL,
	[StatusAtCCCAlternateID] [nvarchar](5) NULL,
	[StatusAtCCCDescription] [nvarchar](15) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimTreatmentType]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimTreatmentType](
	[TreatmentTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[TreatmentTypeAlternateID] [nvarchar](5) NULL,
	[TreatmentTypeDescription] [nvarchar](15) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimVaccinationStatus]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimVaccinationStatus](
	[VaccinationStatusKey] [int] IDENTITY(1,1) NOT NULL,
	[VaccinationStatusAlternateID] [nvarchar](50) NULL,
	[VaccinationStatus] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Fact_ARTOutcomes]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Fact_ARTOutcomes](
	[FactARTStatusKey] [int] NULL,
	[PatientKey] [int] NULL,
	[FacilityKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[PartnerKey] [int] NULL,
	[AgeLastVisit] [int] NULL,
	[AgeEnrollment] [int] NULL,
	[AgeGroupKey] [int] NULL,
	[PopulationTypeKey] [int] NULL,
	[EnrollmentDateKey] [int] NULL,
	[NextAppointmentDate] [datetime] NULL,
	[ARTOutcome] [varchar](10) NULL,
	[StartRegimenKey] [int] NULL,
	[MOHAgeBandKey] [int] NULL,
	[Gender] [varchar](10) NULL,
	[KeyPopulationTypeKey] [int] NULL,
	[CurrentRegimenKey] [int] NULL,
	[StartRegimenLineKey] [int] NULL,
	[DateLastVisit] [datetime] NULL,
	[StartARTDateKey] [int] NULL,
	[DateConfirmedHIVPositiveKey] [int] NULL,
	[AsOfDate] [date] NULL,
	[AsOfDateKey] [int] NULL,
	[Load_DTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Fact_Covid]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Fact_Covid](
	[PatientKey] [int] NULL,
	[DateKey] [int] NULL,
	[VaccinationStatusKey] [int] NULL,
	[IsBoosterGivenKey] [int] NULL,
	[FacilityKey] [int] NULL,
	[AdmissionStatusKey] [int] NULL,
	[PatientStatusKey] [int] NULL,
	[VisitID] [int] NULL,
	[Covid19AssessmentDate] [date] NULL,
	[ReceivedCOVID19Vaccine] [nvarchar](150) NULL,
	[DateGivenFirstDose] [date] NULL,
	[FirstDoseVaccineAdministered] [nvarchar](150) NULL,
	[DateGivenSecondDose] [date] NULL,
	[SecondDoseVaccineAdministered] [nvarchar](150) NULL,
	[VaccineVerification] [nvarchar](150) NULL,
	[BoosterDose] [nvarchar](150) NULL,
	[BoosterDoseDate] [date] NULL,
	[EverCOVID19Positive] [nvarchar](150) NULL,
	[COVID19TestDate] [date] NULL,
	[AdmissionUnit] [nvarchar](150) NULL,
	[MissedAppointmentDueToCOVID19] [nvarchar](150) NULL,
	[COVID19PositiveSinceLasVisit] [nvarchar](150) NULL,
	[COVID19TestDateSinceLastVisit] [date] NULL,
	[PatientStatusSinceLastVisit] [nvarchar](150) NULL,
	[AdmissionStatusSinceLastVisit] [nvarchar](150) NULL,
	[AdmissionStartDate] [date] NULL,
	[AdmissionEndDate] [date] NULL,
	[AdmissionUnitSinceLastVisit] [nvarchar](150) NULL,
	[SupplementalOxygenReceived] [nvarchar](150) NULL,
	[PatientVentilated] [nvarchar](150) NULL,
	[TracingFinalOutcome] [nvarchar](150) NULL,
	[CauseOfDeath] [nvarchar](150) NULL,
	[PKV] [nvarchar](122) NULL,
	[DateImported] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Landing_ARTOutcomeReport]    Script Date: 9/29/2022 8:56:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Landing_ARTOutcomeReport](
	[PatientID] [nvarchar](50) NULL,
	[PatientPK] [nvarchar](50) NULL,
	[MFLCode] [nvarchar](255) NULL,
	[FacilityName] [varchar](250) NULL,
	[CTPartner] [varchar](250) NULL,
	[CTAgency] [varchar](50) NULL,
	[County] [varchar](50) NULL,
	[Subcounty] [varchar](50) NULL,
	[PopulationType] [nvarchar](250) NULL,
	[KeyPopulationType] [nvarchar](250) NULL,
	[CurrentRegimen] [nvarchar](150) NULL,
	[Gender] [varchar](10) NULL,
	[AgeLastVisit] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[AgeEnrollment] [int] NULL,
	[StartRegimen] [varchar](250) NULL,
	[StartRegimenLine] [varchar](250) NULL,
	[ARTOutome] [varchar](2) NULL,
	[AsOfDate] [date] NULL,
	[DateLastVisit] [date] NULL,
	[NextAppointmentDate] [date] NULL,
	[StartARTDate] [date] NULL,
	[DateConfirmedHIVPositive] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Dim_Agency] ADD  DEFAULT (getdate()) FOR [Load_DTS]
GO
ALTER TABLE [dbo].[Dim_Drug] ADD  DEFAULT (getdate()) FOR [Load_DTS]
GO
ALTER TABLE [dbo].[Dim_EMRType] ADD  DEFAULT (getdate()) FOR [Load_DTS]
GO
ALTER TABLE [dbo].[Dim_ExitReason] ADD  DEFAULT (getdate()) FOR [Load_DTS]
GO
ALTER TABLE [dbo].[Dim_Facility] ADD  DEFAULT (getdate()) FOR [Load_DTS]
GO
ALTER TABLE [dbo].[Dim_Partner] ADD  DEFAULT (getdate()) FOR [Load_DTS]
GO
ALTER TABLE [dbo].[Dim_Patient] ADD  DEFAULT (getdate()) FOR [Load_DTS]
GO
ALTER TABLE [dbo].[Dim_PatientSource] ADD  DEFAULT (getdate()) FOR [Load_DTS]
GO
ALTER TABLE [dbo].[Dim_PatientType] ADD  DEFAULT (getdate()) FOR [Load_DTS]
GO
ALTER TABLE [dbo].[Dim_PopulationType] ADD  DEFAULT (getdate()) FOR [Load_DTS]
GO
ALTER TABLE [dbo].[Dim_Regimen] ADD  DEFAULT (getdate()) FOR [Load_DTS]
GO
ALTER TABLE [dbo].[Fact_ARTOutcomes] ADD  DEFAULT (getdate()) FOR [Load_DTS]
GO
USE [master]
GO
ALTER DATABASE [NDWH_DB] SET  READ_WRITE 
GO
