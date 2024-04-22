IF Object_id(N'[NDWH].[dbo].[FactUshauriAppointments]', N'U') IS NOT NULL
  DROP TABLE [Ndwh].[Dbo].[FactUshauriAppointments];

BEGIN
    WITH Mfl_partner_agency_combination
         AS (SELECT DISTINCT Mfl_code,
                             Sdp,
                             Sdp_agency AS Agency
             FROM   Ods.Dbo.All_emrsites)

    SELECT FactKey = IDENTITY(Int, 1, 1),
           Facility.Facilitykey,
           Partner.Partnerkey,
           Patient.Patientkey,
           Agency.Agencykey,
           coalesce(Age_group.Agegroupkey, -999) as Agegroupkey,
           Appointment.Datekey           AS AppointmentDateKey,
           Appointmenttype,
           Appointmentstatus,
           Entrypoint,
           Visittype,
           Attended.Datekey               AS DateAttendedDateKey,
           Consentforsms,
           Smslanguage,
           Smstargetgroup,
           Smspreferredsendtime,
           Fourweeksmssent,
           Fourweeksdate.Datekey         AS FourWeekSMSSendDateKey,
           Fourweeksmsdeliverystatus,
           Fourweeksmsdeliveryfailurereason,
           Threeweeksmssent,
           Threeweeksdate.Datekey        AS ThreeWeekSMSSendDateKey,
           Threeweeksmsdeliverystatus,
           Threeweeksmsdeliveryfailurereason,
           Twoweeksmssent,
           Twoweeksdate.Datekey          AS TwoWeekSMSSendDateKey,
           Twoweeksmsdeliverystatus,
           Twoweeksmsdeliveryfailurereason,
           Oneweeksmssent,
           Oneweeksdate.Datekey          AS OneWeekSMSSendDateKey,
           Oneweeksmsdeliverystatus,
           Oneweeksmsdeliveryfailurereason,
           Onedaysmssent,
           Onedaydate.Datekey           AS OneDaySMSSendDateKey,
           Onedaysmsdeliverystatus,
           Onedaysmsdeliveryfailurereason,
           Missedappointmentsmssent,
           Missedappointmentdate.Datekey  AS  MissedAppointmentSMSSendDateKey,
           Missedappointmentsmsdeliverystatus,
           Missedappointmentsmsdeliveryfailurereason,
           Tracingcalls,
           Tracingsms,
           Tracinghomevisits,
           Tracingoutcome,
           Tracingdate.Datekey          AS TracingOutcomeDateKey,
           Datereturnedtocare.Datekey    AS DateReturnedToCareDateKey,
           Daysdefaulted,
           Nupihash
    INTO   NDWH.dbo.FactUshauriAppointments
    FROM   Ods.Dbo.Ushauri_patientappointments AS Apt
           LEFT JOIN Ndwh.Dbo.Dimfacility AS Facility
                  ON Facility.Mflcode = Apt.Sitecode
           LEFT JOIN Mfl_partner_agency_combination
                  ON Mfl_partner_agency_combination.Mfl_code = Apt.Sitecode
           LEFT JOIN Ndwh.Dbo.Dimpartner AS Partner
                  ON Partner.Partnername = Mfl_partner_agency_combination.Sdp
           LEFT JOIN Ndwh.Dbo.Dimpatient AS Patient
                  ON Patient.Patientpkhash = Apt.Patientpkhash
                     AND Patient.Sitecode = Apt.Sitecode
           LEFT JOIN Ndwh.Dbo.Dimagency AS Agency
                  ON Agency.Agencyname = Mfl_partner_agency_combination.Agency
           LEFT JOIN Ndwh.Dbo.Dimagegroup AS Age_group
                  ON Age_group.Agegroupkey = DATEDIFF(YEAR, Apt.Dob, Appointmentdate)
           LEFT JOIN Ndwh.Dbo.Dimdate AS As_of
                  ON As_of.Date = Apt.Appointmentdate
           LEFT JOIN Ndwh.Dbo.Dimdate AS Appointment
                  ON Appointment.Date = Apt.Appointmentdate
           LEFT JOIN Ndwh.Dbo.Dimdate AS Attended
                  ON Attended.Date = Apt.Dateattended
           LEFT JOIN Ndwh.Dbo.Dimdate AS Fourweeksdate
                  ON Fourweeksdate.Date =
                     Fourweeksmssenddate
           LEFT JOIN Ndwh.Dbo.Dimdate AS Threeweeksdate
                  ON Threeweeksdate.Date =
                     Threeweeksmssenddate
           LEFT JOIN Ndwh.Dbo.Dimdate AS Twoweeksdate
                  ON Twoweeksdate.Date =
                     Twoweeksmssenddate
           LEFT JOIN Ndwh.Dbo.Dimdate AS Oneweeksdate
                  ON Oneweeksdate.Date =
                    Apt.Oneweeksmssenddate
           LEFT JOIN Ndwh.Dbo.Dimdate AS Onedaydate
                  ON Onedaydate.Date = Apt.Onedaysmssenddate
           LEFT JOIN Ndwh.Dbo.Dimdate AS Missedappointmentdate
                  ON Missedappointmentdate.Date =
                    Apt.Missedappointmentsmssenddate
           LEFT JOIN Ndwh.Dbo.Dimdate AS Tracingdate
                  ON Tracingdate.Date =
                    Apt.Tracingoutcomedate
           LEFT JOIN Ndwh.Dbo.Dimdate AS Datereturnedtocare
                  ON Datereturnedtocare.Date =
                     Apt.Datereturnedtocare

    ALTER TABLE Ndwh.Dbo.FactUshauriAppointments
      ADD PRIMARY KEY(Factkey);
END