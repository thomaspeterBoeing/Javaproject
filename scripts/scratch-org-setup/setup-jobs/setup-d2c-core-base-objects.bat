
echo off
REM This script will install package version for D2C Core Base Configuration package.
REM Test data is also generated along with test admin user account is created if selected.  
REM  !!!!  This should only be used for scratch org setup.  !!!!!!!
REM
REM  Dependencies:   None
REM -------------------------------------------------------------------------------------------------------
IF [%1] == [] goto Setup

Set devhub= %1
Set installationkey= %2

goto Install 

:Setup
set /p devhub=Enter DevHub Alias: 
set /p installationkey=Enter Installation Key to install: 

:Install
echo Getting latest package version id for Package Id: 0HoDm0000004CEIKA2  - D2C Core Base Objects
call sf data query --query "SELECT SubscriberPackageVersionId FROM Package2Version WHERE Package2ID = '0HoDm0000004CEIKA2' AND IsDeprecated = False  ORDER BY CreatedDate DESC LIMIT 1" > c:\temp\packageVerID.json --use-tooling-api --result-format json --target-org %devhub% --wait 2' 
echo Getting json file from temp drive with results from query
for /f "tokens=1,2 delims=:{} " %%A in (c:\temp\packageVerID.json) do (
    If "%%~A"=="SubscriberPackageVersionId" set packageversionid=%%~B 
)

echo Found Package Version ID %packageversionid%  Installing package 
call sf package install --package %packageversionid% --installation-key %installationkey% --wait 5 --security-type AllUsers 
echo "*** Assign Permission Sets ...."
call sf org assign permset --name AccountAffiliation_D2CBaseObjects_CRED

echo "*** Load data ... " 
call sf data import tree  --plan scripts\scratch-org-setup\data\d2c-core-base-objects-data-plan.json
echo "*** Updating Account record type ..."
call sf apex run -f scripts\scratch-org-setup\apex\D2CBaseObjects_UpdateAccountRecordtype.apex
echo "*** Updating your user record ..."
call sf apex run -f scripts\scratch-org-setup\apex\D2CBaseObject_UpdateMyUserRecord.apex
echo **********  Installled Package D2C Core Base Objects **********
