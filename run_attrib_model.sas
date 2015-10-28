/***********************************************************
*
* Project:       
* Program Name:  runAttribModel.sas
* Author:        U-degobah\rsowers
*
* Creation Date: <2014-09-11 22:06:43> 
* Time-stamp:    <2014-10-07 14:35:43>
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

%macro runAttribModel(inqData       = kaplan_inquiry_detail ,
                      enrData       = kaplan_enrollment_detail ,
                      spendData     = kaplan_spending_detail ,
                      leadMapData   = lead_source_map ,
                      modelPath     = C:\cygwin64\home\rsowers\projects\kaplan_model_v2 ,
                      libPath       = &modelPath\lib\attrib ,
                      dataPath      = &modelPath\data\spend ,
                      rawPath       = &modelPath\data\raw );

    /***********************************************************
     * Define where to get and put the data
     ***********************************************************/
    
    libname outlib "&dataPath";
    libname rawlib "&rawPath";

    /***********************************************************
     * Include all needed code
     ***********************************************************/

    %include "&libPath\getDetailData.sas";

    /***********************************************************
     * Get the data needed for attribution
     ***********************************************************/

    %getDetailData(inqData   = rawlib.&inqData ,
                   enrData   = rawlib.&enrData ,
                   spendData = rawlib.&spendData ,
                   mapData   = rawlib.&leadMapData ,
                   outPath   = &modelPath ,
                   outDS     = outlib.attrib_long_data );
    
    proc insight data = outlib.attrib_long_data; run;
    
%mend runAttribModel;

%runAttribModel;

