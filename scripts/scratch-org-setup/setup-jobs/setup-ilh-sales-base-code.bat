
echo off
REM This script will install package version for D2C Core Base code package. 
REM  !!!!  This should only be used for scratch org setup.  !!!!!!!
REM -------------------------------------------------------------------------------------------------------

IF [%1] == [] goto Setup

Set devhub= %1
Set installationkey= %2

goto Install 

:Setup
set /p devhub=Enter DevHub Alias: 
set /p installationkey=Enter Installation Key to install: 

:Install
echo Getting latest package version id for Package Id: 0HoDm0000004CESKA2  - ILH Sales Base Code
call sf data query --query "SELECT SubscriberPackageVersionId FROM Package2Version WHERE Package2ID = '0HoDm0000004CESKA2' ORDER BY CreatedDate DESC LIMIT 1" > c:\temp\packageVerID.json --use-tooling-api --result-format json --target-org %devhub% --wait 2' 
echo Getting json file from temp drive with results from query
for /f "tokens=1,2 delims=:{} " %%A in (c:\temp\packageVerID.json) do (
    If "%%~A"=="SubscriberPackageVersionId" set packageversionid=%%~B 
)

echo Found Package Version ID %packageversionid%  Installing package 
call sf package install --package %packageversionid% --installation-key %installationkey% --wait 5 --security-type AllUsers 

echo *********** Installed package ILH Sales Base Code

