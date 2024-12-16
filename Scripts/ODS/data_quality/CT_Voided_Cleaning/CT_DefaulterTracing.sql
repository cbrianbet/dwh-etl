UPDATE a
SET voided = 0
FROM [ODS].[Care].[CT_DefaulterTracing] a
where rtrim(ltrim(voided))='' or voided is null