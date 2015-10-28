/***********************************************************
*
* Project:       Kaplan Spend/Attribution Models (OAD/KB)
* Program Name:  import_all_data.sas
* Author:        U-degobah\rsowers
*
* Creation Date: <2014-08-17 21:18:24> 
* Time-stamp:    <2015-05-14 17:45:26>
*
* Input:         Exported inquiry, enrollment, and spending data
*
* Output:        Formatted SAS datasets with all detail
*
************************************************************/

options compress=yes;

%macro import_all_data(rawPath = C:\cygwin64\home\rsowers\projects\kaplan_model_v2\data\raw);

    libname rawlib "&rawPath";

    data rawlib.lead_source_map;
        infile "&rawPath\txt_files\lead_source_clean.txt"
            DSD DLM = '|' truncover lrecl=1024 firstobs=2;
        input lead_source :$100. lead_source_clean :$100.;
    run;

    /***********************************************************
     * Get the spending data
     ***********************************************************/
    
    data tmp_spending;
        infile "&rawPath\txt_files\KHEC_Spending_Data_2012_to_2015_out.txt"
            DSD DLM = '09'x truncover lrecl=1024 firstobs=2;
        input lead_source :$100. campus :$100. spending :best15. month :2. year :4.;
    run;

    proc sql noprint;
        create table rawlib.kaplan_spending_detail as select
            ((year*100)+month) as month,
            upcase(trim(campus)) as campus,
            upcase(trim(lead_source)) as media_category,
            (case when spending lt 0 then 0 else spending end) as spending format = dollar15.2
            from tmp_spending
            order by calculated month, calculated campus, calculated media_category, calculated spending;
        quit;
    run;

    /***********************************************************
     * Get the enrollment data
     ***********************************************************/

    data tmp_enroll;
        infile "&rawPath\txt_files\KHEC_2012_to_2015_Enroll_Data_out.txt"
            DSD DLM = '09'x truncover lrecl=1024 firstobs=2;
        input systudent_id :$20. last_name :$50. first_name :$50. student_id :$20. city :$50. state :$2.
              zip :$5. email :$50. lead_category :$100. lead_source :$100. status_code :$20.
              program :$100. prv_educ :$100. campus_orig :$100. lead_date_tmp :$10. enroll_date_tmp :$10.
              status_desc :$50. rep_last_name :$50. rep_first_name :$50. enroll_type :$50.
              mk_lead_import_id :$20. primary_date :$10. month_num :2. year_num :4. week :$10.
              data_type :$100. enroll_tally :2. campus :$100. media_category :$100.;
        month = ((year_num*100)+month_num);
        lead_date = ((input(scan(lead_date_tmp,3,"/"),4.)*10000)+(input(scan(lead_date_tmp,1,"/"),2.)*100)+input(scan(lead_date_tmp,2,"/"),2.));
        enroll_date = ((input(scan(enroll_date_tmp,3,"/"),4.)*10000)+(input(scan(enroll_date_tmp,1,"/"),2.)*100)+input(scan(enroll_date_tmp,2,"/"),2.));
    run;

    proc sql noprint;
        create table rawlib.kaplan_enrollment_detail as select
            student_id,
            upcase(trim(campus)) as campus,
            month,
            input(put(lead_date,z8.),yymmdd8.) as lead_date format=yymmdd10.,
            input(put(enroll_date,z8.),yymmdd8.) as enroll_date format=yymmdd10.,
            upcase(trim(last_name)) as last_name,
            upcase(trim(first_name)) as first_name,
            upcase(trim(city)) as city,
            upcase(trim(state)) as state,
            zip,
            upcase(trim(email)) as email,
            upcase(trim(media_category)) as media_category,
            upcase(trim(lead_category)) as lead_category,
            upcase(trim(lead_source)) as lead_source,
            upcase(trim(status_code)) as status_code,
            upcase(trim(status_desc)) as status_desc,
            upcase(trim(program)) as program,
            upcase(trim(prv_educ)) as prv_educ,
            (upcase(trim(rep_first_name))||" "||upcase(trim(rep_last_name))) as rep_name,
            upcase(trim(enroll_type)) as enroll_type,
            upcase(trim(data_type)) as data_type,
            upcase(trim(campus_orig)) as campus_orig,
            enroll_tally
            from tmp_enroll
            order by calculated campus, month, calculated lead_date, calculated media_category;
        quit;
    run;

    /***********************************************************
     * Get the lead data
     ***********************************************************/

    data tmp_lead_2012;
        infile "&rawPath\txt_files\KHEC_2012_Lead_Data_out.txt"
            DSD DLM = '09'x truncover lrecl=1024 firstobs=2;
        input systudent_id :$20.
            last_name :$50.
            first_name :$50.
            student_id :$20.
            phone :$15.
            address :$100.
            city :$50.
            state :$2.
            zip :$5.
            email :$50.
            lead_category :$100.
            lead_source :$100.
            status_code :$20.
            program :$100.
            prv_educ :$100.
            campus_orig :$100.
            lead_date_tmp :$10.
            status_desc :$50.
            rep_name :$50.
            mk_lead_import_id :$20.
            primary_date :$10.
            month_num :2.
            year_num :4.
            week :$10.
            data_type :$100.
            inquiry_tally :2.
            campus :$100.
            media_category :$100.;
        month = ((year_num*100)+month_num);
        lead_date = ((input(scan(lead_date_tmp,3,"/"),4.)*10000)+(input(scan(lead_date_tmp,1,"/"),2.)*100)+input(scan(lead_date_tmp,2,"/"),2.));
    run;

    data tmp_lead_2013;
        infile "&rawPath\txt_files\KHEC_2013_Lead_Data_out.txt"
            DSD DLM = '09'x truncover lrecl=1024 firstobs=2;
        input systudent_id :$20.
            last_name :$50.
            first_name :$50.
            student_id :$20.
            phone :$15.
            address :$100.
            city :$50.
            state :$2.
            zip :$5.
            email :$50.
            lead_category :$100.
            lead_source :$100.
            status_code :$20.
            program :$100.
            prv_educ :$100.
            campus_orig :$100.
            lead_date_tmp :$10.
            status_desc :$50.
            rep_name :$50.
            mk_lead_import_id :$20.
            primary_date :$10.
            month_num :2.
            year_num :4.
            week :$10.
            data_type :$100.
            inquiry_tally :2.
            campus :$100.
            media_category :$100.;
        month = ((year_num*100)+month_num);
        lead_date = ((input(scan(lead_date_tmp,3,"/"),4.)*10000)+(input(scan(lead_date_tmp,1,"/"),2.)*100)+input(scan(lead_date_tmp,2,"/"),2.));
    run;

    data tmp_lead_2014;
        infile "&rawPath\txt_files\KHEC_2014_Lead_Data_out.txt"
            DSD DLM = '09'x truncover lrecl=1024 firstobs=2;
        input systudent_id :$20.
            last_name :$50.
            first_name :$50.
            student_id :$20.
            phone :$15.
            address :$100.
            city :$50.
            state :$2.
            zip :$5.
            email :$50.
            lead_category :$100.
            lead_source :$100.
            status_code :$20.
            program :$100.
            prv_educ :$100.
            campus_orig :$100.
            lead_date_tmp :$10.
            status_desc :$50.
            rep_name :$50.
            mk_lead_import_id :$20.
            primary_date :$10.
            month_num :2.
            year_num :4.
            week :$10.
            data_type :$100.
            inquiry_tally :2.
            campus :$100.
            media_category :$100.;
        month = ((year_num*100)+month_num);
        lead_date = ((input(scan(lead_date_tmp,3,"/"),4.)*10000)+(input(scan(lead_date_tmp,1,"/"),2.)*100)+input(scan(lead_date_tmp,2,"/"),2.));
    run;

    data tmp_lead_2015;
        infile "&rawPath\txt_files\KHEC_2015_Lead_Data_out.txt"
            DSD DLM = '09'x truncover lrecl=1024 firstobs=2;
        input systudent_id :$20.
            last_name :$50.
            first_name :$50.
            student_id :$20.
            phone :$15.
            address :$100.
            city :$50.
            state :$2.
            zip :$5.
            email :$50.
            lead_category :$100.
            lead_source :$100.
            status_code :$20.
            program :$100.
            prv_educ :$100.
            campus_orig :$100.
            lead_date_tmp :$10.
            status_desc :$50.
            rep_name :$50.
            mk_lead_import_id :$20.
            primary_date :$10.
            month_num :2.
            year_num :4.
            week :$10.
            data_type :$100.
            inquiry_tally :2.
            campus :$100.
            media_category :$100.;
        month = ((year_num*100)+month_num);
        lead_date = ((input(scan(lead_date_tmp,3,"/"),4.)*10000)+(input(scan(lead_date_tmp,1,"/"),2.)*100)+input(scan(lead_date_tmp,2,"/"),2.));
    run;
    
    data tmp_inquiry;
        set tmp_lead_2012 tmp_lead_2013 tmp_lead_2014 tmp_lead_2015;
    run;

    proc sql noprint;
        create table rawlib.kaplan_inquiry_detail as select
            student_id,
            upcase(trim(campus)) as campus,
            month,
            input(put(lead_date,z8.),yymmdd8.) as lead_date format=yymmdd10.,
            upcase(trim(last_name)) as last_name,
            upcase(trim(first_name)) as first_name,
            upcase(trim(address)) as address,
            upcase(trim(city)) as city,
            upcase(trim(state)) as state,
            zip,
            phone,
            upcase(trim(email)) as email,
            upcase(trim(media_category)) as media_category,
            upcase(trim(lead_category)) as lead_category,
            upcase(trim(lead_source)) as lead_source,
            upcase(trim(status_code)) as status_code,
            upcase(trim(status_desc)) as status_desc,
            upcase(trim(program)) as program,
            upcase(trim(prv_educ)) as prv_educ,
            upcase(trim(rep_name)) as rep_name,
            upcase(trim(data_type)) as data_type,
            upcase(trim(campus_orig)) as campus_orig,
            inquiry_tally
            from tmp_inquiry
            order by calculated campus, month, calculated lead_date, calculated media_category;
        quit;
    run;

%mend import_all_data;

%import_all_data;

