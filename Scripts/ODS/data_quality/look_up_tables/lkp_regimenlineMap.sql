IF OBJECT_ID(N'[ODS].[lkp].[lkp_RegimenLineMap]', N'U') IS NOT NULL 
    DROP TABLE [ODS].[lkp].[lkp_RegimenLineMap];
BEGIN

CREATE TABLE [ODS].[lkp].[lkp_RegimenLineMap](
    [Ident] [int] IDENTITY(1,1) NOT NULL,
    [Source_Regimen] [varchar](250) NULL,
    [Target_Regimen] [varchar](150) NULL,
    [DateImported] [date] NULL
) ;

SET IDENTITY_INSERT [ODS].[lkp].[lkp_RegimenLineMap] ON 

INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (1, N'1st Line', N'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (2, N'Adult ART FirstLine', N'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (3, N'First line', N'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (4, N'1', N'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (5, N'2', N'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (6, N'Adult ART SecondLine', N'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (7, N'Adult First line', N'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (8, N'2nd Line', N'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (9, N'Paeds ART FirstLine', N'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (10, N'Second line', N'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (11, N'FIRST', N'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (13, N'PMTCT Regimens', N'PMTCT Regimens', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (14, N'Paeds ART Secondline', N'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (15, N'1st', N'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (17, N'Adult second line', N'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (18, N'Child first line', N'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (19, N'SECOND', N'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (20, N'Adult intensive', NULL, NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (21, N'Adult ART ThirdLine', N'Third Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (22, N'Third line', N'Third Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (23, N'Second line substitute', N'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (24, N'2nd', N'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (25, N'PMTCT', N'PMTCT Regimens', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (26, N'3', N'Third Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (27, N'Paeds ART ThirdLine', N'Third Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (28, N'PrEP Regimens', N'PrEP Regimens', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (29, N'Not Applicable', NULL, NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (30, N'PEP', N'PEP Regimens', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (31, N'PEP Regimens', N'PEP Regimens', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (32, N'0', NULL, NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (33, N'Other', NULL, NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (34, N'Adult continuation', NULL, NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (35, N'Adult FirstLine', 'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (36, N'Adult SecondLine', 'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (37, N'Adult ThirdLine', 'Third Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (38, N'Child FirstLine', 'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (39, N'Child SecondLine', 'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (40, N'Child ThirdLine', 'Third Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (41, N'First Line', 'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (42, N'First Line Substitute', 'First Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (43, N'PMTCT Maternal Regimens', 'PMTCT Regimens', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (45, N'Second Line', 'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (46, N'Second Line Substitute', 'Second Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (47, N'Third Line', 'Third Line', NULL)
INSERT [ODS].[lkp].[lkp_RegimenLineMap] ([Ident], [Source_Regimen], [Target_Regimen], [DateImported]) VALUES (48, N'unknown', 'Other', NULL)

END