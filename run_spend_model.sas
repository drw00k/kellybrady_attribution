/***********************************************************
*
* Project:       Kaplan Spend/Attribution Models (OAD/KB)
* Program Name:  runSpendModel.sas
* Author:        U-degobah\rsowers
*
* Creation Date: <2014-09-08 00:50:22> 
* Time-stamp:    <2015-09-24 21:40:59>
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

%macro runSpendModel(inqData          = kaplan_inquiry_detail ,
                     enrData          = kaplan_enrollment_detail ,
                     spendData        = kaplan_spending_detail ,
                     attribData       = outlib.attrib_long_data ,
                     modelStart       = 201201 ,
                     modelEnd         = 201503 ,
                     convRateLookback = 201412 ,
                     modelPath        = C:\cygwin64\home\rsowers\projects\kaplan_model_v2 ,
                     libPath          = &modelPath\lib\spend ,
                     dataPath         = &modelPath\data\spend ,
                     rawPath          = &modelPath\data\raw ,
                     tmpPath          = &modelPath\data\tmp ,
                     getRawData       = 1 ,
                     makeModelData    = 1 ,
                     runHistCoefs     = 1 ,
                     testHistCoefs    = 1 ,
                     makeAdjFactor    = 1 );

    /***********************************************************
     * Define where to get and put the data
     ***********************************************************/
    
    libname outlib "&dataPath";
    libname rawlib "&rawPath";
    libname tmplib "&tmpPath";

    /***********************************************************
     * Include all needed code
     ***********************************************************/
    
    %include "&libPath\getSpendingData.sas";
    %include "&libPath\getDetailData.sas";
    %include "&libPath\combineModelData.sas";
    %include "&libPath\interpolateData.sas";
    %include "&libPath\createModelCoefs.sas";
    %include "&libPath\testHistoricalCoefs.sas";
    %include "&libPath\makeAdjFactor.sas";
    %include "&libPath\makePredSpend.sas";

    /***********************************************************
     * Bring in all needed data and format it
     ***********************************************************/

    %if &getRawData = 1 %then %do;
        %getSpendingData( inDS = rawlib.&spendData, outDS = tmp_spend_data );
        
        %getDetailData(inDS       = rawlib.&inqData ,
                       outDS      = tmp_inq_monthly_data ,
                       spendDS    = tmp_spend_data ,
                       startMonth = &modelStart ,
                       lastMonth  = &modelEnd ,
                       prefix     = inq );

        %getDetailData(inDS       = rawlib.&enrData ,
                       outDS      = tmp_enr_monthly_data ,
                       spendDS    = tmp_spend_data ,
                       startMonth = &modelStart ,
                       lastMonth  = &modelEnd ,
                       prefix     = enr );
        %end;

    /***********************************************************
     * Combine all of the data into a single model dataset
     ***********************************************************/

    %if &makeModelData = 1 %then %do;
        %combineModelData(inqDS = tmp_inq_monthly_data ,
                          enrDS = tmp_enr_monthly_data ,
                          outDS = outlib.spend_model_data_raw);

        %interpolateData(inDS          = outlib.spend_model_data_raw,
                         outDS         = outlib.spend_model_data ,
                         convDS        = outlib.conversion_rates ,
                         convRateStart = &modelEnd ,
                         convRateEnd   = &convRateLookback );
        %end;

    
    /***********************************************************
     * Create model coefficients for entire period
     ***********************************************************/

    %if &runHistCoefs = 1 %then %do;
        %createModelCoefs(inDS     = outlib.spend_model_data , 
                          outDS    = outlib.hist_model_coefs ,
                          lookback = 6 );
    %end;

    proc export data = outlib.spend_model_data
        outfile = "&modelPath\spend_model_data.xls" 
        dbms = excel2000 replace;
        sheet = "Raw Data"; 
    run;

    proc export data = outlib.hist_model_coefs
        outfile = "&modelPath\hist_model_coefs.xls" 
        dbms = excel2000 replace;
        sheet = "Raw Data"; 
    run;

    /***********************************************************
     * Test the historical data to check for high correlations
     ***********************************************************/

    %if &testHistCoefs = 1 %then %do;
        %testHistoricalCoefs(coefDS        = outlib.hist_model_coefs ,
                             modelDS       = outlib.spend_model_data ,
                             outDS         = outlib.hist_test_final ,
                             coef_lookback = 3 );
    %end;

    /***********************************************************
     * Make historical adjustment factor and test
     ***********************************************************/

    %if &makeAdjFactor = 1 %then %do;
        %makeAdjFactor(inDS     = outlib.hist_test_final ,
                       outDS    = outlib.hist_final_with_adj ,
                       adjMonth = &modelEnd ,
                       outPath  = &modelPath );
    %end;

    proc export data = outlib.hist_final_with_adj
        outfile = "&modelPath\hist_final_with_adj.xls" 
        dbms = excel2000 replace;
        sheet = "Raw Data"; 
    run;

    endsas;

    /***********************************************************
     * Create model data
     ***********************************************************/

    proc sql noprint;
        create table tmp_raw_model_data as select
            "ACTUAL" as data_type,
            month,
            campus,
            media_category,
            inq_count,
            enr_count,
            monthly_spend
            from outlib.spend_model_data (where=(month le &modelEnd));

        create table tmp_raw_model_data_9 as select
            "MODEL" as data_type,
            201504 as month,
            campus,
            media_category,
            inq_count,
            enr_count,
            monthly_spend
            from outlib.spend_model_data
            where month = &modelEnd;

        create table tmp_raw_model_data_10 as select
            "MODEL" as data_type,
            201505 as month,
            campus,
            media_category,
            inq_count,
            enr_count,
            monthly_spend
            from outlib.spend_model_data
            where month = &modelEnd;

        create table tmp_raw_model_data_11 as select
            "MODEL" as data_type,
            201506 as month,
            campus,
            media_category,
            inq_count,
            enr_count,
            monthly_spend
            from outlib.spend_model_data
            where month = &modelEnd;

        create table tmp_raw_model_data_12 as select
            "MODEL" as data_type,
            201507 as month,
            campus,
            media_category,
            inq_count,
            enr_count,
            monthly_spend
            from outlib.spend_model_data
            where month = &modelEnd;

        create table tmp_raw_model_data_13 as select
            "MODEL" as data_type,
            201508 as month,
            campus,
            media_category,
            inq_count,
            enr_count,
            monthly_spend
            from outlib.spend_model_data
            where month = &modelEnd;

        create table tmp_raw_model_data_14 as select
            "MODEL" as data_type,
            201509 as month,
            campus,
            media_category,
            inq_count,
            enr_count,
            monthly_spend
            from outlib.spend_model_data
            where month = &modelEnd;

        create table tmp_raw_model_data_15 as select
            "MODEL" as data_type,
            201510 as month,
            campus,
            media_category,
            inq_count,
            enr_count,
            monthly_spend
            from outlib.spend_model_data
            where month = &modelEnd;

        create table tmp_raw_model_data_16 as select
            "MODEL" as data_type,
            201511 as month,
            campus,
            media_category,
            inq_count,
            enr_count,
            monthly_spend
            from outlib.spend_model_data
            where month = &modelEnd;

        create table tmp_raw_model_data_17 as select
            "MODEL" as data_type,
            201512 as month,
            campus,
            media_category,
            inq_count,
            enr_count,
            monthly_spend
            from outlib.spend_model_data
            where month = &modelEnd;
        
        
        quit;
    run;

    data tmp_raw_model_data_full;
        set tmp_raw_model_data
            tmp_raw_model_data_9
            tmp_raw_model_data_10
            tmp_raw_model_data_11
            tmp_raw_model_data_12
            tmp_raw_model_data_13
            tmp_raw_model_data_14
            tmp_raw_model_data_15
            tmp_raw_model_data_16
            tmp_raw_model_data_17;
    run;

    proc sql noprint;
        create table modeled_data as select
            month,
            campus,
            media_category,
            modeled_inq_count,
            modeled_enr_count,
            coef,
            intercept,
            convert_rate,
            adj_factor,
            monthly_spend as monthly_spend_fill
            from outlib.hist_final_with_adj
            order by month, campus, media_category;

        create table tmp_adj_factor_addon as select
            campus,
            media_category,
            max(adj_factor) as adj_factor
            from modeled_data
            where not missing(adj_factor)
            group by campus, media_category;

        create table outlib.full_dashboard_data (where=(month gt &modelEnd)) as select
            detaildata.month,
            detaildata.campus,
            detaildata.media_category,

            (case when not missing(modeldata.modeled_inq_count) then modeldata.modeled_inq_count
                  else detaildata.inq_count end) as display_inq_count,

            (case when not missing(modeldata.modeled_enr_count) then modeldata.modeled_enr_count
                  else detaildata.enr_count end) as display_enr_count,

            (case when detaildata.month ge &modelEnd then modeldata.monthly_spend_fill
                  else detaildata.monthly_spend end) as monthly_spend format=dollar12.,

            modeldata.coef,
            modeldata.intercept,

            (case when missing(modeldata.convert_rate) then conv_rates.convert_rate
                  else modeldata.convert_rate end) as convert_rate format=percent8.2,
            
            (case when missing(modeldata.adj_factor) and not missing(addon.adj_factor) then addon.adj_factor
                  when missing(modeldata.adj_factor) and missing(addon.adj_factor) then 1
                  else modeldata.adj_factor end) as adj_factor,
            
            detaildata.inq_count,
            detaildata.enr_count,

            calculated display_inq_count as modeled_inq_count,
            calculated display_enr_count as modeled_enr_count

            from tmp_raw_model_data_full as detaildata
            left join modeled_data as modeldata on
            (detaildata.month = modeldata.month and
             detaildata.campus = modeldata.campus and
             detaildata.media_category = modeldata.media_category)
            left join tmp_adj_factor_addon as addon on
            (detaildata.campus = addon.campus and detaildata.media_category = addon.media_category)
            left join outlib.conversion_rates as conv_rates on
            (detaildata.campus = conv_rates.campus and detaildata.media_category = conv_rates.media_category)
            order by detaildata.campus, detaildata.media_category, detaildata.month;
        quit;
    run;

    proc sort data = outlib.full_dashboard_data nodupkey;
        by campus media_category month
            display_inq_count
            display_enr_count
            monthly_spend
            coef
            intercept
            convert_rate
            adj_factor
            inq_count
            enr_count
            modeled_inq_count
            modeled_enr_count;
    run;

    proc transpose data = outlib.full_dashboard_data
        out = full_inq_data (drop = _NAME_)
        prefix=inq_;
        by campus media_category;
        id month;
        var display_inq_count;
    run;

    proc transpose data = outlib.full_dashboard_data
        out = full_enr_data (drop = _NAME_)
        prefix=enr_;
        by campus media_category;
        id month;
        var display_enr_count;
    run;
    
    proc transpose data = outlib.full_dashboard_data
        out = full_spend_data (drop = _NAME_)
        prefix=spend_;
        by campus media_category;
        id month;
        var monthly_spend;
    run;
    
    proc transpose data = outlib.full_dashboard_data
        out = full_coef_data (drop = _NAME_)
        prefix=coef_;
        by campus media_category;
        id month;
        var coef;
    run;

    proc transpose data = outlib.full_dashboard_data
        out = full_intercept_data (drop = _NAME_)
        prefix=intercept_;
        by campus media_category;
        id month;
        var intercept;
    run;

    proc transpose data = outlib.full_dashboard_data
        out = full_convrate_data (drop = _NAME_)
        prefix=conv_rate_;
        by campus media_category;
        id month;
        var convert_rate;
    run;
    
    proc transpose data = outlib.full_dashboard_data
        out = full_adj_factor (drop = _NAME_)
        prefix=adj_factor_;
        by campus media_category;
        id month;
        var adj_factor;
    run;

    proc transpose data = outlib.full_dashboard_data
        out = full_mod_inq_count (drop = _NAME_)
        prefix=mod_inq_;
        by campus media_category;
        id month;
        var modeled_inq_count;
    run;

    proc transpose data = outlib.full_dashboard_data
        out = full_mod_enr_count (drop = _NAME_)
        prefix=mod_enr_;
        by campus media_category;
        id month;
        var modeled_enr_count;
    run;

    proc sort data = full_inq_data      ; by campus media_category; run;
    proc sort data = full_enr_data	; by campus media_category; run;
    proc sort data = full_spend_data    ; by campus media_category; run;
    proc sort data = full_coef_data	; by campus media_category; run;
    proc sort data = full_intercept_data; by campus media_category; run;
    proc sort data = full_convrate_data ; by campus media_category; run;
    proc sort data = full_adj_factor    ; by campus media_category; run;
    proc sort data = full_mod_inq_count ; by campus media_category; run;
    proc sort data = full_mod_enr_count ; by campus media_category; run;

    data full_dashboard_data_pre;
        merge
            full_inq_data      
            full_enr_data	
            full_spend_data    
            full_coef_data	
            full_intercept_data
            full_convrate_data 
            full_adj_factor    
            full_mod_inq_count 
            full_mod_enr_count;
        by campus media_category;
    run;

    proc sql noprint;
        create table outlib.full_dashboard_data_final as select
            campus,
            media_category,
            inq_201504,
            inq_201505,
            inq_201506,
            inq_201507,
            inq_201508,
            inq_201509,
            inq_201510,
            inq_201511,
            inq_201512,
                        
            enr_201504,
            enr_201505,
            enr_201506,
            enr_201507,
            enr_201508,
            enr_201509,
            enr_201510,
            enr_201511,
            enr_201512,

            spend_201504,
            spend_201505,
            spend_201506,
            spend_201507,
            spend_201508,
            spend_201509,
            spend_201510,
            spend_201511,
            spend_201512,

            coef_201504,
            coef_201505,
            coef_201506,
            coef_201507,
            coef_201508,
            coef_201509,
            coef_201510,
            coef_201511,
            coef_201512,

            intercept_201504,
            intercept_201505,
            intercept_201506,
            intercept_201507,
            intercept_201508,
            intercept_201509,
            intercept_201510,
            intercept_201511,
            intercept_201512,

            conv_rate_201504,
            conv_rate_201505,
            conv_rate_201506,
            conv_rate_201507,
            conv_rate_201508,
            conv_rate_201509,
            conv_rate_201510,
            conv_rate_201511,
            conv_rate_201512,

            adj_factor_201504,
            adj_factor_201505,
            adj_factor_201506,
            adj_factor_201507,
            adj_factor_201508,
            adj_factor_201509,
            adj_factor_201510,
            adj_factor_201511,
            adj_factor_201512,

            mod_inq_201504,
            mod_inq_201505,
            mod_inq_201506,
            mod_inq_201507,
            mod_inq_201508,
            mod_inq_201509,
            mod_inq_201510,
            mod_inq_201511,
            mod_inq_201512,

            mod_enr_201504,
            mod_enr_201505,
            mod_enr_201506,
            mod_enr_201507,
            mod_enr_201508,
            mod_enr_201509,
            mod_enr_201510,
            mod_enr_201511,
            mod_enr_201512

            from full_dashboard_data_pre
            order by campus, media_category;

        create table outlib.full_dashboard_data_models as select
            campus,
            media_category,
            inq_201504,
            inq_201505,
            inq_201506,
            inq_201507,
            inq_201508,
            inq_201509,
            inq_201510,
            inq_201511,
            inq_201512,
                        
            enr_201504,
            enr_201505,
            enr_201506,
            enr_201507,
            enr_201508,
            enr_201509,
            enr_201510,
            enr_201511,
            enr_201512,

            spend_201504,
            spend_201505,
            spend_201506,
            spend_201507,
            spend_201508,
            spend_201509,
            spend_201510,
            spend_201511,
            spend_201512,

            coef_201504,
            coef_201505,
            coef_201506,
            coef_201507,
            coef_201508,
            coef_201509,
            coef_201510,
            coef_201511,
            coef_201512,

            intercept_201504,
            intercept_201505,
            intercept_201506,
            intercept_201507,
            intercept_201508,
            intercept_201509,
            intercept_201510,
            intercept_201511,
            intercept_201512,

            conv_rate_201504,
            conv_rate_201505,
            conv_rate_201506,
            conv_rate_201507,
            conv_rate_201508,
            conv_rate_201509,
            conv_rate_201510,
            conv_rate_201511,
            conv_rate_201512,

            adj_factor_201504,
            adj_factor_201505,
            adj_factor_201506,
            adj_factor_201507,
            adj_factor_201508,
            adj_factor_201509,
            adj_factor_201510,
            adj_factor_201511,
            adj_factor_201512,

            mod_inq_201504,
            mod_inq_201505,
            mod_inq_201506,
            mod_inq_201507,
            mod_inq_201508,
            mod_inq_201509,
            mod_inq_201510,
            mod_inq_201511,
            mod_inq_201512,

            mod_enr_201504,
            mod_enr_201505,
            mod_enr_201506,
            mod_enr_201507,
            mod_enr_201508,
            mod_enr_201509,
            mod_enr_201510,
            mod_enr_201511,
            mod_enr_201512

            from full_dashboard_data_pre
            order by campus, media_category;

        create table tmp_data_output as select
            campus,
            (put(month,z8.)||" "||media_category) as group_var,
            (case when missing(monthly_spend) then 0 else monthly_spend end) as monthly_spend,
            coef,
            intercept,
            (case when adj_factor eq 0 then 1 else adj_factor end) as adj_factor,
            convert_rate as conv,
            (case when missing(display_inq_count) then 0 else display_inq_count end) as inq_count
            from outlib.full_dashboard_data
            where month ge &modelEnd
            order by campus, group_var;
        quit;
    run;

    proc transpose data = tmp_data_output
        out = med_full_spend_data (drop = _NAME_)
        prefix=sp_;
        by campus;
        id group_var;
        var monthly_spend;
    run;

    proc transpose data = tmp_data_output
        out = med_full_coef_data (drop = _NAME_)
        prefix=cf_;
        by campus;
        id group_var;
        var coef;
    run;

    proc transpose data = tmp_data_output
        out = med_full_intercept_data (drop = _NAME_)
        prefix=int_;
        by campus;
        id group_var;
        var intercept;
    run;

    proc transpose data = tmp_data_output
        out = med_full_adj_factor_data (drop = _NAME_)
        prefix=af_;
        by campus;
        id group_var;
        var adj_factor;
    run;

    proc transpose data = tmp_data_output
        out = med_full_conv_data (drop = _NAME_)
        prefix=cv_;
        by campus;
        id group_var;
        var conv;
    run;

    proc transpose data = tmp_data_output
        out = med_full_inq_data (drop = _NAME_)
        prefix=inq_;
        by campus;
        id group_var;
        var inq_count;
    run;
    
    proc sort data = med_full_spend_data;      by campus; run;
    proc sort data = med_full_coef_data;       by campus; run;
    proc sort data = med_full_intercept_data;  by campus; run;
    proc sort data = med_full_adj_factor_data; by campus; run;
    proc sort data = med_full_conv_data;       by campus; run;
    proc sort data = med_full_inq_data;        by campus; run;

    data med_full_data_out;
        merge
            med_full_spend_data
            med_full_conv_data
            med_full_coef_data
            med_full_intercept_data
            med_full_adj_factor_data
            med_full_inq_data;
    run;
    
    proc sql noprint;
        create table med_full_data_out_201504 as select
            campus,
            201504 as month,

            sp_00201504_AGGREGATOR as spend_AGGREGATOR,
            sp_00201504_SEM as spend_SEM,
            sp_00201504_TELEVISION as spend_TELEVISION,
            sp_00201504_WEBSITE as spend_WEBSITE,
            sp_00201504_PRINT as spend_PRINT,
            sp_00201504_RADIO as spend_RADIO,
            sp_00201504_SPECIALTY as spend_SPECIALTY,
            sp_00201504_RECIRCULATED as spend_RECIRCULATED,
            sp_00201504_YELLOW_PAGES as spend_YELLOW_PAGES,
            sp_00201504_DIRECT_MAIL as spend_DIRECT_MAIL,
            sp_00201504_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            sp_00201504_INTERNET as spend_INTERNET,
            sp_00201504_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            sp_00201504_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,

            cv_00201504_AGGREGATOR as cv_AGGREGATOR,
            cv_00201504_SEM as cv_SEM,
            cv_00201504_TELEVISION as cv_TELEVISION,
            cv_00201504_WEBSITE as cv_WEBSITE,
            cv_00201504_PRINT as cv_PRINT,
            cv_00201504_RADIO as cv_RADIO,
            cv_00201504_SPECIALTY as cv_SPECIALTY,
            cv_00201504_RECIRCULATED as cv_RECIRCULATED,
            cv_00201504_YELLOW_PAGES as cv_YELLOW_PAGES,
            cv_00201504_DIRECT_MAIL as cv_DIRECT_MAIL,
            cv_00201504_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            cv_00201504_INTERNET as cv_INTERNET,
            cv_00201504_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            cv_00201504_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,

            cf_00201504_AGGREGATOR as coef_AGGREGATOR,
            cf_00201504_SEM as coef_SEM,
            cf_00201504_TELEVISION as coef_TELEVISION,
            cf_00201504_WEBSITE as coef_WEBSITE,
            cf_00201504_PRINT as coef_PRINT,
            cf_00201504_RADIO as coef_RADIO,
            cf_00201504_SPECIALTY as coef_SPECIALTY,
            cf_00201504_RECIRCULATED as coef_RECIRCULATED,
            cf_00201504_YELLOW_PAGES as coef_YELLOW_PAGES,
            cf_00201504_DIRECT_MAIL as coef_DIRECT_MAIL,
            cf_00201504_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT,
            cf_00201504_INTERNET as coef_INTERNET,
            cf_00201504_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG,
            cf_00201504_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL,

            int_00201504_AGGREGATOR as intercept_AGGREGATOR,
            int_00201504_SEM as intercept_SEM,
            int_00201504_TELEVISION as intercept_TELEVISION,
            int_00201504_WEBSITE as intercept_WEBSITE,
            int_00201504_PRINT as intercept_PRINT,
            int_00201504_RADIO as intercept_RADIO,
            int_00201504_SPECIALTY as intercept_SPECIALTY,
            int_00201504_RECIRCULATED as intercept_RECIRCULATED,
            int_00201504_YELLOW_PAGES as intercept_YELLOW_PAGES,
            int_00201504_DIRECT_MAIL as intercept_DIRECT_MAIL,
            int_00201504_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT,
            int_00201504_INTERNET as intercept_INTERNET,
            int_00201504_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG,
            int_00201504_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL,

            af_00201504_AGGREGATOR as adj_factor_AGGREGATOR,
            af_00201504_SEM as adj_factor_SEM,
            af_00201504_TELEVISION as adj_factor_TELEVISION,
            af_00201504_WEBSITE as adj_factor_WEBSITE,
            af_00201504_PRINT as adj_factor_PRINT,
            af_00201504_RADIO as adj_factor_RADIO,
            af_00201504_SPECIALTY as adj_factor_SPECIALTY,
            af_00201504_RECIRCULATED as adj_factor_RECIRCULATED,
            af_00201504_YELLOW_PAGES as adj_factor_YELLOW_PAGES,
            af_00201504_DIRECT_MAIL as adj_factor_DIRECT_MAIL,
            af_00201504_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT,
            af_00201504_INTERNET as adj_factor_INTERNET,
            af_00201504_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG,
            af_00201504_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL,

            inq_00201504_AGGREGATOR as inq_AGGREGATOR,
            inq_00201504_SEM as inq_SEM,
            inq_00201504_TELEVISION as inq_TELEVISION,
            inq_00201504_WEBSITE as inq_WEBSITE,
            inq_00201504_PRINT as inq_PRINT,
            inq_00201504_RADIO as inq_RADIO,
            inq_00201504_SPECIALTY as inq_SPECIALTY,
            inq_00201504_RECIRCULATED as inq_RECIRCULATED,
            inq_00201504_YELLOW_PAGES as inq_YELLOW_PAGES,
            inq_00201504_DIRECT_MAIL as inq_DIRECT_MAIL,
            inq_00201504_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            inq_00201504_INTERNET as inq_INTERNET,
            inq_00201504_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            inq_00201504_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL
            
            from med_full_data_out
            order by campus;


        create table med_full_data_out_201505 as select
            campus,
            201505 as month,

            sp_00201505_AGGREGATOR as spend_AGGREGATOR,
            sp_00201505_SEM as spend_SEM,
            sp_00201505_TELEVISION as spend_TELEVISION,
            sp_00201505_WEBSITE as spend_WEBSITE,
            sp_00201505_PRINT as spend_PRINT,
            sp_00201505_RADIO as spend_RADIO,
            sp_00201505_SPECIALTY as spend_SPECIALTY,
            sp_00201505_RECIRCULATED as spend_RECIRCULATED,
            sp_00201505_YELLOW_PAGES as spend_YELLOW_PAGES,
            sp_00201505_DIRECT_MAIL as spend_DIRECT_MAIL,
            sp_00201505_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            sp_00201505_INTERNET as spend_INTERNET,
            sp_00201505_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            sp_00201505_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,

            cv_00201505_AGGREGATOR as cv_AGGREGATOR,
            cv_00201505_SEM as cv_SEM,
            cv_00201505_TELEVISION as cv_TELEVISION,
            cv_00201505_WEBSITE as cv_WEBSITE,
            cv_00201505_PRINT as cv_PRINT,
            cv_00201505_RADIO as cv_RADIO,
            cv_00201505_SPECIALTY as cv_SPECIALTY,
            cv_00201505_RECIRCULATED as cv_RECIRCULATED,
            cv_00201505_YELLOW_PAGES as cv_YELLOW_PAGES,
            cv_00201505_DIRECT_MAIL as cv_DIRECT_MAIL,
            cv_00201505_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            cv_00201505_INTERNET as cv_INTERNET,
            cv_00201505_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            cv_00201505_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,

            cf_00201505_AGGREGATOR as coef_AGGREGATOR,
            cf_00201505_SEM as coef_SEM,
            cf_00201505_TELEVISION as coef_TELEVISION,
            cf_00201505_WEBSITE as coef_WEBSITE,
            cf_00201505_PRINT as coef_PRINT,
            cf_00201505_RADIO as coef_RADIO,
            cf_00201505_SPECIALTY as coef_SPECIALTY,
            cf_00201505_RECIRCULATED as coef_RECIRCULATED,
            cf_00201505_YELLOW_PAGES as coef_YELLOW_PAGES,
            cf_00201505_DIRECT_MAIL as coef_DIRECT_MAIL,
            cf_00201505_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT,
            cf_00201505_INTERNET as coef_INTERNET,
            cf_00201505_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG,
            cf_00201505_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL,

            int_00201505_AGGREGATOR as intercept_AGGREGATOR,
            int_00201505_SEM as intercept_SEM,
            int_00201505_TELEVISION as intercept_TELEVISION,
            int_00201505_WEBSITE as intercept_WEBSITE,
            int_00201505_PRINT as intercept_PRINT,
            int_00201505_RADIO as intercept_RADIO,
            int_00201505_SPECIALTY as intercept_SPECIALTY,
            int_00201505_RECIRCULATED as intercept_RECIRCULATED,
            int_00201505_YELLOW_PAGES as intercept_YELLOW_PAGES,
            int_00201505_DIRECT_MAIL as intercept_DIRECT_MAIL,
            int_00201505_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT,
            int_00201505_INTERNET as intercept_INTERNET,
            int_00201505_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG,
            int_00201505_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL,

            af_00201505_AGGREGATOR as adj_factor_AGGREGATOR,
            af_00201505_SEM as adj_factor_SEM,
            af_00201505_TELEVISION as adj_factor_TELEVISION,
            af_00201505_WEBSITE as adj_factor_WEBSITE,
            af_00201505_PRINT as adj_factor_PRINT,
            af_00201505_RADIO as adj_factor_RADIO,
            af_00201505_SPECIALTY as adj_factor_SPECIALTY,
            af_00201505_RECIRCULATED as adj_factor_RECIRCULATED,
            af_00201505_YELLOW_PAGES as adj_factor_YELLOW_PAGES,
            af_00201505_DIRECT_MAIL as adj_factor_DIRECT_MAIL,
            af_00201505_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT,
            af_00201505_INTERNET as adj_factor_INTERNET,
            af_00201505_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG,
            af_00201505_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL,

            inq_00201505_AGGREGATOR as inq_AGGREGATOR,
            inq_00201505_SEM as inq_SEM,
            inq_00201505_TELEVISION as inq_TELEVISION,
            inq_00201505_WEBSITE as inq_WEBSITE,
            inq_00201505_PRINT as inq_PRINT,
            inq_00201505_RADIO as inq_RADIO,
            inq_00201505_SPECIALTY as inq_SPECIALTY,
            inq_00201505_RECIRCULATED as inq_RECIRCULATED,
            inq_00201505_YELLOW_PAGES as inq_YELLOW_PAGES,
            inq_00201505_DIRECT_MAIL as inq_DIRECT_MAIL,
            inq_00201505_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            inq_00201505_INTERNET as inq_INTERNET,
            inq_00201505_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            inq_00201505_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL
            
            from med_full_data_out
            order by campus;


        create table med_full_data_out_201506 as select
            campus,
            201506 as month,

            sp_00201506_AGGREGATOR as spend_AGGREGATOR,
            sp_00201506_SEM as spend_SEM,
            sp_00201506_TELEVISION as spend_TELEVISION,
            sp_00201506_WEBSITE as spend_WEBSITE,
            sp_00201506_PRINT as spend_PRINT,
            sp_00201506_RADIO as spend_RADIO,
            sp_00201506_SPECIALTY as spend_SPECIALTY,
            sp_00201506_RECIRCULATED as spend_RECIRCULATED,
            sp_00201506_YELLOW_PAGES as spend_YELLOW_PAGES,
            sp_00201506_DIRECT_MAIL as spend_DIRECT_MAIL,
            sp_00201506_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            sp_00201506_INTERNET as spend_INTERNET,
            sp_00201506_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            sp_00201506_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,

            cv_00201506_AGGREGATOR as cv_AGGREGATOR,
            cv_00201506_SEM as cv_SEM,
            cv_00201506_TELEVISION as cv_TELEVISION,
            cv_00201506_WEBSITE as cv_WEBSITE,
            cv_00201506_PRINT as cv_PRINT,
            cv_00201506_RADIO as cv_RADIO,
            cv_00201506_SPECIALTY as cv_SPECIALTY,
            cv_00201506_RECIRCULATED as cv_RECIRCULATED,
            cv_00201506_YELLOW_PAGES as cv_YELLOW_PAGES,
            cv_00201506_DIRECT_MAIL as cv_DIRECT_MAIL,
            cv_00201506_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            cv_00201506_INTERNET as cv_INTERNET,
            cv_00201506_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            cv_00201506_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,

            cf_00201506_AGGREGATOR as coef_AGGREGATOR,
            cf_00201506_SEM as coef_SEM,
            cf_00201506_TELEVISION as coef_TELEVISION,
            cf_00201506_WEBSITE as coef_WEBSITE,
            cf_00201506_PRINT as coef_PRINT,
            cf_00201506_RADIO as coef_RADIO,
            cf_00201506_SPECIALTY as coef_SPECIALTY,
            cf_00201506_RECIRCULATED as coef_RECIRCULATED,
            cf_00201506_YELLOW_PAGES as coef_YELLOW_PAGES,
            cf_00201506_DIRECT_MAIL as coef_DIRECT_MAIL,
            cf_00201506_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT,
            cf_00201506_INTERNET as coef_INTERNET,
            cf_00201506_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG,
            cf_00201506_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL,

            int_00201506_AGGREGATOR as intercept_AGGREGATOR,
            int_00201506_SEM as intercept_SEM,
            int_00201506_TELEVISION as intercept_TELEVISION,
            int_00201506_WEBSITE as intercept_WEBSITE,
            int_00201506_PRINT as intercept_PRINT,
            int_00201506_RADIO as intercept_RADIO,
            int_00201506_SPECIALTY as intercept_SPECIALTY,
            int_00201506_RECIRCULATED as intercept_RECIRCULATED,
            int_00201506_YELLOW_PAGES as intercept_YELLOW_PAGES,
            int_00201506_DIRECT_MAIL as intercept_DIRECT_MAIL,
            int_00201506_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT,
            int_00201506_INTERNET as intercept_INTERNET,
            int_00201506_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG,
            int_00201506_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL,

            af_00201506_AGGREGATOR as adj_factor_AGGREGATOR,
            af_00201506_SEM as adj_factor_SEM,
            af_00201506_TELEVISION as adj_factor_TELEVISION,
            af_00201506_WEBSITE as adj_factor_WEBSITE,
            af_00201506_PRINT as adj_factor_PRINT,
            af_00201506_RADIO as adj_factor_RADIO,
            af_00201506_SPECIALTY as adj_factor_SPECIALTY,
            af_00201506_RECIRCULATED as adj_factor_RECIRCULATED,
            af_00201506_YELLOW_PAGES as adj_factor_YELLOW_PAGES,
            af_00201506_DIRECT_MAIL as adj_factor_DIRECT_MAIL,
            af_00201506_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT,
            af_00201506_INTERNET as adj_factor_INTERNET,
            af_00201506_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG,
            af_00201506_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL,

            inq_00201506_AGGREGATOR as inq_AGGREGATOR,
            inq_00201506_SEM as inq_SEM,
            inq_00201506_TELEVISION as inq_TELEVISION,
            inq_00201506_WEBSITE as inq_WEBSITE,
            inq_00201506_PRINT as inq_PRINT,
            inq_00201506_RADIO as inq_RADIO,
            inq_00201506_SPECIALTY as inq_SPECIALTY,
            inq_00201506_RECIRCULATED as inq_RECIRCULATED,
            inq_00201506_YELLOW_PAGES as inq_YELLOW_PAGES,
            inq_00201506_DIRECT_MAIL as inq_DIRECT_MAIL,
            inq_00201506_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            inq_00201506_INTERNET as inq_INTERNET,
            inq_00201506_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            inq_00201506_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL
            
            from med_full_data_out
            order by campus;


        create table med_full_data_out_201507 as select
            campus,
            201507 as month,

            sp_00201507_AGGREGATOR as spend_AGGREGATOR,
            sp_00201507_SEM as spend_SEM,
            sp_00201507_TELEVISION as spend_TELEVISION,
            sp_00201507_WEBSITE as spend_WEBSITE,
            sp_00201507_PRINT as spend_PRINT,
            sp_00201507_RADIO as spend_RADIO,
            sp_00201507_SPECIALTY as spend_SPECIALTY,
            sp_00201507_RECIRCULATED as spend_RECIRCULATED,
            sp_00201507_YELLOW_PAGES as spend_YELLOW_PAGES,
            sp_00201507_DIRECT_MAIL as spend_DIRECT_MAIL,
            sp_00201507_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            sp_00201507_INTERNET as spend_INTERNET,
            sp_00201507_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            sp_00201507_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,

            cv_00201507_AGGREGATOR as cv_AGGREGATOR,
            cv_00201507_SEM as cv_SEM,
            cv_00201507_TELEVISION as cv_TELEVISION,
            cv_00201507_WEBSITE as cv_WEBSITE,
            cv_00201507_PRINT as cv_PRINT,
            cv_00201507_RADIO as cv_RADIO,
            cv_00201507_SPECIALTY as cv_SPECIALTY,
            cv_00201507_RECIRCULATED as cv_RECIRCULATED,
            cv_00201507_YELLOW_PAGES as cv_YELLOW_PAGES,
            cv_00201507_DIRECT_MAIL as cv_DIRECT_MAIL,
            cv_00201507_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            cv_00201507_INTERNET as cv_INTERNET,
            cv_00201507_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            cv_00201507_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,

            cf_00201507_AGGREGATOR as coef_AGGREGATOR,
            cf_00201507_SEM as coef_SEM,
            cf_00201507_TELEVISION as coef_TELEVISION,
            cf_00201507_WEBSITE as coef_WEBSITE,
            cf_00201507_PRINT as coef_PRINT,
            cf_00201507_RADIO as coef_RADIO,
            cf_00201507_SPECIALTY as coef_SPECIALTY,
            cf_00201507_RECIRCULATED as coef_RECIRCULATED,
            cf_00201507_YELLOW_PAGES as coef_YELLOW_PAGES,
            cf_00201507_DIRECT_MAIL as coef_DIRECT_MAIL,
            cf_00201507_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT,
            cf_00201507_INTERNET as coef_INTERNET,
            cf_00201507_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG,
            cf_00201507_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL,

            int_00201507_AGGREGATOR as intercept_AGGREGATOR,
            int_00201507_SEM as intercept_SEM,
            int_00201507_TELEVISION as intercept_TELEVISION,
            int_00201507_WEBSITE as intercept_WEBSITE,
            int_00201507_PRINT as intercept_PRINT,
            int_00201507_RADIO as intercept_RADIO,
            int_00201507_SPECIALTY as intercept_SPECIALTY,
            int_00201507_RECIRCULATED as intercept_RECIRCULATED,
            int_00201507_YELLOW_PAGES as intercept_YELLOW_PAGES,
            int_00201507_DIRECT_MAIL as intercept_DIRECT_MAIL,
            int_00201507_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT,
            int_00201507_INTERNET as intercept_INTERNET,
            int_00201507_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG,
            int_00201507_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL,

            af_00201507_AGGREGATOR as adj_factor_AGGREGATOR,
            af_00201507_SEM as adj_factor_SEM,
            af_00201507_TELEVISION as adj_factor_TELEVISION,
            af_00201507_WEBSITE as adj_factor_WEBSITE,
            af_00201507_PRINT as adj_factor_PRINT,
            af_00201507_RADIO as adj_factor_RADIO,
            af_00201507_SPECIALTY as adj_factor_SPECIALTY,
            af_00201507_RECIRCULATED as adj_factor_RECIRCULATED,
            af_00201507_YELLOW_PAGES as adj_factor_YELLOW_PAGES,
            af_00201507_DIRECT_MAIL as adj_factor_DIRECT_MAIL,
            af_00201507_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT,
            af_00201507_INTERNET as adj_factor_INTERNET,
            af_00201507_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG,
            af_00201507_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL,

            inq_00201507_AGGREGATOR as inq_AGGREGATOR,
            inq_00201507_SEM as inq_SEM,
            inq_00201507_TELEVISION as inq_TELEVISION,
            inq_00201507_WEBSITE as inq_WEBSITE,
            inq_00201507_PRINT as inq_PRINT,
            inq_00201507_RADIO as inq_RADIO,
            inq_00201507_SPECIALTY as inq_SPECIALTY,
            inq_00201507_RECIRCULATED as inq_RECIRCULATED,
            inq_00201507_YELLOW_PAGES as inq_YELLOW_PAGES,
            inq_00201507_DIRECT_MAIL as inq_DIRECT_MAIL,
            inq_00201507_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            inq_00201507_INTERNET as inq_INTERNET,
            inq_00201507_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            inq_00201507_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL
            
            from med_full_data_out
            order by campus;


        create table med_full_data_out_201508 as select
            campus,
            201508 as month,

            sp_00201508_AGGREGATOR as spend_AGGREGATOR,
            sp_00201508_SEM as spend_SEM,
            sp_00201508_TELEVISION as spend_TELEVISION,
            sp_00201508_WEBSITE as spend_WEBSITE,
            sp_00201508_PRINT as spend_PRINT,
            sp_00201508_RADIO as spend_RADIO,
            sp_00201508_SPECIALTY as spend_SPECIALTY,
            sp_00201508_RECIRCULATED as spend_RECIRCULATED,
            sp_00201508_YELLOW_PAGES as spend_YELLOW_PAGES,
            sp_00201508_DIRECT_MAIL as spend_DIRECT_MAIL,
            sp_00201508_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            sp_00201508_INTERNET as spend_INTERNET,
            sp_00201508_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            sp_00201508_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,

            cv_00201508_AGGREGATOR as cv_AGGREGATOR,
            cv_00201508_SEM as cv_SEM,
            cv_00201508_TELEVISION as cv_TELEVISION,
            cv_00201508_WEBSITE as cv_WEBSITE,
            cv_00201508_PRINT as cv_PRINT,
            cv_00201508_RADIO as cv_RADIO,
            cv_00201508_SPECIALTY as cv_SPECIALTY,
            cv_00201508_RECIRCULATED as cv_RECIRCULATED,
            cv_00201508_YELLOW_PAGES as cv_YELLOW_PAGES,
            cv_00201508_DIRECT_MAIL as cv_DIRECT_MAIL,
            cv_00201508_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            cv_00201508_INTERNET as cv_INTERNET,
            cv_00201508_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            cv_00201508_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,

            cf_00201508_AGGREGATOR as coef_AGGREGATOR,
            cf_00201508_SEM as coef_SEM,
            cf_00201508_TELEVISION as coef_TELEVISION,
            cf_00201508_WEBSITE as coef_WEBSITE,
            cf_00201508_PRINT as coef_PRINT,
            cf_00201508_RADIO as coef_RADIO,
            cf_00201508_SPECIALTY as coef_SPECIALTY,
            cf_00201508_RECIRCULATED as coef_RECIRCULATED,
            cf_00201508_YELLOW_PAGES as coef_YELLOW_PAGES,
            cf_00201508_DIRECT_MAIL as coef_DIRECT_MAIL,
            cf_00201508_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT,
            cf_00201508_INTERNET as coef_INTERNET,
            cf_00201508_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG,
            cf_00201508_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL,

            int_00201508_AGGREGATOR as intercept_AGGREGATOR,
            int_00201508_SEM as intercept_SEM,
            int_00201508_TELEVISION as intercept_TELEVISION,
            int_00201508_WEBSITE as intercept_WEBSITE,
            int_00201508_PRINT as intercept_PRINT,
            int_00201508_RADIO as intercept_RADIO,
            int_00201508_SPECIALTY as intercept_SPECIALTY,
            int_00201508_RECIRCULATED as intercept_RECIRCULATED,
            int_00201508_YELLOW_PAGES as intercept_YELLOW_PAGES,
            int_00201508_DIRECT_MAIL as intercept_DIRECT_MAIL,
            int_00201508_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT,
            int_00201508_INTERNET as intercept_INTERNET,
            int_00201508_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG,
            int_00201508_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL,

            af_00201508_AGGREGATOR as adj_factor_AGGREGATOR,
            af_00201508_SEM as adj_factor_SEM,
            af_00201508_TELEVISION as adj_factor_TELEVISION,
            af_00201508_WEBSITE as adj_factor_WEBSITE,
            af_00201508_PRINT as adj_factor_PRINT,
            af_00201508_RADIO as adj_factor_RADIO,
            af_00201508_SPECIALTY as adj_factor_SPECIALTY,
            af_00201508_RECIRCULATED as adj_factor_RECIRCULATED,
            af_00201508_YELLOW_PAGES as adj_factor_YELLOW_PAGES,
            af_00201508_DIRECT_MAIL as adj_factor_DIRECT_MAIL,
            af_00201508_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT,
            af_00201508_INTERNET as adj_factor_INTERNET,
            af_00201508_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG,
            af_00201508_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL,

            inq_00201508_AGGREGATOR as inq_AGGREGATOR,
            inq_00201508_SEM as inq_SEM,
            inq_00201508_TELEVISION as inq_TELEVISION,
            inq_00201508_WEBSITE as inq_WEBSITE,
            inq_00201508_PRINT as inq_PRINT,
            inq_00201508_RADIO as inq_RADIO,
            inq_00201508_SPECIALTY as inq_SPECIALTY,
            inq_00201508_RECIRCULATED as inq_RECIRCULATED,
            inq_00201508_YELLOW_PAGES as inq_YELLOW_PAGES,
            inq_00201508_DIRECT_MAIL as inq_DIRECT_MAIL,
            inq_00201508_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            inq_00201508_INTERNET as inq_INTERNET,
            inq_00201508_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            inq_00201508_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL
            
            from med_full_data_out
            order by campus;


        create table med_full_data_out_201509 as select
            campus,
            201509 as month,

            sp_00201509_AGGREGATOR as spend_AGGREGATOR,
            sp_00201509_SEM as spend_SEM,
            sp_00201509_TELEVISION as spend_TELEVISION,
            sp_00201509_WEBSITE as spend_WEBSITE,
            sp_00201509_PRINT as spend_PRINT,
            sp_00201509_RADIO as spend_RADIO,
            sp_00201509_SPECIALTY as spend_SPECIALTY,
            sp_00201509_RECIRCULATED as spend_RECIRCULATED,
            sp_00201509_YELLOW_PAGES as spend_YELLOW_PAGES,
            sp_00201509_DIRECT_MAIL as spend_DIRECT_MAIL,
            sp_00201509_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            sp_00201509_INTERNET as spend_INTERNET,
            sp_00201509_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            sp_00201509_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,

            cv_00201509_AGGREGATOR as cv_AGGREGATOR,
            cv_00201509_SEM as cv_SEM,
            cv_00201509_TELEVISION as cv_TELEVISION,
            cv_00201509_WEBSITE as cv_WEBSITE,
            cv_00201509_PRINT as cv_PRINT,
            cv_00201509_RADIO as cv_RADIO,
            cv_00201509_SPECIALTY as cv_SPECIALTY,
            cv_00201509_RECIRCULATED as cv_RECIRCULATED,
            cv_00201509_YELLOW_PAGES as cv_YELLOW_PAGES,
            cv_00201509_DIRECT_MAIL as cv_DIRECT_MAIL,
            cv_00201509_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            cv_00201509_INTERNET as cv_INTERNET,
            cv_00201509_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            cv_00201509_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,

            cf_00201509_AGGREGATOR as coef_AGGREGATOR,
            cf_00201509_SEM as coef_SEM,
            cf_00201509_TELEVISION as coef_TELEVISION,
            cf_00201509_WEBSITE as coef_WEBSITE,
            cf_00201509_PRINT as coef_PRINT,
            cf_00201509_RADIO as coef_RADIO,
            cf_00201509_SPECIALTY as coef_SPECIALTY,
            cf_00201509_RECIRCULATED as coef_RECIRCULATED,
            cf_00201509_YELLOW_PAGES as coef_YELLOW_PAGES,
            cf_00201509_DIRECT_MAIL as coef_DIRECT_MAIL,
            cf_00201509_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT,
            cf_00201509_INTERNET as coef_INTERNET,
            cf_00201509_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG,
            cf_00201509_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL,

            int_00201509_AGGREGATOR as intercept_AGGREGATOR,
            int_00201509_SEM as intercept_SEM,
            int_00201509_TELEVISION as intercept_TELEVISION,
            int_00201509_WEBSITE as intercept_WEBSITE,
            int_00201509_PRINT as intercept_PRINT,
            int_00201509_RADIO as intercept_RADIO,
            int_00201509_SPECIALTY as intercept_SPECIALTY,
            int_00201509_RECIRCULATED as intercept_RECIRCULATED,
            int_00201509_YELLOW_PAGES as intercept_YELLOW_PAGES,
            int_00201509_DIRECT_MAIL as intercept_DIRECT_MAIL,
            int_00201509_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT,
            int_00201509_INTERNET as intercept_INTERNET,
            int_00201509_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG,
            int_00201509_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL,

            af_00201509_AGGREGATOR as adj_factor_AGGREGATOR,
            af_00201509_SEM as adj_factor_SEM,
            af_00201509_TELEVISION as adj_factor_TELEVISION,
            af_00201509_WEBSITE as adj_factor_WEBSITE,
            af_00201509_PRINT as adj_factor_PRINT,
            af_00201509_RADIO as adj_factor_RADIO,
            af_00201509_SPECIALTY as adj_factor_SPECIALTY,
            af_00201509_RECIRCULATED as adj_factor_RECIRCULATED,
            af_00201509_YELLOW_PAGES as adj_factor_YELLOW_PAGES,
            af_00201509_DIRECT_MAIL as adj_factor_DIRECT_MAIL,
            af_00201509_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT,
            af_00201509_INTERNET as adj_factor_INTERNET,
            af_00201509_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG,
            af_00201509_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL,

            inq_00201509_AGGREGATOR as inq_AGGREGATOR,
            inq_00201509_SEM as inq_SEM,
            inq_00201509_TELEVISION as inq_TELEVISION,
            inq_00201509_WEBSITE as inq_WEBSITE,
            inq_00201509_PRINT as inq_PRINT,
            inq_00201509_RADIO as inq_RADIO,
            inq_00201509_SPECIALTY as inq_SPECIALTY,
            inq_00201509_RECIRCULATED as inq_RECIRCULATED,
            inq_00201509_YELLOW_PAGES as inq_YELLOW_PAGES,
            inq_00201509_DIRECT_MAIL as inq_DIRECT_MAIL,
            inq_00201509_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            inq_00201509_INTERNET as inq_INTERNET,
            inq_00201509_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            inq_00201509_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL
            
            from med_full_data_out
            order by campus;


        create table med_full_data_out_201510 as select
            campus,
            201510 as month,

            sp_00201510_AGGREGATOR as spend_AGGREGATOR,
            sp_00201510_SEM as spend_SEM,
            sp_00201510_TELEVISION as spend_TELEVISION,
            sp_00201510_WEBSITE as spend_WEBSITE,
            sp_00201510_PRINT as spend_PRINT,
            sp_00201510_RADIO as spend_RADIO,
            sp_00201510_SPECIALTY as spend_SPECIALTY,
            sp_00201510_RECIRCULATED as spend_RECIRCULATED,
            sp_00201510_YELLOW_PAGES as spend_YELLOW_PAGES,
            sp_00201510_DIRECT_MAIL as spend_DIRECT_MAIL,
            sp_00201510_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            sp_00201510_INTERNET as spend_INTERNET,
            sp_00201510_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            sp_00201510_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,

            cv_00201510_AGGREGATOR as cv_AGGREGATOR,
            cv_00201510_SEM as cv_SEM,
            cv_00201510_TELEVISION as cv_TELEVISION,
            cv_00201510_WEBSITE as cv_WEBSITE,
            cv_00201510_PRINT as cv_PRINT,
            cv_00201510_RADIO as cv_RADIO,
            cv_00201510_SPECIALTY as cv_SPECIALTY,
            cv_00201510_RECIRCULATED as cv_RECIRCULATED,
            cv_00201510_YELLOW_PAGES as cv_YELLOW_PAGES,
            cv_00201510_DIRECT_MAIL as cv_DIRECT_MAIL,
            cv_00201510_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            cv_00201510_INTERNET as cv_INTERNET,
            cv_00201510_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            cv_00201510_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,

            cf_00201510_AGGREGATOR as coef_AGGREGATOR,
            cf_00201510_SEM as coef_SEM,
            cf_00201510_TELEVISION as coef_TELEVISION,
            cf_00201510_WEBSITE as coef_WEBSITE,
            cf_00201510_PRINT as coef_PRINT,
            cf_00201510_RADIO as coef_RADIO,
            cf_00201510_SPECIALTY as coef_SPECIALTY,
            cf_00201510_RECIRCULATED as coef_RECIRCULATED,
            cf_00201510_YELLOW_PAGES as coef_YELLOW_PAGES,
            cf_00201510_DIRECT_MAIL as coef_DIRECT_MAIL,
            cf_00201510_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT,
            cf_00201510_INTERNET as coef_INTERNET,
            cf_00201510_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG,
            cf_00201510_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL,

            int_00201510_AGGREGATOR as intercept_AGGREGATOR,
            int_00201510_SEM as intercept_SEM,
            int_00201510_TELEVISION as intercept_TELEVISION,
            int_00201510_WEBSITE as intercept_WEBSITE,
            int_00201510_PRINT as intercept_PRINT,
            int_00201510_RADIO as intercept_RADIO,
            int_00201510_SPECIALTY as intercept_SPECIALTY,
            int_00201510_RECIRCULATED as intercept_RECIRCULATED,
            int_00201510_YELLOW_PAGES as intercept_YELLOW_PAGES,
            int_00201510_DIRECT_MAIL as intercept_DIRECT_MAIL,
            int_00201510_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT,
            int_00201510_INTERNET as intercept_INTERNET,
            int_00201510_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG,
            int_00201510_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL,

            af_00201510_AGGREGATOR as adj_factor_AGGREGATOR,
            af_00201510_SEM as adj_factor_SEM,
            af_00201510_TELEVISION as adj_factor_TELEVISION,
            af_00201510_WEBSITE as adj_factor_WEBSITE,
            af_00201510_PRINT as adj_factor_PRINT,
            af_00201510_RADIO as adj_factor_RADIO,
            af_00201510_SPECIALTY as adj_factor_SPECIALTY,
            af_00201510_RECIRCULATED as adj_factor_RECIRCULATED,
            af_00201510_YELLOW_PAGES as adj_factor_YELLOW_PAGES,
            af_00201510_DIRECT_MAIL as adj_factor_DIRECT_MAIL,
            af_00201510_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT,
            af_00201510_INTERNET as adj_factor_INTERNET,
            af_00201510_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG,
            af_00201510_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL,

            inq_00201510_AGGREGATOR as inq_AGGREGATOR,
            inq_00201510_SEM as inq_SEM,
            inq_00201510_TELEVISION as inq_TELEVISION,
            inq_00201510_WEBSITE as inq_WEBSITE,
            inq_00201510_PRINT as inq_PRINT,
            inq_00201510_RADIO as inq_RADIO,
            inq_00201510_SPECIALTY as inq_SPECIALTY,
            inq_00201510_RECIRCULATED as inq_RECIRCULATED,
            inq_00201510_YELLOW_PAGES as inq_YELLOW_PAGES,
            inq_00201510_DIRECT_MAIL as inq_DIRECT_MAIL,
            inq_00201510_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            inq_00201510_INTERNET as inq_INTERNET,
            inq_00201510_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            inq_00201510_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL
            
            from med_full_data_out
            order by campus;


        create table med_full_data_out_201511 as select
            campus,
            201511 as month,

            sp_00201511_AGGREGATOR as spend_AGGREGATOR,
            sp_00201511_SEM as spend_SEM,
            sp_00201511_TELEVISION as spend_TELEVISION,
            sp_00201511_WEBSITE as spend_WEBSITE,
            sp_00201511_PRINT as spend_PRINT,
            sp_00201511_RADIO as spend_RADIO,
            sp_00201511_SPECIALTY as spend_SPECIALTY,
            sp_00201511_RECIRCULATED as spend_RECIRCULATED,
            sp_00201511_YELLOW_PAGES as spend_YELLOW_PAGES,
            sp_00201511_DIRECT_MAIL as spend_DIRECT_MAIL,
            sp_00201511_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            sp_00201511_INTERNET as spend_INTERNET,
            sp_00201511_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            sp_00201511_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,

            cv_00201511_AGGREGATOR as cv_AGGREGATOR,
            cv_00201511_SEM as cv_SEM,
            cv_00201511_TELEVISION as cv_TELEVISION,
            cv_00201511_WEBSITE as cv_WEBSITE,
            cv_00201511_PRINT as cv_PRINT,
            cv_00201511_RADIO as cv_RADIO,
            cv_00201511_SPECIALTY as cv_SPECIALTY,
            cv_00201511_RECIRCULATED as cv_RECIRCULATED,
            cv_00201511_YELLOW_PAGES as cv_YELLOW_PAGES,
            cv_00201511_DIRECT_MAIL as cv_DIRECT_MAIL,
            cv_00201511_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            cv_00201511_INTERNET as cv_INTERNET,
            cv_00201511_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            cv_00201511_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,

            cf_00201511_AGGREGATOR as coef_AGGREGATOR,
            cf_00201511_SEM as coef_SEM,
            cf_00201511_TELEVISION as coef_TELEVISION,
            cf_00201511_WEBSITE as coef_WEBSITE,
            cf_00201511_PRINT as coef_PRINT,
            cf_00201511_RADIO as coef_RADIO,
            cf_00201511_SPECIALTY as coef_SPECIALTY,
            cf_00201511_RECIRCULATED as coef_RECIRCULATED,
            cf_00201511_YELLOW_PAGES as coef_YELLOW_PAGES,
            cf_00201511_DIRECT_MAIL as coef_DIRECT_MAIL,
            cf_00201511_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT,
            cf_00201511_INTERNET as coef_INTERNET,
            cf_00201511_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG,
            cf_00201511_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL,

            int_00201511_AGGREGATOR as intercept_AGGREGATOR,
            int_00201511_SEM as intercept_SEM,
            int_00201511_TELEVISION as intercept_TELEVISION,
            int_00201511_WEBSITE as intercept_WEBSITE,
            int_00201511_PRINT as intercept_PRINT,
            int_00201511_RADIO as intercept_RADIO,
            int_00201511_SPECIALTY as intercept_SPECIALTY,
            int_00201511_RECIRCULATED as intercept_RECIRCULATED,
            int_00201511_YELLOW_PAGES as intercept_YELLOW_PAGES,
            int_00201511_DIRECT_MAIL as intercept_DIRECT_MAIL,
            int_00201511_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT,
            int_00201511_INTERNET as intercept_INTERNET,
            int_00201511_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG,
            int_00201511_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL,

            af_00201511_AGGREGATOR as adj_factor_AGGREGATOR,
            af_00201511_SEM as adj_factor_SEM,
            af_00201511_TELEVISION as adj_factor_TELEVISION,
            af_00201511_WEBSITE as adj_factor_WEBSITE,
            af_00201511_PRINT as adj_factor_PRINT,
            af_00201511_RADIO as adj_factor_RADIO,
            af_00201511_SPECIALTY as adj_factor_SPECIALTY,
            af_00201511_RECIRCULATED as adj_factor_RECIRCULATED,
            af_00201511_YELLOW_PAGES as adj_factor_YELLOW_PAGES,
            af_00201511_DIRECT_MAIL as adj_factor_DIRECT_MAIL,
            af_00201511_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT,
            af_00201511_INTERNET as adj_factor_INTERNET,
            af_00201511_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG,
            af_00201511_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL,

            inq_00201511_AGGREGATOR as inq_AGGREGATOR,
            inq_00201511_SEM as inq_SEM,
            inq_00201511_TELEVISION as inq_TELEVISION,
            inq_00201511_WEBSITE as inq_WEBSITE,
            inq_00201511_PRINT as inq_PRINT,
            inq_00201511_RADIO as inq_RADIO,
            inq_00201511_SPECIALTY as inq_SPECIALTY,
            inq_00201511_RECIRCULATED as inq_RECIRCULATED,
            inq_00201511_YELLOW_PAGES as inq_YELLOW_PAGES,
            inq_00201511_DIRECT_MAIL as inq_DIRECT_MAIL,
            inq_00201511_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            inq_00201511_INTERNET as inq_INTERNET,
            inq_00201511_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            inq_00201511_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL
            
            from med_full_data_out
            order by campus;


        create table med_full_data_out_201512 as select
            campus,
            201512 as month,

            sp_00201512_AGGREGATOR as spend_AGGREGATOR,
            sp_00201512_SEM as spend_SEM,
            sp_00201512_TELEVISION as spend_TELEVISION,
            sp_00201512_WEBSITE as spend_WEBSITE,
            sp_00201512_PRINT as spend_PRINT,
            sp_00201512_RADIO as spend_RADIO,
            sp_00201512_SPECIALTY as spend_SPECIALTY,
            sp_00201512_RECIRCULATED as spend_RECIRCULATED,
            sp_00201512_YELLOW_PAGES as spend_YELLOW_PAGES,
            sp_00201512_DIRECT_MAIL as spend_DIRECT_MAIL,
            sp_00201512_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            sp_00201512_INTERNET as spend_INTERNET,
            sp_00201512_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            sp_00201512_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,

            cv_00201512_AGGREGATOR as cv_AGGREGATOR,
            cv_00201512_SEM as cv_SEM,
            cv_00201512_TELEVISION as cv_TELEVISION,
            cv_00201512_WEBSITE as cv_WEBSITE,
            cv_00201512_PRINT as cv_PRINT,
            cv_00201512_RADIO as cv_RADIO,
            cv_00201512_SPECIALTY as cv_SPECIALTY,
            cv_00201512_RECIRCULATED as cv_RECIRCULATED,
            cv_00201512_YELLOW_PAGES as cv_YELLOW_PAGES,
            cv_00201512_DIRECT_MAIL as cv_DIRECT_MAIL,
            cv_00201512_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            cv_00201512_INTERNET as cv_INTERNET,
            cv_00201512_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            cv_00201512_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,

            cf_00201512_AGGREGATOR as coef_AGGREGATOR,
            cf_00201512_SEM as coef_SEM,
            cf_00201512_TELEVISION as coef_TELEVISION,
            cf_00201512_WEBSITE as coef_WEBSITE,
            cf_00201512_PRINT as coef_PRINT,
            cf_00201512_RADIO as coef_RADIO,
            cf_00201512_SPECIALTY as coef_SPECIALTY,
            cf_00201512_RECIRCULATED as coef_RECIRCULATED,
            cf_00201512_YELLOW_PAGES as coef_YELLOW_PAGES,
            cf_00201512_DIRECT_MAIL as coef_DIRECT_MAIL,
            cf_00201512_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT,
            cf_00201512_INTERNET as coef_INTERNET,
            cf_00201512_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG,
            cf_00201512_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL,

            int_00201512_AGGREGATOR as intercept_AGGREGATOR,
            int_00201512_SEM as intercept_SEM,
            int_00201512_TELEVISION as intercept_TELEVISION,
            int_00201512_WEBSITE as intercept_WEBSITE,
            int_00201512_PRINT as intercept_PRINT,
            int_00201512_RADIO as intercept_RADIO,
            int_00201512_SPECIALTY as intercept_SPECIALTY,
            int_00201512_RECIRCULATED as intercept_RECIRCULATED,
            int_00201512_YELLOW_PAGES as intercept_YELLOW_PAGES,
            int_00201512_DIRECT_MAIL as intercept_DIRECT_MAIL,
            int_00201512_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT,
            int_00201512_INTERNET as intercept_INTERNET,
            int_00201512_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG,
            int_00201512_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL,

            af_00201512_AGGREGATOR as adj_factor_AGGREGATOR,
            af_00201512_SEM as adj_factor_SEM,
            af_00201512_TELEVISION as adj_factor_TELEVISION,
            af_00201512_WEBSITE as adj_factor_WEBSITE,
            af_00201512_PRINT as adj_factor_PRINT,
            af_00201512_RADIO as adj_factor_RADIO,
            af_00201512_SPECIALTY as adj_factor_SPECIALTY,
            af_00201512_RECIRCULATED as adj_factor_RECIRCULATED,
            af_00201512_YELLOW_PAGES as adj_factor_YELLOW_PAGES,
            af_00201512_DIRECT_MAIL as adj_factor_DIRECT_MAIL,
            af_00201512_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT,
            af_00201512_INTERNET as adj_factor_INTERNET,
            af_00201512_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG,
            af_00201512_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL,

            inq_00201512_AGGREGATOR as inq_AGGREGATOR,
            inq_00201512_SEM as inq_SEM,
            inq_00201512_TELEVISION as inq_TELEVISION,
            inq_00201512_WEBSITE as inq_WEBSITE,
            inq_00201512_PRINT as inq_PRINT,
            inq_00201512_RADIO as inq_RADIO,
            inq_00201512_SPECIALTY as inq_SPECIALTY,
            inq_00201512_RECIRCULATED as inq_RECIRCULATED,
            inq_00201512_YELLOW_PAGES as inq_YELLOW_PAGES,
            inq_00201512_DIRECT_MAIL as inq_DIRECT_MAIL,
            inq_00201512_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            inq_00201512_INTERNET as inq_INTERNET,
            inq_00201512_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            inq_00201512_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL
            
            from med_full_data_out
            order by campus;
        quit;
    run;

    data model_data_out_dash;
        set
            med_full_data_out_201504
            med_full_data_out_201505
            med_full_data_out_201506
            med_full_data_out_201507
            med_full_data_out_201508
            med_full_data_out_201509
            med_full_data_out_201510
            med_full_data_out_201511
            med_full_data_out_201512;
    run;

    proc export data = model_data_out_dash
        outfile = "&modelPath\model_data_out_dash.xls" 
        dbms = excel2000 replace;
        sheet = "Raw Model Data"; 
    run;

    proc sql noprint;
        create table med_full_data_out_201504_out as select
            campus,
            201504 as month,

            sp_00201504_AGGREGATOR as spend_AGGREGATOR,
            inq_00201504_AGGREGATOR as inq_AGGREGATOR,
            round(inq_00201504_AGGREGATOR*cv_00201504_AGGREGATOR) as enr_AGGREGATOR,
            cv_00201504_AGGREGATOR as cv_AGGREGATOR,
            " " as seperator_AGGREGATOR,
            
            sp_00201504_SEM as spend_SEM,
            inq_00201504_SEM as inq_SEM,
            round(inq_00201504_SEM*cv_00201504_SEM) as enr_SEM,
            cv_00201504_SEM as cv_SEM,
            " " as seperator_SEM,

            sp_00201504_TELEVISION as spend_TELEVISION,
            inq_00201504_TELEVISION as inq_TELEVISION,
            round(inq_00201504_TELEVISION*cv_00201504_TELEVISION) as enr_TELEVISION,
            cv_00201504_TELEVISION as cv_TELEVISION,
            " " as seperator_TELEVISION,

            sp_00201504_WEBSITE as spend_WEBSITE,
            inq_00201504_WEBSITE as inq_WEBSITE,
            round(inq_00201504_WEBSITE*cv_00201504_WEBSITE) as enr_WEBSITE,
            cv_00201504_WEBSITE as cv_WEBSITE,
            " " as seperator_WEBSITE,

            sp_00201504_PRINT as spend_PRINT,
            inq_00201504_PRINT as inq_PRINT,
            round(inq_00201504_PRINT*cv_00201504_PRINT) as enr_PRINT,
            cv_00201504_PRINT as cv_PRINT,
            " " as seperator_PRINT,

            sp_00201504_RADIO as spend_RADIO,
            inq_00201504_RADIO as inq_RADIO,
            round(inq_00201504_RADIO*cv_00201504_RADIO) as enr_RADIO,
            cv_00201504_RADIO as cv_RADIO,
            " " as seperator_RADIO,

            sp_00201504_SPECIALTY as spend_SPECIALTY,
            inq_00201504_SPECIALTY as inq_SPECIALTY,
            round(inq_00201504_SPECIALTY*cv_00201504_SPECIALTY) as enr_SPECIALTY,
            cv_00201504_SPECIALTY as cv_SPECIALTY,
            " " as seperator_SPECIALTY,

            sp_00201504_RECIRCULATED as spend_RECIRCULATED,
            inq_00201504_RECIRCULATED as inq_RECIRCULATED,
            round(inq_00201504_RECIRCULATED*cv_00201504_RECIRCULATED) as enr_RECIRCULATED,
            cv_00201504_RECIRCULATED as cv_RECIRCULATED,
            " " as seperator_RECIRCULATED,

            sp_00201504_YELLOW_PAGES as spend_YELLOW_PAGES,
            inq_00201504_YELLOW_PAGES as inq_YELLOW_PAGES,
            round(inq_00201504_YELLOW_PAGES*cv_00201504_YELLOW_PAGES) as enr_YELLOW_PAGES,
            cv_00201504_YELLOW_PAGES as cv_YELLOW_PAGES,
            " " as seperator_YELLOW_PAGES,

            sp_00201504_DIRECT_MAIL as spend_DIRECT_MAIL,
            inq_00201504_DIRECT_MAIL as inq_DIRECT_MAIL,
            round(inq_00201504_DIRECT_MAIL*cv_00201504_DIRECT_MAIL) as enr_DIRECT_MAIL,
            cv_00201504_DIRECT_MAIL as cv_DIRECT_MAIL,
            " " as seperator_DIRECT_MAIL,

            sp_00201504_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            inq_00201504_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            round(inq_00201504_HIGH_SCHOOL_COMMENT*cv_00201504_HIGH_SCHOOL_COMMENT) as enr_HIGH_SCHOOL_COMMENT,
            cv_00201504_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            " " as seperator_HIGH_SCHOOL_COMMENT,

            sp_00201504_INTERNET as spend_INTERNET,
            inq_00201504_INTERNET as inq_INTERNET,
            round(inq_00201504_INTERNET*cv_00201504_INTERNET) as enr_INTERNET,
            cv_00201504_INTERNET as cv_INTERNET,
            " " as seperator_INTERNET,
            
            sp_00201504_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            inq_00201504_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            round(inq_00201504_LATER_TOO_YOUNG*cv_00201504_LATER_TOO_YOUNG) as enr_LATER_TOO_YOUNG,
            cv_00201504_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            " " as seperator_LATER_TOO_YOUNG,

            sp_00201504_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,
            inq_00201504_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL,
            round(inq_00201504_PDL_OR_REFERRAL*cv_00201504_PDL_OR_REFERRAL) as enr_PDL_OR_REFERRAL,
            cv_00201504_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,
            " " as seperator_PDL_OR_REFERRAL,

            cv_00201504_AGGREGATOR as cv_AGGREGATOR_1,
            cv_00201504_SEM as cv_SEM_1,
            cv_00201504_TELEVISION as cv_TELEVISION_1,
            cv_00201504_WEBSITE as cv_WEBSITE_1,
            cv_00201504_PRINT as cv_PRINT_1,
            cv_00201504_RADIO as cv_RADIO_1,
            cv_00201504_SPECIALTY as cv_SPECIALTY_1,
            cv_00201504_RECIRCULATED as cv_RECIRCULATED_1,
            cv_00201504_YELLOW_PAGES as cv_YELLOW_PAGES_1,
            cv_00201504_DIRECT_MAIL as cv_DIRECT_MAIL_1,
            cv_00201504_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT_1,
            cv_00201504_INTERNET as cv_INTERNET_1,
            cv_00201504_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG_1,
            cv_00201504_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL_1,

            cf_00201504_AGGREGATOR as coef_AGGREGATOR_1,
            cf_00201504_SEM as coef_SEM_1,
            cf_00201504_TELEVISION as coef_TELEVISION_1,
            cf_00201504_WEBSITE as coef_WEBSITE_1,
            cf_00201504_PRINT as coef_PRINT_1,
            cf_00201504_RADIO as coef_RADIO_1,
            cf_00201504_SPECIALTY as coef_SPECIALTY_1,
            cf_00201504_RECIRCULATED as coef_RECIRCULATED_1,
            cf_00201504_YELLOW_PAGES as coef_YELLOW_PAGES_1,
            cf_00201504_DIRECT_MAIL as coef_DIRECT_MAIL_1,
            cf_00201504_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT_1,
            cf_00201504_INTERNET as coef_INTERNET_1,
            cf_00201504_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG_1,
            cf_00201504_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL_1,

            int_00201504_AGGREGATOR as intercept_AGGREGATOR_1,
            int_00201504_SEM as intercept_SEM_1,
            int_00201504_TELEVISION as intercept_TELEVISION_1,
            int_00201504_WEBSITE as intercept_WEBSITE_1,
            int_00201504_PRINT as intercept_PRINT_1,
            int_00201504_RADIO as intercept_RADIO_1,
            int_00201504_SPECIALTY as intercept_SPECIALTY_1,
            int_00201504_RECIRCULATED as intercept_RECIRCULATED_1,
            int_00201504_YELLOW_PAGES as intercept_YELLOW_PAGES_1,
            int_00201504_DIRECT_MAIL as intercept_DIRECT_MAIL_1,
            int_00201504_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT_1,
            int_00201504_INTERNET as intercept_INTERNET_1,
            int_00201504_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG_1,
            int_00201504_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL_1,

            af_00201504_AGGREGATOR as adj_factor_AGGREGATOR_1,
            af_00201504_SEM as adj_factor_SEM_1,
            af_00201504_TELEVISION as adj_factor_TELEVISION_1,
            af_00201504_WEBSITE as adj_factor_WEBSITE_1,
            af_00201504_PRINT as adj_factor_PRINT_1,
            af_00201504_RADIO as adj_factor_RADIO_1,
            af_00201504_SPECIALTY as adj_factor_SPECIALTY_1,
            af_00201504_RECIRCULATED as adj_factor_RECIRCULATED_1,
            af_00201504_YELLOW_PAGES as adj_factor_YELLOW_PAGES_1,
            af_00201504_DIRECT_MAIL as adj_factor_DIRECT_MAIL_1,
            af_00201504_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT_1,
            af_00201504_INTERNET as adj_factor_INTERNET_1,
            af_00201504_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG_1,
            af_00201504_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL_1,

            inq_00201504_AGGREGATOR as inq_AGGREGATOR_1,
            inq_00201504_SEM as inq_SEM_1,
            inq_00201504_TELEVISION as inq_TELEVISION_1,
            inq_00201504_WEBSITE as inq_WEBSITE_1,
            inq_00201504_PRINT as inq_PRINT_1,
            inq_00201504_RADIO as inq_RADIO_1,
            inq_00201504_SPECIALTY as inq_SPECIALTY_1,
            inq_00201504_RECIRCULATED as inq_RECIRCULATED_1,
            inq_00201504_YELLOW_PAGES as inq_YELLOW_PAGES_1,
            inq_00201504_DIRECT_MAIL as inq_DIRECT_MAIL_1,
            inq_00201504_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT_1,
            inq_00201504_INTERNET as inq_INTERNET_1,
            inq_00201504_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG_1,
            inq_00201504_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL_1

            from med_full_data_out
            where campus not contains "ATLANTA" and campus not contains "BROOKLYN" and campus not contains "JACKSONVILLE"
            order by campus;

        create table med_full_data_out_201505_out as select
            campus,
            201505 as month,

            sp_00201505_AGGREGATOR as spend_AGGREGATOR,
            inq_00201505_AGGREGATOR as inq_AGGREGATOR,
            round(inq_00201505_AGGREGATOR*cv_00201505_AGGREGATOR) as enr_AGGREGATOR,
            cv_00201505_AGGREGATOR as cv_AGGREGATOR,
            " " as seperator_AGGREGATOR,
            
            sp_00201505_SEM as spend_SEM,
            inq_00201505_SEM as inq_SEM,
            round(inq_00201505_SEM*cv_00201505_SEM) as enr_SEM,
            cv_00201505_SEM as cv_SEM,
            " " as seperator_SEM,

            sp_00201505_TELEVISION as spend_TELEVISION,
            inq_00201505_TELEVISION as inq_TELEVISION,
            round(inq_00201505_TELEVISION*cv_00201505_TELEVISION) as enr_TELEVISION,
            cv_00201505_TELEVISION as cv_TELEVISION,
            " " as seperator_TELEVISION,

            sp_00201505_WEBSITE as spend_WEBSITE,
            inq_00201505_WEBSITE as inq_WEBSITE,
            round(inq_00201505_WEBSITE*cv_00201505_WEBSITE) as enr_WEBSITE,
            cv_00201505_WEBSITE as cv_WEBSITE,
            " " as seperator_WEBSITE,

            sp_00201505_PRINT as spend_PRINT,
            inq_00201505_PRINT as inq_PRINT,
            round(inq_00201505_PRINT*cv_00201505_PRINT) as enr_PRINT,
            cv_00201505_PRINT as cv_PRINT,
            " " as seperator_PRINT,

            sp_00201505_RADIO as spend_RADIO,
            inq_00201505_RADIO as inq_RADIO,
            round(inq_00201505_RADIO*cv_00201505_RADIO) as enr_RADIO,
            cv_00201505_RADIO as cv_RADIO,
            " " as seperator_RADIO,

            sp_00201505_SPECIALTY as spend_SPECIALTY,
            inq_00201505_SPECIALTY as inq_SPECIALTY,
            round(inq_00201505_SPECIALTY*cv_00201505_SPECIALTY) as enr_SPECIALTY,
            cv_00201505_SPECIALTY as cv_SPECIALTY,
            " " as seperator_SPECIALTY,

            sp_00201505_RECIRCULATED as spend_RECIRCULATED,
            inq_00201505_RECIRCULATED as inq_RECIRCULATED,
            round(inq_00201505_RECIRCULATED*cv_00201505_RECIRCULATED) as enr_RECIRCULATED,
            cv_00201505_RECIRCULATED as cv_RECIRCULATED,
            " " as seperator_RECIRCULATED,

            sp_00201505_YELLOW_PAGES as spend_YELLOW_PAGES,
            inq_00201505_YELLOW_PAGES as inq_YELLOW_PAGES,
            round(inq_00201505_YELLOW_PAGES*cv_00201505_YELLOW_PAGES) as enr_YELLOW_PAGES,
            cv_00201505_YELLOW_PAGES as cv_YELLOW_PAGES,
            " " as seperator_YELLOW_PAGES,

            sp_00201505_DIRECT_MAIL as spend_DIRECT_MAIL,
            inq_00201505_DIRECT_MAIL as inq_DIRECT_MAIL,
            round(inq_00201505_DIRECT_MAIL*cv_00201505_DIRECT_MAIL) as enr_DIRECT_MAIL,
            cv_00201505_DIRECT_MAIL as cv_DIRECT_MAIL,
            " " as seperator_DIRECT_MAIL,

            sp_00201505_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            inq_00201505_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            round(inq_00201505_HIGH_SCHOOL_COMMENT*cv_00201505_HIGH_SCHOOL_COMMENT) as enr_HIGH_SCHOOL_COMMENT,
            cv_00201505_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            " " as seperator_HIGH_SCHOOL_COMMENT,

            sp_00201505_INTERNET as spend_INTERNET,
            inq_00201505_INTERNET as inq_INTERNET,
            round(inq_00201505_INTERNET*cv_00201505_INTERNET) as enr_INTERNET,
            cv_00201505_INTERNET as cv_INTERNET,
            " " as seperator_INTERNET,
            
            sp_00201505_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            inq_00201505_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            round(inq_00201505_LATER_TOO_YOUNG*cv_00201505_LATER_TOO_YOUNG) as enr_LATER_TOO_YOUNG,
            cv_00201505_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            " " as seperator_LATER_TOO_YOUNG,

            sp_00201505_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,
            inq_00201505_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL,
            round(inq_00201505_PDL_OR_REFERRAL*cv_00201505_PDL_OR_REFERRAL) as enr_PDL_OR_REFERRAL,
            cv_00201505_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,
            " " as seperator_PDL_OR_REFERRAL,

            cv_00201505_AGGREGATOR as cv_AGGREGATOR_1,
            cv_00201505_SEM as cv_SEM_1,
            cv_00201505_TELEVISION as cv_TELEVISION_1,
            cv_00201505_WEBSITE as cv_WEBSITE_1,
            cv_00201505_PRINT as cv_PRINT_1,
            cv_00201505_RADIO as cv_RADIO_1,
            cv_00201505_SPECIALTY as cv_SPECIALTY_1,
            cv_00201505_RECIRCULATED as cv_RECIRCULATED_1,
            cv_00201505_YELLOW_PAGES as cv_YELLOW_PAGES_1,
            cv_00201505_DIRECT_MAIL as cv_DIRECT_MAIL_1,
            cv_00201505_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT_1,
            cv_00201505_INTERNET as cv_INTERNET_1,
            cv_00201505_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG_1,
            cv_00201505_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL_1,

            cf_00201505_AGGREGATOR as coef_AGGREGATOR_1,
            cf_00201505_SEM as coef_SEM_1,
            cf_00201505_TELEVISION as coef_TELEVISION_1,
            cf_00201505_WEBSITE as coef_WEBSITE_1,
            cf_00201505_PRINT as coef_PRINT_1,
            cf_00201505_RADIO as coef_RADIO_1,
            cf_00201505_SPECIALTY as coef_SPECIALTY_1,
            cf_00201505_RECIRCULATED as coef_RECIRCULATED_1,
            cf_00201505_YELLOW_PAGES as coef_YELLOW_PAGES_1,
            cf_00201505_DIRECT_MAIL as coef_DIRECT_MAIL_1,
            cf_00201505_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT_1,
            cf_00201505_INTERNET as coef_INTERNET_1,
            cf_00201505_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG_1,
            cf_00201505_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL_1,

            int_00201505_AGGREGATOR as intercept_AGGREGATOR_1,
            int_00201505_SEM as intercept_SEM_1,
            int_00201505_TELEVISION as intercept_TELEVISION_1,
            int_00201505_WEBSITE as intercept_WEBSITE_1,
            int_00201505_PRINT as intercept_PRINT_1,
            int_00201505_RADIO as intercept_RADIO_1,
            int_00201505_SPECIALTY as intercept_SPECIALTY_1,
            int_00201505_RECIRCULATED as intercept_RECIRCULATED_1,
            int_00201505_YELLOW_PAGES as intercept_YELLOW_PAGES_1,
            int_00201505_DIRECT_MAIL as intercept_DIRECT_MAIL_1,
            int_00201505_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT_1,
            int_00201505_INTERNET as intercept_INTERNET_1,
            int_00201505_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG_1,
            int_00201505_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL_1,

            af_00201505_AGGREGATOR as adj_factor_AGGREGATOR_1,
            af_00201505_SEM as adj_factor_SEM_1,
            af_00201505_TELEVISION as adj_factor_TELEVISION_1,
            af_00201505_WEBSITE as adj_factor_WEBSITE_1,
            af_00201505_PRINT as adj_factor_PRINT_1,
            af_00201505_RADIO as adj_factor_RADIO_1,
            af_00201505_SPECIALTY as adj_factor_SPECIALTY_1,
            af_00201505_RECIRCULATED as adj_factor_RECIRCULATED_1,
            af_00201505_YELLOW_PAGES as adj_factor_YELLOW_PAGES_1,
            af_00201505_DIRECT_MAIL as adj_factor_DIRECT_MAIL_1,
            af_00201505_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT_1,
            af_00201505_INTERNET as adj_factor_INTERNET_1,
            af_00201505_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG_1,
            af_00201505_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL_1,

            inq_00201505_AGGREGATOR as inq_AGGREGATOR_1,
            inq_00201505_SEM as inq_SEM_1,
            inq_00201505_TELEVISION as inq_TELEVISION_1,
            inq_00201505_WEBSITE as inq_WEBSITE_1,
            inq_00201505_PRINT as inq_PRINT_1,
            inq_00201505_RADIO as inq_RADIO_1,
            inq_00201505_SPECIALTY as inq_SPECIALTY_1,
            inq_00201505_RECIRCULATED as inq_RECIRCULATED_1,
            inq_00201505_YELLOW_PAGES as inq_YELLOW_PAGES_1,
            inq_00201505_DIRECT_MAIL as inq_DIRECT_MAIL_1,
            inq_00201505_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT_1,
            inq_00201505_INTERNET as inq_INTERNET_1,
            inq_00201505_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG_1,
            inq_00201505_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL_1

            from med_full_data_out
            where campus not contains "ATLANTA" and campus not contains "BROOKLYN" and campus not contains "JACKSONVILLE"
            order by campus;

        create table med_full_data_out_201506_out as select
            campus,
            201506 as month,

            sp_00201506_AGGREGATOR as spend_AGGREGATOR,
            inq_00201506_AGGREGATOR as inq_AGGREGATOR,
            round(inq_00201506_AGGREGATOR*cv_00201506_AGGREGATOR) as enr_AGGREGATOR,
            cv_00201506_AGGREGATOR as cv_AGGREGATOR,
            " " as seperator_AGGREGATOR,
            
            sp_00201506_SEM as spend_SEM,
            inq_00201506_SEM as inq_SEM,
            round(inq_00201506_SEM*cv_00201506_SEM) as enr_SEM,
            cv_00201506_SEM as cv_SEM,
            " " as seperator_SEM,

            sp_00201506_TELEVISION as spend_TELEVISION,
            inq_00201506_TELEVISION as inq_TELEVISION,
            round(inq_00201506_TELEVISION*cv_00201506_TELEVISION) as enr_TELEVISION,
            cv_00201506_TELEVISION as cv_TELEVISION,
            " " as seperator_TELEVISION,

            sp_00201506_WEBSITE as spend_WEBSITE,
            inq_00201506_WEBSITE as inq_WEBSITE,
            round(inq_00201506_WEBSITE*cv_00201506_WEBSITE) as enr_WEBSITE,
            cv_00201506_WEBSITE as cv_WEBSITE,
            " " as seperator_WEBSITE,

            sp_00201506_PRINT as spend_PRINT,
            inq_00201506_PRINT as inq_PRINT,
            round(inq_00201506_PRINT*cv_00201506_PRINT) as enr_PRINT,
            cv_00201506_PRINT as cv_PRINT,
            " " as seperator_PRINT,

            sp_00201506_RADIO as spend_RADIO,
            inq_00201506_RADIO as inq_RADIO,
            round(inq_00201506_RADIO*cv_00201506_RADIO) as enr_RADIO,
            cv_00201506_RADIO as cv_RADIO,
            " " as seperator_RADIO,

            sp_00201506_SPECIALTY as spend_SPECIALTY,
            inq_00201506_SPECIALTY as inq_SPECIALTY,
            round(inq_00201506_SPECIALTY*cv_00201506_SPECIALTY) as enr_SPECIALTY,
            cv_00201506_SPECIALTY as cv_SPECIALTY,
            " " as seperator_SPECIALTY,

            sp_00201506_RECIRCULATED as spend_RECIRCULATED,
            inq_00201506_RECIRCULATED as inq_RECIRCULATED,
            round(inq_00201506_RECIRCULATED*cv_00201506_RECIRCULATED) as enr_RECIRCULATED,
            cv_00201506_RECIRCULATED as cv_RECIRCULATED,
            " " as seperator_RECIRCULATED,

            sp_00201506_YELLOW_PAGES as spend_YELLOW_PAGES,
            inq_00201506_YELLOW_PAGES as inq_YELLOW_PAGES,
            round(inq_00201506_YELLOW_PAGES*cv_00201506_YELLOW_PAGES) as enr_YELLOW_PAGES,
            cv_00201506_YELLOW_PAGES as cv_YELLOW_PAGES,
            " " as seperator_YELLOW_PAGES,

            sp_00201506_DIRECT_MAIL as spend_DIRECT_MAIL,
            inq_00201506_DIRECT_MAIL as inq_DIRECT_MAIL,
            round(inq_00201506_DIRECT_MAIL*cv_00201506_DIRECT_MAIL) as enr_DIRECT_MAIL,
            cv_00201506_DIRECT_MAIL as cv_DIRECT_MAIL,
            " " as seperator_DIRECT_MAIL,

            sp_00201506_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            inq_00201506_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            round(inq_00201506_HIGH_SCHOOL_COMMENT*cv_00201506_HIGH_SCHOOL_COMMENT) as enr_HIGH_SCHOOL_COMMENT,
            cv_00201506_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            " " as seperator_HIGH_SCHOOL_COMMENT,

            sp_00201506_INTERNET as spend_INTERNET,
            inq_00201506_INTERNET as inq_INTERNET,
            round(inq_00201506_INTERNET*cv_00201506_INTERNET) as enr_INTERNET,
            cv_00201506_INTERNET as cv_INTERNET,
            " " as seperator_INTERNET,
            
            sp_00201506_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            inq_00201506_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            round(inq_00201506_LATER_TOO_YOUNG*cv_00201506_LATER_TOO_YOUNG) as enr_LATER_TOO_YOUNG,
            cv_00201506_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            " " as seperator_LATER_TOO_YOUNG,

            sp_00201506_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,
            inq_00201506_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL,
            round(inq_00201506_PDL_OR_REFERRAL*cv_00201506_PDL_OR_REFERRAL) as enr_PDL_OR_REFERRAL,
            cv_00201506_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,
            " " as seperator_PDL_OR_REFERRAL,

            cv_00201506_AGGREGATOR as cv_AGGREGATOR_1,
            cv_00201506_SEM as cv_SEM_1,
            cv_00201506_TELEVISION as cv_TELEVISION_1,
            cv_00201506_WEBSITE as cv_WEBSITE_1,
            cv_00201506_PRINT as cv_PRINT_1,
            cv_00201506_RADIO as cv_RADIO_1,
            cv_00201506_SPECIALTY as cv_SPECIALTY_1,
            cv_00201506_RECIRCULATED as cv_RECIRCULATED_1,
            cv_00201506_YELLOW_PAGES as cv_YELLOW_PAGES_1,
            cv_00201506_DIRECT_MAIL as cv_DIRECT_MAIL_1,
            cv_00201506_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT_1,
            cv_00201506_INTERNET as cv_INTERNET_1,
            cv_00201506_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG_1,
            cv_00201506_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL_1,

            cf_00201506_AGGREGATOR as coef_AGGREGATOR_1,
            cf_00201506_SEM as coef_SEM_1,
            cf_00201506_TELEVISION as coef_TELEVISION_1,
            cf_00201506_WEBSITE as coef_WEBSITE_1,
            cf_00201506_PRINT as coef_PRINT_1,
            cf_00201506_RADIO as coef_RADIO_1,
            cf_00201506_SPECIALTY as coef_SPECIALTY_1,
            cf_00201506_RECIRCULATED as coef_RECIRCULATED_1,
            cf_00201506_YELLOW_PAGES as coef_YELLOW_PAGES_1,
            cf_00201506_DIRECT_MAIL as coef_DIRECT_MAIL_1,
            cf_00201506_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT_1,
            cf_00201506_INTERNET as coef_INTERNET_1,
            cf_00201506_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG_1,
            cf_00201506_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL_1,

            int_00201506_AGGREGATOR as intercept_AGGREGATOR_1,
            int_00201506_SEM as intercept_SEM_1,
            int_00201506_TELEVISION as intercept_TELEVISION_1,
            int_00201506_WEBSITE as intercept_WEBSITE_1,
            int_00201506_PRINT as intercept_PRINT_1,
            int_00201506_RADIO as intercept_RADIO_1,
            int_00201506_SPECIALTY as intercept_SPECIALTY_1,
            int_00201506_RECIRCULATED as intercept_RECIRCULATED_1,
            int_00201506_YELLOW_PAGES as intercept_YELLOW_PAGES_1,
            int_00201506_DIRECT_MAIL as intercept_DIRECT_MAIL_1,
            int_00201506_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT_1,
            int_00201506_INTERNET as intercept_INTERNET_1,
            int_00201506_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG_1,
            int_00201506_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL_1,

            af_00201506_AGGREGATOR as adj_factor_AGGREGATOR_1,
            af_00201506_SEM as adj_factor_SEM_1,
            af_00201506_TELEVISION as adj_factor_TELEVISION_1,
            af_00201506_WEBSITE as adj_factor_WEBSITE_1,
            af_00201506_PRINT as adj_factor_PRINT_1,
            af_00201506_RADIO as adj_factor_RADIO_1,
            af_00201506_SPECIALTY as adj_factor_SPECIALTY_1,
            af_00201506_RECIRCULATED as adj_factor_RECIRCULATED_1,
            af_00201506_YELLOW_PAGES as adj_factor_YELLOW_PAGES_1,
            af_00201506_DIRECT_MAIL as adj_factor_DIRECT_MAIL_1,
            af_00201506_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT_1,
            af_00201506_INTERNET as adj_factor_INTERNET_1,
            af_00201506_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG_1,
            af_00201506_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL_1,

            inq_00201506_AGGREGATOR as inq_AGGREGATOR_1,
            inq_00201506_SEM as inq_SEM_1,
            inq_00201506_TELEVISION as inq_TELEVISION_1,
            inq_00201506_WEBSITE as inq_WEBSITE_1,
            inq_00201506_PRINT as inq_PRINT_1,
            inq_00201506_RADIO as inq_RADIO_1,
            inq_00201506_SPECIALTY as inq_SPECIALTY_1,
            inq_00201506_RECIRCULATED as inq_RECIRCULATED_1,
            inq_00201506_YELLOW_PAGES as inq_YELLOW_PAGES_1,
            inq_00201506_DIRECT_MAIL as inq_DIRECT_MAIL_1,
            inq_00201506_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT_1,
            inq_00201506_INTERNET as inq_INTERNET_1,
            inq_00201506_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG_1,
            inq_00201506_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL_1

            from med_full_data_out
            where campus not contains "ATLANTA" and campus not contains "BROOKLYN" and campus not contains "JACKSONVILLE"
            order by campus;

        create table med_full_data_out_201507_out as select
            campus,
            201507 as month,

            sp_00201507_AGGREGATOR as spend_AGGREGATOR,
            inq_00201507_AGGREGATOR as inq_AGGREGATOR,
            round(inq_00201507_AGGREGATOR*cv_00201507_AGGREGATOR) as enr_AGGREGATOR,
            cv_00201507_AGGREGATOR as cv_AGGREGATOR,
            " " as seperator_AGGREGATOR,
            
            sp_00201507_SEM as spend_SEM,
            inq_00201507_SEM as inq_SEM,
            round(inq_00201507_SEM*cv_00201507_SEM) as enr_SEM,
            cv_00201507_SEM as cv_SEM,
            " " as seperator_SEM,

            sp_00201507_TELEVISION as spend_TELEVISION,
            inq_00201507_TELEVISION as inq_TELEVISION,
            round(inq_00201507_TELEVISION*cv_00201507_TELEVISION) as enr_TELEVISION,
            cv_00201507_TELEVISION as cv_TELEVISION,
            " " as seperator_TELEVISION,

            sp_00201507_WEBSITE as spend_WEBSITE,
            inq_00201507_WEBSITE as inq_WEBSITE,
            round(inq_00201507_WEBSITE*cv_00201507_WEBSITE) as enr_WEBSITE,
            cv_00201507_WEBSITE as cv_WEBSITE,
            " " as seperator_WEBSITE,

            sp_00201507_PRINT as spend_PRINT,
            inq_00201507_PRINT as inq_PRINT,
            round(inq_00201507_PRINT*cv_00201507_PRINT) as enr_PRINT,
            cv_00201507_PRINT as cv_PRINT,
            " " as seperator_PRINT,

            sp_00201507_RADIO as spend_RADIO,
            inq_00201507_RADIO as inq_RADIO,
            round(inq_00201507_RADIO*cv_00201507_RADIO) as enr_RADIO,
            cv_00201507_RADIO as cv_RADIO,
            " " as seperator_RADIO,

            sp_00201507_SPECIALTY as spend_SPECIALTY,
            inq_00201507_SPECIALTY as inq_SPECIALTY,
            round(inq_00201507_SPECIALTY*cv_00201507_SPECIALTY) as enr_SPECIALTY,
            cv_00201507_SPECIALTY as cv_SPECIALTY,
            " " as seperator_SPECIALTY,

            sp_00201507_RECIRCULATED as spend_RECIRCULATED,
            inq_00201507_RECIRCULATED as inq_RECIRCULATED,
            round(inq_00201507_RECIRCULATED*cv_00201507_RECIRCULATED) as enr_RECIRCULATED,
            cv_00201507_RECIRCULATED as cv_RECIRCULATED,
            " " as seperator_RECIRCULATED,

            sp_00201507_YELLOW_PAGES as spend_YELLOW_PAGES,
            inq_00201507_YELLOW_PAGES as inq_YELLOW_PAGES,
            round(inq_00201507_YELLOW_PAGES*cv_00201507_YELLOW_PAGES) as enr_YELLOW_PAGES,
            cv_00201507_YELLOW_PAGES as cv_YELLOW_PAGES,
            " " as seperator_YELLOW_PAGES,

            sp_00201507_DIRECT_MAIL as spend_DIRECT_MAIL,
            inq_00201507_DIRECT_MAIL as inq_DIRECT_MAIL,
            round(inq_00201507_DIRECT_MAIL*cv_00201507_DIRECT_MAIL) as enr_DIRECT_MAIL,
            cv_00201507_DIRECT_MAIL as cv_DIRECT_MAIL,
            " " as seperator_DIRECT_MAIL,

            sp_00201507_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            inq_00201507_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            round(inq_00201507_HIGH_SCHOOL_COMMENT*cv_00201507_HIGH_SCHOOL_COMMENT) as enr_HIGH_SCHOOL_COMMENT,
            cv_00201507_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            " " as seperator_HIGH_SCHOOL_COMMENT,

            sp_00201507_INTERNET as spend_INTERNET,
            inq_00201507_INTERNET as inq_INTERNET,
            round(inq_00201507_INTERNET*cv_00201507_INTERNET) as enr_INTERNET,
            cv_00201507_INTERNET as cv_INTERNET,
            " " as seperator_INTERNET,
            
            sp_00201507_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            inq_00201507_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            round(inq_00201507_LATER_TOO_YOUNG*cv_00201507_LATER_TOO_YOUNG) as enr_LATER_TOO_YOUNG,
            cv_00201507_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            " " as seperator_LATER_TOO_YOUNG,

            sp_00201507_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,
            inq_00201507_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL,
            round(inq_00201507_PDL_OR_REFERRAL*cv_00201507_PDL_OR_REFERRAL) as enr_PDL_OR_REFERRAL,
            cv_00201507_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,
            " " as seperator_PDL_OR_REFERRAL,

            cv_00201507_AGGREGATOR as cv_AGGREGATOR_1,
            cv_00201507_SEM as cv_SEM_1,
            cv_00201507_TELEVISION as cv_TELEVISION_1,
            cv_00201507_WEBSITE as cv_WEBSITE_1,
            cv_00201507_PRINT as cv_PRINT_1,
            cv_00201507_RADIO as cv_RADIO_1,
            cv_00201507_SPECIALTY as cv_SPECIALTY_1,
            cv_00201507_RECIRCULATED as cv_RECIRCULATED_1,
            cv_00201507_YELLOW_PAGES as cv_YELLOW_PAGES_1,
            cv_00201507_DIRECT_MAIL as cv_DIRECT_MAIL_1,
            cv_00201507_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT_1,
            cv_00201507_INTERNET as cv_INTERNET_1,
            cv_00201507_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG_1,
            cv_00201507_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL_1,

            cf_00201507_AGGREGATOR as coef_AGGREGATOR_1,
            cf_00201507_SEM as coef_SEM_1,
            cf_00201507_TELEVISION as coef_TELEVISION_1,
            cf_00201507_WEBSITE as coef_WEBSITE_1,
            cf_00201507_PRINT as coef_PRINT_1,
            cf_00201507_RADIO as coef_RADIO_1,
            cf_00201507_SPECIALTY as coef_SPECIALTY_1,
            cf_00201507_RECIRCULATED as coef_RECIRCULATED_1,
            cf_00201507_YELLOW_PAGES as coef_YELLOW_PAGES_1,
            cf_00201507_DIRECT_MAIL as coef_DIRECT_MAIL_1,
            cf_00201507_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT_1,
            cf_00201507_INTERNET as coef_INTERNET_1,
            cf_00201507_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG_1,
            cf_00201507_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL_1,

            int_00201507_AGGREGATOR as intercept_AGGREGATOR_1,
            int_00201507_SEM as intercept_SEM_1,
            int_00201507_TELEVISION as intercept_TELEVISION_1,
            int_00201507_WEBSITE as intercept_WEBSITE_1,
            int_00201507_PRINT as intercept_PRINT_1,
            int_00201507_RADIO as intercept_RADIO_1,
            int_00201507_SPECIALTY as intercept_SPECIALTY_1,
            int_00201507_RECIRCULATED as intercept_RECIRCULATED_1,
            int_00201507_YELLOW_PAGES as intercept_YELLOW_PAGES_1,
            int_00201507_DIRECT_MAIL as intercept_DIRECT_MAIL_1,
            int_00201507_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT_1,
            int_00201507_INTERNET as intercept_INTERNET_1,
            int_00201507_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG_1,
            int_00201507_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL_1,

            af_00201507_AGGREGATOR as adj_factor_AGGREGATOR_1,
            af_00201507_SEM as adj_factor_SEM_1,
            af_00201507_TELEVISION as adj_factor_TELEVISION_1,
            af_00201507_WEBSITE as adj_factor_WEBSITE_1,
            af_00201507_PRINT as adj_factor_PRINT_1,
            af_00201507_RADIO as adj_factor_RADIO_1,
            af_00201507_SPECIALTY as adj_factor_SPECIALTY_1,
            af_00201507_RECIRCULATED as adj_factor_RECIRCULATED_1,
            af_00201507_YELLOW_PAGES as adj_factor_YELLOW_PAGES_1,
            af_00201507_DIRECT_MAIL as adj_factor_DIRECT_MAIL_1,
            af_00201507_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT_1,
            af_00201507_INTERNET as adj_factor_INTERNET_1,
            af_00201507_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG_1,
            af_00201507_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL_1,

            inq_00201507_AGGREGATOR as inq_AGGREGATOR_1,
            inq_00201507_SEM as inq_SEM_1,
            inq_00201507_TELEVISION as inq_TELEVISION_1,
            inq_00201507_WEBSITE as inq_WEBSITE_1,
            inq_00201507_PRINT as inq_PRINT_1,
            inq_00201507_RADIO as inq_RADIO_1,
            inq_00201507_SPECIALTY as inq_SPECIALTY_1,
            inq_00201507_RECIRCULATED as inq_RECIRCULATED_1,
            inq_00201507_YELLOW_PAGES as inq_YELLOW_PAGES_1,
            inq_00201507_DIRECT_MAIL as inq_DIRECT_MAIL_1,
            inq_00201507_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT_1,
            inq_00201507_INTERNET as inq_INTERNET_1,
            inq_00201507_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG_1,
            inq_00201507_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL_1

            from med_full_data_out
            where campus not contains "ATLANTA" and campus not contains "BROOKLYN" and campus not contains "JACKSONVILLE"
            order by campus;

        create table med_full_data_out_201508_out as select
            campus,
            201508 as month,

            sp_00201508_AGGREGATOR as spend_AGGREGATOR,
            inq_00201508_AGGREGATOR as inq_AGGREGATOR,
            round(inq_00201508_AGGREGATOR*cv_00201508_AGGREGATOR) as enr_AGGREGATOR,
            cv_00201508_AGGREGATOR as cv_AGGREGATOR,
            " " as seperator_AGGREGATOR,
            
            sp_00201508_SEM as spend_SEM,
            inq_00201508_SEM as inq_SEM,
            round(inq_00201508_SEM*cv_00201508_SEM) as enr_SEM,
            cv_00201508_SEM as cv_SEM,
            " " as seperator_SEM,

            sp_00201508_TELEVISION as spend_TELEVISION,
            inq_00201508_TELEVISION as inq_TELEVISION,
            round(inq_00201508_TELEVISION*cv_00201508_TELEVISION) as enr_TELEVISION,
            cv_00201508_TELEVISION as cv_TELEVISION,
            " " as seperator_TELEVISION,

            sp_00201508_WEBSITE as spend_WEBSITE,
            inq_00201508_WEBSITE as inq_WEBSITE,
            round(inq_00201508_WEBSITE*cv_00201508_WEBSITE) as enr_WEBSITE,
            cv_00201508_WEBSITE as cv_WEBSITE,
            " " as seperator_WEBSITE,

            sp_00201508_PRINT as spend_PRINT,
            inq_00201508_PRINT as inq_PRINT,
            round(inq_00201508_PRINT*cv_00201508_PRINT) as enr_PRINT,
            cv_00201508_PRINT as cv_PRINT,
            " " as seperator_PRINT,

            sp_00201508_RADIO as spend_RADIO,
            inq_00201508_RADIO as inq_RADIO,
            round(inq_00201508_RADIO*cv_00201508_RADIO) as enr_RADIO,
            cv_00201508_RADIO as cv_RADIO,
            " " as seperator_RADIO,

            sp_00201508_SPECIALTY as spend_SPECIALTY,
            inq_00201508_SPECIALTY as inq_SPECIALTY,
            round(inq_00201508_SPECIALTY*cv_00201508_SPECIALTY) as enr_SPECIALTY,
            cv_00201508_SPECIALTY as cv_SPECIALTY,
            " " as seperator_SPECIALTY,

            sp_00201508_RECIRCULATED as spend_RECIRCULATED,
            inq_00201508_RECIRCULATED as inq_RECIRCULATED,
            round(inq_00201508_RECIRCULATED*cv_00201508_RECIRCULATED) as enr_RECIRCULATED,
            cv_00201508_RECIRCULATED as cv_RECIRCULATED,
            " " as seperator_RECIRCULATED,

            sp_00201508_YELLOW_PAGES as spend_YELLOW_PAGES,
            inq_00201508_YELLOW_PAGES as inq_YELLOW_PAGES,
            round(inq_00201508_YELLOW_PAGES*cv_00201508_YELLOW_PAGES) as enr_YELLOW_PAGES,
            cv_00201508_YELLOW_PAGES as cv_YELLOW_PAGES,
            " " as seperator_YELLOW_PAGES,

            sp_00201508_DIRECT_MAIL as spend_DIRECT_MAIL,
            inq_00201508_DIRECT_MAIL as inq_DIRECT_MAIL,
            round(inq_00201508_DIRECT_MAIL*cv_00201508_DIRECT_MAIL) as enr_DIRECT_MAIL,
            cv_00201508_DIRECT_MAIL as cv_DIRECT_MAIL,
            " " as seperator_DIRECT_MAIL,

            sp_00201508_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            inq_00201508_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            round(inq_00201508_HIGH_SCHOOL_COMMENT*cv_00201508_HIGH_SCHOOL_COMMENT) as enr_HIGH_SCHOOL_COMMENT,
            cv_00201508_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            " " as seperator_HIGH_SCHOOL_COMMENT,

            sp_00201508_INTERNET as spend_INTERNET,
            inq_00201508_INTERNET as inq_INTERNET,
            round(inq_00201508_INTERNET*cv_00201508_INTERNET) as enr_INTERNET,
            cv_00201508_INTERNET as cv_INTERNET,
            " " as seperator_INTERNET,
            
            sp_00201508_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            inq_00201508_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            round(inq_00201508_LATER_TOO_YOUNG*cv_00201508_LATER_TOO_YOUNG) as enr_LATER_TOO_YOUNG,
            cv_00201508_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            " " as seperator_LATER_TOO_YOUNG,

            sp_00201508_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,
            inq_00201508_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL,
            round(inq_00201508_PDL_OR_REFERRAL*cv_00201508_PDL_OR_REFERRAL) as enr_PDL_OR_REFERRAL,
            cv_00201508_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,
            " " as seperator_PDL_OR_REFERRAL,

            cv_00201508_AGGREGATOR as cv_AGGREGATOR_1,
            cv_00201508_SEM as cv_SEM_1,
            cv_00201508_TELEVISION as cv_TELEVISION_1,
            cv_00201508_WEBSITE as cv_WEBSITE_1,
            cv_00201508_PRINT as cv_PRINT_1,
            cv_00201508_RADIO as cv_RADIO_1,
            cv_00201508_SPECIALTY as cv_SPECIALTY_1,
            cv_00201508_RECIRCULATED as cv_RECIRCULATED_1,
            cv_00201508_YELLOW_PAGES as cv_YELLOW_PAGES_1,
            cv_00201508_DIRECT_MAIL as cv_DIRECT_MAIL_1,
            cv_00201508_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT_1,
            cv_00201508_INTERNET as cv_INTERNET_1,
            cv_00201508_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG_1,
            cv_00201508_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL_1,

            cf_00201508_AGGREGATOR as coef_AGGREGATOR_1,
            cf_00201508_SEM as coef_SEM_1,
            cf_00201508_TELEVISION as coef_TELEVISION_1,
            cf_00201508_WEBSITE as coef_WEBSITE_1,
            cf_00201508_PRINT as coef_PRINT_1,
            cf_00201508_RADIO as coef_RADIO_1,
            cf_00201508_SPECIALTY as coef_SPECIALTY_1,
            cf_00201508_RECIRCULATED as coef_RECIRCULATED_1,
            cf_00201508_YELLOW_PAGES as coef_YELLOW_PAGES_1,
            cf_00201508_DIRECT_MAIL as coef_DIRECT_MAIL_1,
            cf_00201508_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT_1,
            cf_00201508_INTERNET as coef_INTERNET_1,
            cf_00201508_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG_1,
            cf_00201508_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL_1,

            int_00201508_AGGREGATOR as intercept_AGGREGATOR_1,
            int_00201508_SEM as intercept_SEM_1,
            int_00201508_TELEVISION as intercept_TELEVISION_1,
            int_00201508_WEBSITE as intercept_WEBSITE_1,
            int_00201508_PRINT as intercept_PRINT_1,
            int_00201508_RADIO as intercept_RADIO_1,
            int_00201508_SPECIALTY as intercept_SPECIALTY_1,
            int_00201508_RECIRCULATED as intercept_RECIRCULATED_1,
            int_00201508_YELLOW_PAGES as intercept_YELLOW_PAGES_1,
            int_00201508_DIRECT_MAIL as intercept_DIRECT_MAIL_1,
            int_00201508_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT_1,
            int_00201508_INTERNET as intercept_INTERNET_1,
            int_00201508_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG_1,
            int_00201508_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL_1,

            af_00201508_AGGREGATOR as adj_factor_AGGREGATOR_1,
            af_00201508_SEM as adj_factor_SEM_1,
            af_00201508_TELEVISION as adj_factor_TELEVISION_1,
            af_00201508_WEBSITE as adj_factor_WEBSITE_1,
            af_00201508_PRINT as adj_factor_PRINT_1,
            af_00201508_RADIO as adj_factor_RADIO_1,
            af_00201508_SPECIALTY as adj_factor_SPECIALTY_1,
            af_00201508_RECIRCULATED as adj_factor_RECIRCULATED_1,
            af_00201508_YELLOW_PAGES as adj_factor_YELLOW_PAGES_1,
            af_00201508_DIRECT_MAIL as adj_factor_DIRECT_MAIL_1,
            af_00201508_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT_1,
            af_00201508_INTERNET as adj_factor_INTERNET_1,
            af_00201508_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG_1,
            af_00201508_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL_1,

            inq_00201508_AGGREGATOR as inq_AGGREGATOR_1,
            inq_00201508_SEM as inq_SEM_1,
            inq_00201508_TELEVISION as inq_TELEVISION_1,
            inq_00201508_WEBSITE as inq_WEBSITE_1,
            inq_00201508_PRINT as inq_PRINT_1,
            inq_00201508_RADIO as inq_RADIO_1,
            inq_00201508_SPECIALTY as inq_SPECIALTY_1,
            inq_00201508_RECIRCULATED as inq_RECIRCULATED_1,
            inq_00201508_YELLOW_PAGES as inq_YELLOW_PAGES_1,
            inq_00201508_DIRECT_MAIL as inq_DIRECT_MAIL_1,
            inq_00201508_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT_1,
            inq_00201508_INTERNET as inq_INTERNET_1,
            inq_00201508_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG_1,
            inq_00201508_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL_1

            from med_full_data_out
            where campus not contains "ATLANTA" and campus not contains "BROOKLYN" and campus not contains "JACKSONVILLE"
            order by campus;

        create table med_full_data_out_201509_out as select
            campus,
            201509 as month,

            sp_00201509_AGGREGATOR as spend_AGGREGATOR,
            inq_00201509_AGGREGATOR as inq_AGGREGATOR,
            round(inq_00201509_AGGREGATOR*cv_00201509_AGGREGATOR) as enr_AGGREGATOR,
            cv_00201509_AGGREGATOR as cv_AGGREGATOR,
            " " as seperator_AGGREGATOR,
            
            sp_00201509_SEM as spend_SEM,
            inq_00201509_SEM as inq_SEM,
            round(inq_00201509_SEM*cv_00201509_SEM) as enr_SEM,
            cv_00201509_SEM as cv_SEM,
            " " as seperator_SEM,

            sp_00201509_TELEVISION as spend_TELEVISION,
            inq_00201509_TELEVISION as inq_TELEVISION,
            round(inq_00201509_TELEVISION*cv_00201509_TELEVISION) as enr_TELEVISION,
            cv_00201509_TELEVISION as cv_TELEVISION,
            " " as seperator_TELEVISION,

            sp_00201509_WEBSITE as spend_WEBSITE,
            inq_00201509_WEBSITE as inq_WEBSITE,
            round(inq_00201509_WEBSITE*cv_00201509_WEBSITE) as enr_WEBSITE,
            cv_00201509_WEBSITE as cv_WEBSITE,
            " " as seperator_WEBSITE,

            sp_00201509_PRINT as spend_PRINT,
            inq_00201509_PRINT as inq_PRINT,
            round(inq_00201509_PRINT*cv_00201509_PRINT) as enr_PRINT,
            cv_00201509_PRINT as cv_PRINT,
            " " as seperator_PRINT,

            sp_00201509_RADIO as spend_RADIO,
            inq_00201509_RADIO as inq_RADIO,
            round(inq_00201509_RADIO*cv_00201509_RADIO) as enr_RADIO,
            cv_00201509_RADIO as cv_RADIO,
            " " as seperator_RADIO,

            sp_00201509_SPECIALTY as spend_SPECIALTY,
            inq_00201509_SPECIALTY as inq_SPECIALTY,
            round(inq_00201509_SPECIALTY*cv_00201509_SPECIALTY) as enr_SPECIALTY,
            cv_00201509_SPECIALTY as cv_SPECIALTY,
            " " as seperator_SPECIALTY,

            sp_00201509_RECIRCULATED as spend_RECIRCULATED,
            inq_00201509_RECIRCULATED as inq_RECIRCULATED,
            round(inq_00201509_RECIRCULATED*cv_00201509_RECIRCULATED) as enr_RECIRCULATED,
            cv_00201509_RECIRCULATED as cv_RECIRCULATED,
            " " as seperator_RECIRCULATED,

            sp_00201509_YELLOW_PAGES as spend_YELLOW_PAGES,
            inq_00201509_YELLOW_PAGES as inq_YELLOW_PAGES,
            round(inq_00201509_YELLOW_PAGES*cv_00201509_YELLOW_PAGES) as enr_YELLOW_PAGES,
            cv_00201509_YELLOW_PAGES as cv_YELLOW_PAGES,
            " " as seperator_YELLOW_PAGES,

            sp_00201509_DIRECT_MAIL as spend_DIRECT_MAIL,
            inq_00201509_DIRECT_MAIL as inq_DIRECT_MAIL,
            round(inq_00201509_DIRECT_MAIL*cv_00201509_DIRECT_MAIL) as enr_DIRECT_MAIL,
            cv_00201509_DIRECT_MAIL as cv_DIRECT_MAIL,
            " " as seperator_DIRECT_MAIL,

            sp_00201509_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            inq_00201509_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            round(inq_00201509_HIGH_SCHOOL_COMMENT*cv_00201509_HIGH_SCHOOL_COMMENT) as enr_HIGH_SCHOOL_COMMENT,
            cv_00201509_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            " " as seperator_HIGH_SCHOOL_COMMENT,

            sp_00201509_INTERNET as spend_INTERNET,
            inq_00201509_INTERNET as inq_INTERNET,
            round(inq_00201509_INTERNET*cv_00201509_INTERNET) as enr_INTERNET,
            cv_00201509_INTERNET as cv_INTERNET,
            " " as seperator_INTERNET,
            
            sp_00201509_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            inq_00201509_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            round(inq_00201509_LATER_TOO_YOUNG*cv_00201509_LATER_TOO_YOUNG) as enr_LATER_TOO_YOUNG,
            cv_00201509_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            " " as seperator_LATER_TOO_YOUNG,

            sp_00201509_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,
            inq_00201509_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL,
            round(inq_00201509_PDL_OR_REFERRAL*cv_00201509_PDL_OR_REFERRAL) as enr_PDL_OR_REFERRAL,
            cv_00201509_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,
            " " as seperator_PDL_OR_REFERRAL,

            cv_00201509_AGGREGATOR as cv_AGGREGATOR_1,
            cv_00201509_SEM as cv_SEM_1,
            cv_00201509_TELEVISION as cv_TELEVISION_1,
            cv_00201509_WEBSITE as cv_WEBSITE_1,
            cv_00201509_PRINT as cv_PRINT_1,
            cv_00201509_RADIO as cv_RADIO_1,
            cv_00201509_SPECIALTY as cv_SPECIALTY_1,
            cv_00201509_RECIRCULATED as cv_RECIRCULATED_1,
            cv_00201509_YELLOW_PAGES as cv_YELLOW_PAGES_1,
            cv_00201509_DIRECT_MAIL as cv_DIRECT_MAIL_1,
            cv_00201509_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT_1,
            cv_00201509_INTERNET as cv_INTERNET_1,
            cv_00201509_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG_1,
            cv_00201509_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL_1,

            cf_00201509_AGGREGATOR as coef_AGGREGATOR_1,
            cf_00201509_SEM as coef_SEM_1,
            cf_00201509_TELEVISION as coef_TELEVISION_1,
            cf_00201509_WEBSITE as coef_WEBSITE_1,
            cf_00201509_PRINT as coef_PRINT_1,
            cf_00201509_RADIO as coef_RADIO_1,
            cf_00201509_SPECIALTY as coef_SPECIALTY_1,
            cf_00201509_RECIRCULATED as coef_RECIRCULATED_1,
            cf_00201509_YELLOW_PAGES as coef_YELLOW_PAGES_1,
            cf_00201509_DIRECT_MAIL as coef_DIRECT_MAIL_1,
            cf_00201509_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT_1,
            cf_00201509_INTERNET as coef_INTERNET_1,
            cf_00201509_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG_1,
            cf_00201509_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL_1,

            int_00201509_AGGREGATOR as intercept_AGGREGATOR_1,
            int_00201509_SEM as intercept_SEM_1,
            int_00201509_TELEVISION as intercept_TELEVISION_1,
            int_00201509_WEBSITE as intercept_WEBSITE_1,
            int_00201509_PRINT as intercept_PRINT_1,
            int_00201509_RADIO as intercept_RADIO_1,
            int_00201509_SPECIALTY as intercept_SPECIALTY_1,
            int_00201509_RECIRCULATED as intercept_RECIRCULATED_1,
            int_00201509_YELLOW_PAGES as intercept_YELLOW_PAGES_1,
            int_00201509_DIRECT_MAIL as intercept_DIRECT_MAIL_1,
            int_00201509_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT_1,
            int_00201509_INTERNET as intercept_INTERNET_1,
            int_00201509_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG_1,
            int_00201509_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL_1,

            af_00201509_AGGREGATOR as adj_factor_AGGREGATOR_1,
            af_00201509_SEM as adj_factor_SEM_1,
            af_00201509_TELEVISION as adj_factor_TELEVISION_1,
            af_00201509_WEBSITE as adj_factor_WEBSITE_1,
            af_00201509_PRINT as adj_factor_PRINT_1,
            af_00201509_RADIO as adj_factor_RADIO_1,
            af_00201509_SPECIALTY as adj_factor_SPECIALTY_1,
            af_00201509_RECIRCULATED as adj_factor_RECIRCULATED_1,
            af_00201509_YELLOW_PAGES as adj_factor_YELLOW_PAGES_1,
            af_00201509_DIRECT_MAIL as adj_factor_DIRECT_MAIL_1,
            af_00201509_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT_1,
            af_00201509_INTERNET as adj_factor_INTERNET_1,
            af_00201509_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG_1,
            af_00201509_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL_1,

            inq_00201509_AGGREGATOR as inq_AGGREGATOR_1,
            inq_00201509_SEM as inq_SEM_1,
            inq_00201509_TELEVISION as inq_TELEVISION_1,
            inq_00201509_WEBSITE as inq_WEBSITE_1,
            inq_00201509_PRINT as inq_PRINT_1,
            inq_00201509_RADIO as inq_RADIO_1,
            inq_00201509_SPECIALTY as inq_SPECIALTY_1,
            inq_00201509_RECIRCULATED as inq_RECIRCULATED_1,
            inq_00201509_YELLOW_PAGES as inq_YELLOW_PAGES_1,
            inq_00201509_DIRECT_MAIL as inq_DIRECT_MAIL_1,
            inq_00201509_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT_1,
            inq_00201509_INTERNET as inq_INTERNET_1,
            inq_00201509_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG_1,
            inq_00201509_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL_1

            from med_full_data_out
            where campus not contains "ATLANTA" and campus not contains "BROOKLYN" and campus not contains "JACKSONVILLE"
            order by campus;

        create table med_full_data_out_201510_out as select
            campus,
            201510 as month,

            sp_00201510_AGGREGATOR as spend_AGGREGATOR,
            inq_00201510_AGGREGATOR as inq_AGGREGATOR,
            round(inq_00201510_AGGREGATOR*cv_00201510_AGGREGATOR) as enr_AGGREGATOR,
            cv_00201510_AGGREGATOR as cv_AGGREGATOR,
            " " as seperator_AGGREGATOR,
            
            sp_00201510_SEM as spend_SEM,
            inq_00201510_SEM as inq_SEM,
            round(inq_00201510_SEM*cv_00201510_SEM) as enr_SEM,
            cv_00201510_SEM as cv_SEM,
            " " as seperator_SEM,

            sp_00201510_TELEVISION as spend_TELEVISION,
            inq_00201510_TELEVISION as inq_TELEVISION,
            round(inq_00201510_TELEVISION*cv_00201510_TELEVISION) as enr_TELEVISION,
            cv_00201510_TELEVISION as cv_TELEVISION,
            " " as seperator_TELEVISION,

            sp_00201510_WEBSITE as spend_WEBSITE,
            inq_00201510_WEBSITE as inq_WEBSITE,
            round(inq_00201510_WEBSITE*cv_00201510_WEBSITE) as enr_WEBSITE,
            cv_00201510_WEBSITE as cv_WEBSITE,
            " " as seperator_WEBSITE,

            sp_00201510_PRINT as spend_PRINT,
            inq_00201510_PRINT as inq_PRINT,
            round(inq_00201510_PRINT*cv_00201510_PRINT) as enr_PRINT,
            cv_00201510_PRINT as cv_PRINT,
            " " as seperator_PRINT,

            sp_00201510_RADIO as spend_RADIO,
            inq_00201510_RADIO as inq_RADIO,
            round(inq_00201510_RADIO*cv_00201510_RADIO) as enr_RADIO,
            cv_00201510_RADIO as cv_RADIO,
            " " as seperator_RADIO,

            sp_00201510_SPECIALTY as spend_SPECIALTY,
            inq_00201510_SPECIALTY as inq_SPECIALTY,
            round(inq_00201510_SPECIALTY*cv_00201510_SPECIALTY) as enr_SPECIALTY,
            cv_00201510_SPECIALTY as cv_SPECIALTY,
            " " as seperator_SPECIALTY,

            sp_00201510_RECIRCULATED as spend_RECIRCULATED,
            inq_00201510_RECIRCULATED as inq_RECIRCULATED,
            round(inq_00201510_RECIRCULATED*cv_00201510_RECIRCULATED) as enr_RECIRCULATED,
            cv_00201510_RECIRCULATED as cv_RECIRCULATED,
            " " as seperator_RECIRCULATED,

            sp_00201510_YELLOW_PAGES as spend_YELLOW_PAGES,
            inq_00201510_YELLOW_PAGES as inq_YELLOW_PAGES,
            round(inq_00201510_YELLOW_PAGES*cv_00201510_YELLOW_PAGES) as enr_YELLOW_PAGES,
            cv_00201510_YELLOW_PAGES as cv_YELLOW_PAGES,
            " " as seperator_YELLOW_PAGES,

            sp_00201510_DIRECT_MAIL as spend_DIRECT_MAIL,
            inq_00201510_DIRECT_MAIL as inq_DIRECT_MAIL,
            round(inq_00201510_DIRECT_MAIL*cv_00201510_DIRECT_MAIL) as enr_DIRECT_MAIL,
            cv_00201510_DIRECT_MAIL as cv_DIRECT_MAIL,
            " " as seperator_DIRECT_MAIL,

            sp_00201510_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            inq_00201510_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            round(inq_00201510_HIGH_SCHOOL_COMMENT*cv_00201510_HIGH_SCHOOL_COMMENT) as enr_HIGH_SCHOOL_COMMENT,
            cv_00201510_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            " " as seperator_HIGH_SCHOOL_COMMENT,

            sp_00201510_INTERNET as spend_INTERNET,
            inq_00201510_INTERNET as inq_INTERNET,
            round(inq_00201510_INTERNET*cv_00201510_INTERNET) as enr_INTERNET,
            cv_00201510_INTERNET as cv_INTERNET,
            " " as seperator_INTERNET,
            
            sp_00201510_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            inq_00201510_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            round(inq_00201510_LATER_TOO_YOUNG*cv_00201510_LATER_TOO_YOUNG) as enr_LATER_TOO_YOUNG,
            cv_00201510_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            " " as seperator_LATER_TOO_YOUNG,

            sp_00201510_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,
            inq_00201510_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL,
            round(inq_00201510_PDL_OR_REFERRAL*cv_00201510_PDL_OR_REFERRAL) as enr_PDL_OR_REFERRAL,
            cv_00201510_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,
            " " as seperator_PDL_OR_REFERRAL,

            cv_00201510_AGGREGATOR as cv_AGGREGATOR_1,
            cv_00201510_SEM as cv_SEM_1,
            cv_00201510_TELEVISION as cv_TELEVISION_1,
            cv_00201510_WEBSITE as cv_WEBSITE_1,
            cv_00201510_PRINT as cv_PRINT_1,
            cv_00201510_RADIO as cv_RADIO_1,
            cv_00201510_SPECIALTY as cv_SPECIALTY_1,
            cv_00201510_RECIRCULATED as cv_RECIRCULATED_1,
            cv_00201510_YELLOW_PAGES as cv_YELLOW_PAGES_1,
            cv_00201510_DIRECT_MAIL as cv_DIRECT_MAIL_1,
            cv_00201510_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT_1,
            cv_00201510_INTERNET as cv_INTERNET_1,
            cv_00201510_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG_1,
            cv_00201510_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL_1,

            cf_00201510_AGGREGATOR as coef_AGGREGATOR_1,
            cf_00201510_SEM as coef_SEM_1,
            cf_00201510_TELEVISION as coef_TELEVISION_1,
            cf_00201510_WEBSITE as coef_WEBSITE_1,
            cf_00201510_PRINT as coef_PRINT_1,
            cf_00201510_RADIO as coef_RADIO_1,
            cf_00201510_SPECIALTY as coef_SPECIALTY_1,
            cf_00201510_RECIRCULATED as coef_RECIRCULATED_1,
            cf_00201510_YELLOW_PAGES as coef_YELLOW_PAGES_1,
            cf_00201510_DIRECT_MAIL as coef_DIRECT_MAIL_1,
            cf_00201510_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT_1,
            cf_00201510_INTERNET as coef_INTERNET_1,
            cf_00201510_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG_1,
            cf_00201510_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL_1,

            int_00201510_AGGREGATOR as intercept_AGGREGATOR_1,
            int_00201510_SEM as intercept_SEM_1,
            int_00201510_TELEVISION as intercept_TELEVISION_1,
            int_00201510_WEBSITE as intercept_WEBSITE_1,
            int_00201510_PRINT as intercept_PRINT_1,
            int_00201510_RADIO as intercept_RADIO_1,
            int_00201510_SPECIALTY as intercept_SPECIALTY_1,
            int_00201510_RECIRCULATED as intercept_RECIRCULATED_1,
            int_00201510_YELLOW_PAGES as intercept_YELLOW_PAGES_1,
            int_00201510_DIRECT_MAIL as intercept_DIRECT_MAIL_1,
            int_00201510_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT_1,
            int_00201510_INTERNET as intercept_INTERNET_1,
            int_00201510_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG_1,
            int_00201510_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL_1,

            af_00201510_AGGREGATOR as adj_factor_AGGREGATOR_1,
            af_00201510_SEM as adj_factor_SEM_1,
            af_00201510_TELEVISION as adj_factor_TELEVISION_1,
            af_00201510_WEBSITE as adj_factor_WEBSITE_1,
            af_00201510_PRINT as adj_factor_PRINT_1,
            af_00201510_RADIO as adj_factor_RADIO_1,
            af_00201510_SPECIALTY as adj_factor_SPECIALTY_1,
            af_00201510_RECIRCULATED as adj_factor_RECIRCULATED_1,
            af_00201510_YELLOW_PAGES as adj_factor_YELLOW_PAGES_1,
            af_00201510_DIRECT_MAIL as adj_factor_DIRECT_MAIL_1,
            af_00201510_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT_1,
            af_00201510_INTERNET as adj_factor_INTERNET_1,
            af_00201510_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG_1,
            af_00201510_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL_1,

            inq_00201510_AGGREGATOR as inq_AGGREGATOR_1,
            inq_00201510_SEM as inq_SEM_1,
            inq_00201510_TELEVISION as inq_TELEVISION_1,
            inq_00201510_WEBSITE as inq_WEBSITE_1,
            inq_00201510_PRINT as inq_PRINT_1,
            inq_00201510_RADIO as inq_RADIO_1,
            inq_00201510_SPECIALTY as inq_SPECIALTY_1,
            inq_00201510_RECIRCULATED as inq_RECIRCULATED_1,
            inq_00201510_YELLOW_PAGES as inq_YELLOW_PAGES_1,
            inq_00201510_DIRECT_MAIL as inq_DIRECT_MAIL_1,
            inq_00201510_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT_1,
            inq_00201510_INTERNET as inq_INTERNET_1,
            inq_00201510_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG_1,
            inq_00201510_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL_1

            from med_full_data_out
            where campus not contains "ATLANTA" and campus not contains "BROOKLYN" and campus not contains "JACKSONVILLE"
            order by campus;

        create table med_full_data_out_201511_out as select
            campus,
            201511 as month,

            sp_00201511_AGGREGATOR as spend_AGGREGATOR,
            inq_00201511_AGGREGATOR as inq_AGGREGATOR,
            round(inq_00201511_AGGREGATOR*cv_00201511_AGGREGATOR) as enr_AGGREGATOR,
            cv_00201511_AGGREGATOR as cv_AGGREGATOR,
            " " as seperator_AGGREGATOR,
            
            sp_00201511_SEM as spend_SEM,
            inq_00201511_SEM as inq_SEM,
            round(inq_00201511_SEM*cv_00201511_SEM) as enr_SEM,
            cv_00201511_SEM as cv_SEM,
            " " as seperator_SEM,

            sp_00201511_TELEVISION as spend_TELEVISION,
            inq_00201511_TELEVISION as inq_TELEVISION,
            round(inq_00201511_TELEVISION*cv_00201511_TELEVISION) as enr_TELEVISION,
            cv_00201511_TELEVISION as cv_TELEVISION,
            " " as seperator_TELEVISION,

            sp_00201511_WEBSITE as spend_WEBSITE,
            inq_00201511_WEBSITE as inq_WEBSITE,
            round(inq_00201511_WEBSITE*cv_00201511_WEBSITE) as enr_WEBSITE,
            cv_00201511_WEBSITE as cv_WEBSITE,
            " " as seperator_WEBSITE,

            sp_00201511_PRINT as spend_PRINT,
            inq_00201511_PRINT as inq_PRINT,
            round(inq_00201511_PRINT*cv_00201511_PRINT) as enr_PRINT,
            cv_00201511_PRINT as cv_PRINT,
            " " as seperator_PRINT,

            sp_00201511_RADIO as spend_RADIO,
            inq_00201511_RADIO as inq_RADIO,
            round(inq_00201511_RADIO*cv_00201511_RADIO) as enr_RADIO,
            cv_00201511_RADIO as cv_RADIO,
            " " as seperator_RADIO,

            sp_00201511_SPECIALTY as spend_SPECIALTY,
            inq_00201511_SPECIALTY as inq_SPECIALTY,
            round(inq_00201511_SPECIALTY*cv_00201511_SPECIALTY) as enr_SPECIALTY,
            cv_00201511_SPECIALTY as cv_SPECIALTY,
            " " as seperator_SPECIALTY,

            sp_00201511_RECIRCULATED as spend_RECIRCULATED,
            inq_00201511_RECIRCULATED as inq_RECIRCULATED,
            round(inq_00201511_RECIRCULATED*cv_00201511_RECIRCULATED) as enr_RECIRCULATED,
            cv_00201511_RECIRCULATED as cv_RECIRCULATED,
            " " as seperator_RECIRCULATED,

            sp_00201511_YELLOW_PAGES as spend_YELLOW_PAGES,
            inq_00201511_YELLOW_PAGES as inq_YELLOW_PAGES,
            round(inq_00201511_YELLOW_PAGES*cv_00201511_YELLOW_PAGES) as enr_YELLOW_PAGES,
            cv_00201511_YELLOW_PAGES as cv_YELLOW_PAGES,
            " " as seperator_YELLOW_PAGES,

            sp_00201511_DIRECT_MAIL as spend_DIRECT_MAIL,
            inq_00201511_DIRECT_MAIL as inq_DIRECT_MAIL,
            round(inq_00201511_DIRECT_MAIL*cv_00201511_DIRECT_MAIL) as enr_DIRECT_MAIL,
            cv_00201511_DIRECT_MAIL as cv_DIRECT_MAIL,
            " " as seperator_DIRECT_MAIL,

            sp_00201511_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            inq_00201511_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            round(inq_00201511_HIGH_SCHOOL_COMMENT*cv_00201511_HIGH_SCHOOL_COMMENT) as enr_HIGH_SCHOOL_COMMENT,
            cv_00201511_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            " " as seperator_HIGH_SCHOOL_COMMENT,

            sp_00201511_INTERNET as spend_INTERNET,
            inq_00201511_INTERNET as inq_INTERNET,
            round(inq_00201511_INTERNET*cv_00201511_INTERNET) as enr_INTERNET,
            cv_00201511_INTERNET as cv_INTERNET,
            " " as seperator_INTERNET,
            
            sp_00201511_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            inq_00201511_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            round(inq_00201511_LATER_TOO_YOUNG*cv_00201511_LATER_TOO_YOUNG) as enr_LATER_TOO_YOUNG,
            cv_00201511_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            " " as seperator_LATER_TOO_YOUNG,

            sp_00201511_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,
            inq_00201511_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL,
            round(inq_00201511_PDL_OR_REFERRAL*cv_00201511_PDL_OR_REFERRAL) as enr_PDL_OR_REFERRAL,
            cv_00201511_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,
            " " as seperator_PDL_OR_REFERRAL,

            cv_00201511_AGGREGATOR as cv_AGGREGATOR_1,
            cv_00201511_SEM as cv_SEM_1,
            cv_00201511_TELEVISION as cv_TELEVISION_1,
            cv_00201511_WEBSITE as cv_WEBSITE_1,
            cv_00201511_PRINT as cv_PRINT_1,
            cv_00201511_RADIO as cv_RADIO_1,
            cv_00201511_SPECIALTY as cv_SPECIALTY_1,
            cv_00201511_RECIRCULATED as cv_RECIRCULATED_1,
            cv_00201511_YELLOW_PAGES as cv_YELLOW_PAGES_1,
            cv_00201511_DIRECT_MAIL as cv_DIRECT_MAIL_1,
            cv_00201511_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT_1,
            cv_00201511_INTERNET as cv_INTERNET_1,
            cv_00201511_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG_1,
            cv_00201511_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL_1,

            cf_00201511_AGGREGATOR as coef_AGGREGATOR_1,
            cf_00201511_SEM as coef_SEM_1,
            cf_00201511_TELEVISION as coef_TELEVISION_1,
            cf_00201511_WEBSITE as coef_WEBSITE_1,
            cf_00201511_PRINT as coef_PRINT_1,
            cf_00201511_RADIO as coef_RADIO_1,
            cf_00201511_SPECIALTY as coef_SPECIALTY_1,
            cf_00201511_RECIRCULATED as coef_RECIRCULATED_1,
            cf_00201511_YELLOW_PAGES as coef_YELLOW_PAGES_1,
            cf_00201511_DIRECT_MAIL as coef_DIRECT_MAIL_1,
            cf_00201511_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT_1,
            cf_00201511_INTERNET as coef_INTERNET_1,
            cf_00201511_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG_1,
            cf_00201511_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL_1,

            int_00201511_AGGREGATOR as intercept_AGGREGATOR_1,
            int_00201511_SEM as intercept_SEM_1,
            int_00201511_TELEVISION as intercept_TELEVISION_1,
            int_00201511_WEBSITE as intercept_WEBSITE_1,
            int_00201511_PRINT as intercept_PRINT_1,
            int_00201511_RADIO as intercept_RADIO_1,
            int_00201511_SPECIALTY as intercept_SPECIALTY_1,
            int_00201511_RECIRCULATED as intercept_RECIRCULATED_1,
            int_00201511_YELLOW_PAGES as intercept_YELLOW_PAGES_1,
            int_00201511_DIRECT_MAIL as intercept_DIRECT_MAIL_1,
            int_00201511_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT_1,
            int_00201511_INTERNET as intercept_INTERNET_1,
            int_00201511_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG_1,
            int_00201511_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL_1,

            af_00201511_AGGREGATOR as adj_factor_AGGREGATOR_1,
            af_00201511_SEM as adj_factor_SEM_1,
            af_00201511_TELEVISION as adj_factor_TELEVISION_1,
            af_00201511_WEBSITE as adj_factor_WEBSITE_1,
            af_00201511_PRINT as adj_factor_PRINT_1,
            af_00201511_RADIO as adj_factor_RADIO_1,
            af_00201511_SPECIALTY as adj_factor_SPECIALTY_1,
            af_00201511_RECIRCULATED as adj_factor_RECIRCULATED_1,
            af_00201511_YELLOW_PAGES as adj_factor_YELLOW_PAGES_1,
            af_00201511_DIRECT_MAIL as adj_factor_DIRECT_MAIL_1,
            af_00201511_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT_1,
            af_00201511_INTERNET as adj_factor_INTERNET_1,
            af_00201511_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG_1,
            af_00201511_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL_1,

            inq_00201511_AGGREGATOR as inq_AGGREGATOR_1,
            inq_00201511_SEM as inq_SEM_1,
            inq_00201511_TELEVISION as inq_TELEVISION_1,
            inq_00201511_WEBSITE as inq_WEBSITE_1,
            inq_00201511_PRINT as inq_PRINT_1,
            inq_00201511_RADIO as inq_RADIO_1,
            inq_00201511_SPECIALTY as inq_SPECIALTY_1,
            inq_00201511_RECIRCULATED as inq_RECIRCULATED_1,
            inq_00201511_YELLOW_PAGES as inq_YELLOW_PAGES_1,
            inq_00201511_DIRECT_MAIL as inq_DIRECT_MAIL_1,
            inq_00201511_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT_1,
            inq_00201511_INTERNET as inq_INTERNET_1,
            inq_00201511_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG_1,
            inq_00201511_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL_1

            from med_full_data_out
            where campus not contains "ATLANTA" and campus not contains "BROOKLYN" and campus not contains "JACKSONVILLE"
            order by campus;

        create table med_full_data_out_201512_out as select
            campus,
            201512 as month,

            sp_00201512_AGGREGATOR as spend_AGGREGATOR,
            inq_00201512_AGGREGATOR as inq_AGGREGATOR,
            round(inq_00201512_AGGREGATOR*cv_00201512_AGGREGATOR) as enr_AGGREGATOR,
            cv_00201512_AGGREGATOR as cv_AGGREGATOR,
            " " as seperator_AGGREGATOR,
            
            sp_00201512_SEM as spend_SEM,
            inq_00201512_SEM as inq_SEM,
            round(inq_00201512_SEM*cv_00201512_SEM) as enr_SEM,
            cv_00201512_SEM as cv_SEM,
            " " as seperator_SEM,

            sp_00201512_TELEVISION as spend_TELEVISION,
            inq_00201512_TELEVISION as inq_TELEVISION,
            round(inq_00201512_TELEVISION*cv_00201512_TELEVISION) as enr_TELEVISION,
            cv_00201512_TELEVISION as cv_TELEVISION,
            " " as seperator_TELEVISION,

            sp_00201512_WEBSITE as spend_WEBSITE,
            inq_00201512_WEBSITE as inq_WEBSITE,
            round(inq_00201512_WEBSITE*cv_00201512_WEBSITE) as enr_WEBSITE,
            cv_00201512_WEBSITE as cv_WEBSITE,
            " " as seperator_WEBSITE,

            sp_00201512_PRINT as spend_PRINT,
            inq_00201512_PRINT as inq_PRINT,
            round(inq_00201512_PRINT*cv_00201512_PRINT) as enr_PRINT,
            cv_00201512_PRINT as cv_PRINT,
            " " as seperator_PRINT,

            sp_00201512_RADIO as spend_RADIO,
            inq_00201512_RADIO as inq_RADIO,
            round(inq_00201512_RADIO*cv_00201512_RADIO) as enr_RADIO,
            cv_00201512_RADIO as cv_RADIO,
            " " as seperator_RADIO,

            sp_00201512_SPECIALTY as spend_SPECIALTY,
            inq_00201512_SPECIALTY as inq_SPECIALTY,
            round(inq_00201512_SPECIALTY*cv_00201512_SPECIALTY) as enr_SPECIALTY,
            cv_00201512_SPECIALTY as cv_SPECIALTY,
            " " as seperator_SPECIALTY,

            sp_00201512_RECIRCULATED as spend_RECIRCULATED,
            inq_00201512_RECIRCULATED as inq_RECIRCULATED,
            round(inq_00201512_RECIRCULATED*cv_00201512_RECIRCULATED) as enr_RECIRCULATED,
            cv_00201512_RECIRCULATED as cv_RECIRCULATED,
            " " as seperator_RECIRCULATED,

            sp_00201512_YELLOW_PAGES as spend_YELLOW_PAGES,
            inq_00201512_YELLOW_PAGES as inq_YELLOW_PAGES,
            round(inq_00201512_YELLOW_PAGES*cv_00201512_YELLOW_PAGES) as enr_YELLOW_PAGES,
            cv_00201512_YELLOW_PAGES as cv_YELLOW_PAGES,
            " " as seperator_YELLOW_PAGES,

            sp_00201512_DIRECT_MAIL as spend_DIRECT_MAIL,
            inq_00201512_DIRECT_MAIL as inq_DIRECT_MAIL,
            round(inq_00201512_DIRECT_MAIL*cv_00201512_DIRECT_MAIL) as enr_DIRECT_MAIL,
            cv_00201512_DIRECT_MAIL as cv_DIRECT_MAIL,
            " " as seperator_DIRECT_MAIL,

            sp_00201512_HIGH_SCHOOL_COMMENT as spend_HIGH_SCHOOL_COMMENT,
            inq_00201512_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT,
            round(inq_00201512_HIGH_SCHOOL_COMMENT*cv_00201512_HIGH_SCHOOL_COMMENT) as enr_HIGH_SCHOOL_COMMENT,
            cv_00201512_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT,
            " " as seperator_HIGH_SCHOOL_COMMENT,

            sp_00201512_INTERNET as spend_INTERNET,
            inq_00201512_INTERNET as inq_INTERNET,
            round(inq_00201512_INTERNET*cv_00201512_INTERNET) as enr_INTERNET,
            cv_00201512_INTERNET as cv_INTERNET,
            " " as seperator_INTERNET,
            
            sp_00201512_LATER_TOO_YOUNG as spend_LATER_TOO_YOUNG,
            inq_00201512_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG,
            round(inq_00201512_LATER_TOO_YOUNG*cv_00201512_LATER_TOO_YOUNG) as enr_LATER_TOO_YOUNG,
            cv_00201512_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG,
            " " as seperator_LATER_TOO_YOUNG,

            sp_00201512_PDL_OR_REFERRAL as spend_PDL_OR_REFERRAL,
            inq_00201512_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL,
            round(inq_00201512_PDL_OR_REFERRAL*cv_00201512_PDL_OR_REFERRAL) as enr_PDL_OR_REFERRAL,
            cv_00201512_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL,
            " " as seperator_PDL_OR_REFERRAL,

            cv_00201512_AGGREGATOR as cv_AGGREGATOR_1,
            cv_00201512_SEM as cv_SEM_1,
            cv_00201512_TELEVISION as cv_TELEVISION_1,
            cv_00201512_WEBSITE as cv_WEBSITE_1,
            cv_00201512_PRINT as cv_PRINT_1,
            cv_00201512_RADIO as cv_RADIO_1,
            cv_00201512_SPECIALTY as cv_SPECIALTY_1,
            cv_00201512_RECIRCULATED as cv_RECIRCULATED_1,
            cv_00201512_YELLOW_PAGES as cv_YELLOW_PAGES_1,
            cv_00201512_DIRECT_MAIL as cv_DIRECT_MAIL_1,
            cv_00201512_HIGH_SCHOOL_COMMENT as cv_HIGH_SCHOOL_COMMENT_1,
            cv_00201512_INTERNET as cv_INTERNET_1,
            cv_00201512_LATER_TOO_YOUNG as cv_LATER_TOO_YOUNG_1,
            cv_00201512_PDL_OR_REFERRAL as cv_PDL_OR_REFERRAL_1,

            cf_00201512_AGGREGATOR as coef_AGGREGATOR_1,
            cf_00201512_SEM as coef_SEM_1,
            cf_00201512_TELEVISION as coef_TELEVISION_1,
            cf_00201512_WEBSITE as coef_WEBSITE_1,
            cf_00201512_PRINT as coef_PRINT_1,
            cf_00201512_RADIO as coef_RADIO_1,
            cf_00201512_SPECIALTY as coef_SPECIALTY_1,
            cf_00201512_RECIRCULATED as coef_RECIRCULATED_1,
            cf_00201512_YELLOW_PAGES as coef_YELLOW_PAGES_1,
            cf_00201512_DIRECT_MAIL as coef_DIRECT_MAIL_1,
            cf_00201512_HIGH_SCHOOL_COMMENT as coef_HIGH_SCHOOL_COMMENT_1,
            cf_00201512_INTERNET as coef_INTERNET_1,
            cf_00201512_LATER_TOO_YOUNG as coef_LATER_TOO_YOUNG_1,
            cf_00201512_PDL_OR_REFERRAL as coef_PDL_OR_REFERRAL_1,

            int_00201512_AGGREGATOR as intercept_AGGREGATOR_1,
            int_00201512_SEM as intercept_SEM_1,
            int_00201512_TELEVISION as intercept_TELEVISION_1,
            int_00201512_WEBSITE as intercept_WEBSITE_1,
            int_00201512_PRINT as intercept_PRINT_1,
            int_00201512_RADIO as intercept_RADIO_1,
            int_00201512_SPECIALTY as intercept_SPECIALTY_1,
            int_00201512_RECIRCULATED as intercept_RECIRCULATED_1,
            int_00201512_YELLOW_PAGES as intercept_YELLOW_PAGES_1,
            int_00201512_DIRECT_MAIL as intercept_DIRECT_MAIL_1,
            int_00201512_HIGH_SCHOOL_COMMENT as intercept_HIGH_SCHOOL_COMMENT_1,
            int_00201512_INTERNET as intercept_INTERNET_1,
            int_00201512_LATER_TOO_YOUNG as intercept_LATER_TOO_YOUNG_1,
            int_00201512_PDL_OR_REFERRAL as intercept_PDL_OR_REFERRAL_1,

            af_00201512_AGGREGATOR as adj_factor_AGGREGATOR_1,
            af_00201512_SEM as adj_factor_SEM_1,
            af_00201512_TELEVISION as adj_factor_TELEVISION_1,
            af_00201512_WEBSITE as adj_factor_WEBSITE_1,
            af_00201512_PRINT as adj_factor_PRINT_1,
            af_00201512_RADIO as adj_factor_RADIO_1,
            af_00201512_SPECIALTY as adj_factor_SPECIALTY_1,
            af_00201512_RECIRCULATED as adj_factor_RECIRCULATED_1,
            af_00201512_YELLOW_PAGES as adj_factor_YELLOW_PAGES_1,
            af_00201512_DIRECT_MAIL as adj_factor_DIRECT_MAIL_1,
            af_00201512_HIGH_SCHOOL_COMMENT as adj_factor_HIGH_SCHOOL_COMMENT_1,
            af_00201512_INTERNET as adj_factor_INTERNET_1,
            af_00201512_LATER_TOO_YOUNG as adj_factor_LATER_TOO_YOUNG_1,
            af_00201512_PDL_OR_REFERRAL as adj_factor_PDL_OR_REFERRAL_1,

            inq_00201512_AGGREGATOR as inq_AGGREGATOR_1,
            inq_00201512_SEM as inq_SEM_1,
            inq_00201512_TELEVISION as inq_TELEVISION_1,
            inq_00201512_WEBSITE as inq_WEBSITE_1,
            inq_00201512_PRINT as inq_PRINT_1,
            inq_00201512_RADIO as inq_RADIO_1,
            inq_00201512_SPECIALTY as inq_SPECIALTY_1,
            inq_00201512_RECIRCULATED as inq_RECIRCULATED_1,
            inq_00201512_YELLOW_PAGES as inq_YELLOW_PAGES_1,
            inq_00201512_DIRECT_MAIL as inq_DIRECT_MAIL_1,
            inq_00201512_HIGH_SCHOOL_COMMENT as inq_HIGH_SCHOOL_COMMENT_1,
            inq_00201512_INTERNET as inq_INTERNET_1,
            inq_00201512_LATER_TOO_YOUNG as inq_LATER_TOO_YOUNG_1,
            inq_00201512_PDL_OR_REFERRAL as inq_PDL_OR_REFERRAL_1

            from med_full_data_out
            where campus not contains "ATLANTA" and campus not contains "BROOKLYN" and campus not contains "JACKSONVILLE"
            order by campus;
        quit;
    run;

    data model_data_out_dash_out;
        set
            med_full_data_out_201504_out
            med_full_data_out_201505_out
            med_full_data_out_201506_out
            med_full_data_out_201507_out
            med_full_data_out_201508_out
            med_full_data_out_201509_out
            med_full_data_out_201510_out
            med_full_data_out_201511_out
            med_full_data_out_201512_out;
    run;

    proc export data = model_data_out_dash_out
        outfile = "&modelPath\model_data_out_dash_out.xls" 
        dbms = excel2000 replace;
        sheet = "Raw Model Data"; 
    run;

%mend runSpendModel;

%runSpendModel;

