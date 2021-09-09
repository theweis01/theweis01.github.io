/***********************************************************************************************************************************
* Date: 2020/06/15  
* Author: Olivia Chen (Shiran.Chen@cchmc.org)
* Project: RDCRN
* Protocol: 
* Program Name: REDCapAPIExport.sas
* Program Purpose:  extract data from REDCap using API and save as csv file
* Data Sources:  REDCAP
* Datasets Created: 
 
* INSTRUCTIONS: This provides sample code to access RDCRN REDCap (cloud) data using the RDCRN SAS  (cloud) software.
        * User will need to contact the RDCRN DCC data manager for the specific consoritum / study to obtain token from REDCap (line 26 below).
        * User will need to specific the RawDataDir (line 33 below).
        * The final product of this program is a .csv file with the data and headers.
        * To produce a SAS dataset with all SAS formats and labels applied to the data, the user will need to download the SAS program generated
            by REDCap and run it on the .csv file. PLEASE NOTE: a couple of lines of code will need to be changed in that program.  See lines 78-95 below.
**********************************************************************************************************************************/
 
proc datasets lib=work kill nolist; quit;
 
 
*----------------------------------------------------------------------------------------------;
*     Specify project and user-specific token and set up data folder       ;
*----------------------------------------------------------------------------------------------;
 
*** Project- and user-specific token obtained from REDCap.   ***;
%let mytoken = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   ;
 
* Edit the protocol id;
%let Protocol = ;
 
* Specify path and name of the csv data to be extracted from REDCap;
%let DLM=\;
%let RawDataDir = ;
 
libname raw "&RawDataDir";
 
%let csv_file = "&RawDataDir.&DLM.&Protocol..csv";
 
 
*--------------------------------------------------------------;
*     Extract data from REDCap         ;
*--------------------------------------------------------------;
 
 *** Text file for API parameters that the define the request sent to REDCap API. Will be created in a DATA step. Extension can be .csv, .txt, .dat ***;
filename my_in "&RawDataDir.&DLM.REDCap_Parameters_&Protocol..txt";*redcap parameter file;
 
 
*** .CSV output file to contain the exported data ***;
filename my_out "&RawDataDir.&DLM.&Protocol..csv";*redcap output data file;
 
 
*** Output file to contain PROC HTTP status information returned from REDCap API (this is optional) ***;
filename status "&RawDataDir.&DLM.REDCap_Status_&Protocol..txt";*redcap status file;
 
 
*** Create the text file to hold the API parameters. ***;
 
data _null_ ;
      file my_in ;
      put "%NRStr(token=)&mytoken%NRStr(&content=record&format=csv&importCheckboxLabel=true&exportDataAccessGroups=true&returnFormat=csv)";
run;
 
 
*** PROC HTTP call.  ***;
 
proc http
    in= my_in
    out= my_out
    headerout = status
    url ="https://rc.rarediseasesnetwork.org/api/"
    method="post";
run;
   
 
*-----------------------------------------------------------------;
* Read .CSV data file into SAS and save it.
  Uses project-specific SAS code generated through the REDCap
  Data Export Tool with a modification (shown below) to the
  first DATA step in the program to work with the REDCap API data.
*-----------------------------------------------------------------;
 
*** Code copied from the REDCap-generated SAS program
(this is optional, may use PROC IMPORT or a DATA step) ***;
*** Change INFILE name to data named in PROC HTTP OUT = ***;
*** Change FIRSTOBS=1 to FIRSTOBS=2 to indicate that
a header row exists ***;
  
 /*
data REDCAP; %let _EFIERR_ = 0;
infile &csv_file  delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
<lines omitted>
run; quit;
