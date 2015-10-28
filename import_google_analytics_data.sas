/***********************************************************
*
* Project:       
* Program Name:  import_google_analytics_data.sas
* Author:        U-degobah\rsowers
*
* Creation Date: <2015-03-09 22:36:12> 
* Time-stamp:    <2015-03-10 00:05:21>
*
* Input:
*
* Output:
*
* Purpose:
*
* Modified:
*
************************************************************/

%macro import_google_analytics_data(modelPath = C:\cygwin64\home\rsowers\projects\kaplan_model_v2 ,
                                    gaFile    = &modelPath\data\raw\google_analytics\ga_dump_201408_201503.txt ,
                                    rawPath   = &modelPath\data\raw );

    libname rawlib "&rawPath";
    
    data tmp_ga_data;
        infile "&gaFile" DSD DLM = "," truncover lrecl=1024 firstobs=2;
        input
            ga_account :$200.
            ga_profile :$200.
            ga_minute :5.
            ga_hour :5.
            ga_date :$10.
            ga_week :$10.
            ga_users :10.
            ga_sessions :10.
            ga_new_users :10.
            ga_returning_users :10.
            ga_avg_session_length :$10.
            ga_pageviews :10.
            ga_hits :10.;
    run;

    proc sql noprint;
        create table ga_data_raw as select
            ga_account,
            ga_profile,
            (case when upcase(ga_profile) contains "BROOMALL"                  then "BROOMALL"  
            when upcase(ga_profile) contains "FRANKLIN MILLS"            then "FRANKLIN MILLS"
            when upcase(ga_profile) contains "HARRISBURG"                then "HARRISBURG"
            when upcase(ga_profile) contains "PHILADELPHIA"              then "PHILADELPHIA"
            when upcase(ga_profile) contains "PITTSBURGH"                then "PITTSBURGH"
            when upcase(ga_profile) contains "ARLINGTON"	           then "ARLINGTON"
            when upcase(ga_profile) contains "BAKERSFIELD"	           then "BAKERSFIELD"
            when upcase(ga_profile) contains "BROWNSVILLE"	           then "BROWNSVILLE"
            when upcase(ga_profile) contains "CHARLOTTE"	           then "CHARLOTTE"
            when upcase(ga_profile) contains "CHULAVISTA"	           then "CHULA VISTA"
            when upcase(ga_profile) contains "CORPUS-CHRISTI"	           then "CORPUS CHRISTI"
            when upcase(ga_profile) contains "DALLAS"		           then "DALLAS"
            when upcase(ga_profile) contains "DAYTON"		           then "DAYTON"
            when upcase(ga_profile) contains "EL-PASO"	           then "EL PASO"
            when upcase(ga_profile) contains "FORT-WORTH"	           then "FORT WORTH"
            when upcase(ga_profile) contains "FRESNO"		           then "FRESNO"
            when upcase(ga_profile) contains "HAMMOND" 	           then "HAMMOND"
            when upcase(ga_profile) contains "INGRAM - (W)SAN-ANTONIO"   then "SAN ANTONIO - INGRAM"
            when upcase(ga_profile) contains "LAREDO"			   then "LAREDO"
            when upcase(ga_profile) contains "LAS-VEGAS"		   then "LAS VEGAS"
            when upcase(ga_profile) contains "LUBBOCK"		   then "LUBBOCK"
            when upcase(ga_profile) contains "MCALLEN"		   then "MCALLEN"
            when upcase(ga_profile) contains "MODESTO"		   then "MODESTO"
            when upcase(ga_profile) contains "NASHVILLE"		   then "NASHVILLE"
            when upcase(ga_profile) contains "NORTH-HOLLYWOOD"	   then "NORTH HOLLYWOOD"
            when upcase(ga_profile) contains "PALM-SPRINGS"		   then "PALM SPRINGS"
            when upcase(ga_profile) contains "RIVERSIDE"		   then "RIVERSIDE"
            when upcase(ga_profile) contains "SEINDIANAPOLIS"		   then "INDIANAPOLIS - SOUTHEAST"
            when upcase(ga_profile) contains "SACRAMENTO"		   then "SACRAMENTO"
            when upcase(ga_profile) contains "SAN-DIEGO"		   then "SAN DIEGO"
            when upcase(ga_profile) contains "SANPEDRO - (N)SAN-ANTONIO" then "SAN ANTONIO - SAN PEDRO"
            when upcase(ga_profile) contains "VISTA"                     then "VISTA" else "DELETE" end) as campus,
            input(trim(ga_date),mmddyy10.) as ga_date format=yymmdd10.,
            ga_hour,
            (case when ga_minute <=15 then "Q1"
                  when ga_minute <=30 then "Q2"
                  when ga_minute <=45 then "Q3" else "Q4" end) as ga_minute,
            ga_users,
            ga_new_users,
            ga_returning_users,
            ga_hits
            from tmp_ga_data
            order by ga_profile, ga_date, ga_hour, ga_minute;

        create table rawlib.ga_data_raw as select
            campus,
            ga_date,
            ga_hour,
            ga_minute,
            sum(ga_users) as ga_users,
            sum(ga_new_users) as ga_new_users,
            sum(ga_returning_users) as ga_returning_users,
            sum(ga_hits) as ga_hits
            from ga_data_raw
            where upcase(campus) ne "DELETE"
            group by campus, ga_date, ga_hour, ga_minute
            order by campus, ga_date, ga_hour, ga_minute;
        quit;
    run;

    proc sql;
        select distinct campus from rawlib.kaplan_inquiry_detail; 
        quit;
    run;
    
%mend import_google_analytics_data;

%import_google_analytics_data;

