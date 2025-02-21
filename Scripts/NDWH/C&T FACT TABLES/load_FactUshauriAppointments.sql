IF Object_id(N'[NDWH].[Fact].[FactUshauriAppointments]', N'U') IS NOT NULL
  DROP TABLE [Ndwh].[Fact].[FactUshauriAppointments];

BEGIN
    WITH Mfl_partner_agency_combination
         AS (SELECT DISTINCT Mfl_code,
                             Sdp,
                             Sdp_agency AS Agency
             FROM   Ods.Care.All_emrsites)

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
           TracingOutCost,
           Tracingoutcome,
           Tracingdate.Datekey          AS TracingOutcomeDateKey,
           Datereturnedtocare.Datekey    AS DateReturnedToCareDateKey,
           Daysdefaulted,
           Nupihash
    INTO   NDWH.[Fact].FactUshauriAppointments
    FROM   [ODS].[Mhealth].[Mhealth_Ushauri_PatientAppointments] AS Apt
           LEFT JOIN Ndwh.Dim.Dimfacility AS Facility
                  ON Facility.Mflcode = Apt.Sitecode
           LEFT JOIN Mfl_partner_agency_combination
                  ON Mfl_partner_agency_combination.Mfl_code = Apt.Sitecode
           LEFT JOIN Ndwh.Dim.Dimpartner AS Partner
                  ON Partner.Partnername = Mfl_partner_agency_combination.Sdp
           LEFT JOIN Ndwh.Dim.Dimpatient AS Patient
                  ON Patient.Patientpkhash = Apt.Patientpkhash
                     AND Patient.Sitecode = Apt.Sitecode
           LEFT JOIN Ndwh.Dim.Dimagency AS Agency
                  ON Agency.Agencyname = Mfl_partner_agency_combination.Agency
           LEFT JOIN Ndwh.Dim.Dimagegroup AS Age_group
                  ON Age_group.Agegroupkey = DATEDIFF(YEAR, Apt.Dob, Appointmentdate)
           LEFT JOIN Ndwh.Dim.Dimdate AS As_of
                  ON As_of.Date = Apt.Appointmentdate
           LEFT JOIN Ndwh.Dim.Dimdate AS Appointment
                  ON Appointment.Date = Apt.Appointmentdate
           LEFT JOIN Ndwh.Dim.Dimdate AS Attended
                  ON Attended.Date = Apt.Dateattended
           LEFT JOIN Ndwh.Dim.Dimdate AS Fourweeksdate
                  ON Fourweeksdate.Date =
                     Fourweeksmssenddate
           LEFT JOIN Ndwh.Dim.Dimdate AS Threeweeksdate
                  ON Threeweeksdate.Date =
                     Threeweeksmssenddate
           LEFT JOIN Ndwh.Dim.Dimdate AS Twoweeksdate
                  ON Twoweeksdate.Date =
                     Twoweeksmssenddate
           LEFT JOIN Ndwh.Dim.Dimdate AS Oneweeksdate
                  ON Oneweeksdate.Date =
                    Apt.Oneweeksmssenddate
           LEFT JOIN Ndwh.Dim.Dimdate AS Onedaydate
                  ON Onedaydate.Date = Apt.Onedaysmssenddate
           LEFT JOIN Ndwh.Dim.Dimdate AS Missedappointmentdate
                  ON Missedappointmentdate.Date =
                    Apt.Missedappointmentsmssenddate
           LEFT JOIN Ndwh.Dim.Dimdate AS Tracingdate
                  ON Tracingdate.Date =
                    Apt.Tracingoutcomedate
           LEFT JOIN Ndwh.Dim.Dimdate AS Datereturnedtocare
                  ON Datereturnedtocare.Date =
                     Apt.Datereturnedtocare

    ALTER TABLE Ndwh.[Fact].FactUshauriAppointments
      ADD PRIMARY KEY(Factkey);
END
