/***********************************************************
*
* Project:       
* Program Name:  import_post_log_data.sas
* Author:        U-degobah\rsowers
*
* Creation Date: <2015-03-10 00:01:02> 
* Time-stamp:    <2015-03-10 01:54:52>
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

%macro import_post_log_data(modelPath = C:\cygwin64\home\rsowers\projects\kaplan_model_v2 ,
                            tvFile    = &modelPath\data\raw\post_logs\origTelevision.csv ,
                            printFile = &modelPath\data\raw\post_logs\origPrint.csv ,
                            radioFile = &modelPath\data\raw\post_logs\origRadio.csv ,
                            rawPath   = &modelPath\data\raw );

    libname rawlib "&rawPath";

/***********************************************************
 * Import the raw files
 ***********************************************************/
    
    data tmp_tv_data;
        infile "&tvFile" DSD DLM = "," truncover lrecl=1024 firstobs=2;
        input
            client :$200.
            vendor :$200.
            rotation :$200.
            post_log_date :$10.
            post_log_time :$10.
            dnis :$50.
            isci :$100.
            commercial_title :$200.
            creative_group :$200.
            dma :$200.;
    run;

    data tmp_print_data;
        infile "&printFile" DSD DLM = "," truncover lrecl=1024 firstobs=2;
        input
            client :$200.
            vendor :$200.
            rotation :$200.
            post_log_date :$10.
            post_log_time :$10.
            dnis :$50.
            isci :$100.
            commercial_title :$200.
            creative_group :$200.
            dma :$200.;
    run;
        
    data tmp_radio_data;
        infile "&radioFile" DSD DLM = "," truncover lrecl=1024 firstobs=2;
        input
            client :$200.
            vendor :$200.
            rotation :$200.
            post_log_date :$10.
            post_log_time :$10.
            dnis :$50.
            isci :$100.
            commercial_title :$200.
            creative_group :$200.
            dma :$200.;
    run;
    
/***********************************************************
 * Clean up the files and save as datasets
 ***********************************************************/

    proc sql noprint;
        create table rawlib.post_log_tv_raw (where=(not missing(campus))) as select
            (case when dma = "BAKERSFIELD" then "BAKERSFIELD"
            when dma = "BALTIMORE" then "BALTIMORE"
            when dma = "BEAUMONT-PORT ARTHUR" then "BEAUMONT"
            when dma = "CHARLOTTE" then "CHARLOTTE"
            when dma = "CORPUS CHRISTI" then "CORPUS CHRISTI"
            when dma = "DALLAS-FT. WORTH" then "DALLAS"
            when dma = "DAYTON" then "DAYTON"
            when dma = "EL PASO" then "EL PASO"
            when dma = "FRESNO-VISALIA" then "FRESNO"
            when dma = "HARRISBURG-LNCSTR-LEB-YORK" then "HARRISBURG"
            when dma = "INDIANAPOLIS" then "INDIANAPOLIS - SOUTHEAST"
            when dma = "LAREDO" then "LAREDO"
            when dma = "LAS VEGAS" then "LAS VEGAS"
            when dma = "LUBBOCK" then "LUBBOCK"
            when dma = "NASHVILLE" then "NASHVILLE"
            when dma = "PALM SPRINGS" then "PALM SPRINGS"
            when dma = "PHILADELPHIA" then "PHILADELPHIA"
            when dma = "PITTSBURGH" then "PITTSBURGH"
            when dma = "SACRAMNTO-STKTON-MODESTO" then "SACRAMENTO"
            when dma = "SAN ANTONIO" then "SAN ANTONIO - INGRAM"
            when dma = "SAN ANTONIO" then "SAN ANTONIO - SAN PEDRO"
            when dma = "SAN DIEGO" then "SAN DIEGO" end) as campus,
            input(trim(post_log_date),mmddyy10.) as post_log_date format=yymmdd10.,
            input(scan(post_log_time,1,":"),5.) as post_hour,
            (case when input(scan(post_log_time,2,":"),5.) <= 15 then "Q1"
                  when input(scan(post_log_time,2,":"),5.) <= 30 then "Q2"
                  when input(scan(post_log_time,2,":"),5.) <= 45 then "Q3" else "Q4" end) as post_minute,
            client,
            vendor,
            rotation,
            commercial_title,
            creative_group
            from tmp_tv_data;

        create table rawlib.post_log_tv as select
            campus,
            post_log_date,
            post_hour,
            post_minute,
            count(*) as show_count
            from rawlib.post_log_tv_raw
            group by campus, post_log_date, post_hour, post_minute
            order by campus, post_log_date, post_hour, post_minute;
        
        create table rawlib.post_log_print_raw (where=(not missing(campus))) as select
            (case when dma = "BAKERSFIELD" then "BAKERSFIELD"
            when dma = "BALTIMORE" then "BALTIMORE"
            when dma = "CORPUS CHRISTI" then "CORPUS CHRISTI"
            when dma = "DALLAS-FT. WORTH" then "DALLAS"
            when dma = "DALLAS-FT. WORTH" then "FORT WORTH"
            when dma = "EL PASO" then "EL PASO"
            when dma = "INDIANAPOLIS" then "INDIANAPOLIS - SOUTHEAST"
            when dma = "LAS VEGAS" then "LAS VEGAS"
            when dma = "PHILADELPHIA" then "PHILADELPHIA"
            when dma = "PITTSBURGH" then "PITTSBURGH"
            when dma = "SAN DIEGO" then "SAN DIEGO" end) as campus,
            input(trim(post_log_date),mmddyy10.) as post_log_date format=yymmdd10.,
            input(scan(post_log_time,1,":"),5.) as post_hour,
            (case when input(scan(post_log_time,2,":"),5.) <= 15 then "Q1"
                  when input(scan(post_log_time,2,":"),5.) <= 30 then "Q2"
                  when input(scan(post_log_time,2,":"),5.) <= 45 then "Q3" else "Q4" end) as post_minute,
            client,
            vendor,
            rotation,
            commercial_title,
            creative_group
            from tmp_print_data;
        
        create table rawlib.post_log_print as select
            campus,
            post_log_date,
            count(*) as print_count
            from rawlib.post_log_print
            group by campus, post_log_date
            order by campus, post_log_date;
        
        create table rawlib.post_log_radio_raw (where=(not missing(campus))) as select
            (case when dma = "BAKERSFIELD" then "BAKERSFIELD"
            when dma = "LAREDO" then "LAREDO"
            when dma = "LUBBOCK" then "LUBBOCK"
            when dma = "NASHVILLE" then "NASHVILLE"
            when dma = "PALM SPRINGS" then "PALM SPRINGS"
            when dma = "SAN DIEGO" then "SAN DIEGO" end) as campus,
            input(trim(post_log_date),mmddyy10.) as post_log_date format=yymmdd10.,
            input(scan(post_log_time,1,":"),5.) as post_hour,
            (case when input(scan(post_log_time,2,":"),5.) <= 15 then "Q1"
                  when input(scan(post_log_time,2,":"),5.) <= 30 then "Q2"
                  when input(scan(post_log_time,2,":"),5.) <= 45 then "Q3" else "Q4" end) as post_minute,
            client,
            vendor,
            rotation,
            commercial_title,
            creative_group
            from tmp_radio_data;

        create table rawlib.post_log_radio as select
            campus,
            post_log_date,
            post_hour,
            post_minute,
            count(*) as show_count
            from rawlib.post_log_radio_raw
            group by campus, post_log_date, post_hour, post_minute
            order by campus, post_log_date, post_hour, post_minute;
        quit;
    run;

%mend import_post_log_data;

%import_post_log_data;

