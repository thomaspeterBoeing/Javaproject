echo off
REM -----------------------------------------------------------------------------------------------------
REM This script will install package version for ILH Sales Base Configuration package.
REM Test data is also generated along with test admin user account is created if selected.  
REM  !!!!  This should only be used for scratch org setup.  !!!!!!!
REM
REM  Dependencies:   
REM       -  D2C Core Base Configuration
REM -------------------------------------------------------------------------------------------------------

IF [%1] == [] goto setup

Set devhub= %1
Set installationkey= %2

goto install 

:setup
set /p devhub=Enter DevHub Alias: 
set /p installationkey=Enter Installation Key to install: 

:install
echo Getting latest package version id for Package Id: 0HoDm0000004CEIKA2  - ILH Sales Base Configurations
call sf data query --query "SELECT SubscriberPackageVersionId FROM Package2Version WHERE Package2ID = '0HoDm0000004CENKA2' ORDER BY CreatedDate DESC LIMIT 1" > c:\temp\packageVerID.json --use-tooling-api --result-format json --target-org %devhub% --wait 2' 
echo Getting json file from temp drive with results from query
for /f "tokens=1,2 delims=:{} " %%A in (c:\temp\packageVerID.json) do (
    If "%%~A"=="SubscriberPackageVersionId" set packageversionid=%%~B 
)

echo Found Package Version ID %packageversionid%  Installing package 
call sf package install --package %packageversionid% --installation-key %installationkey% --wait 2 --security-type AllUsers  

call sf org assign permset --name Admin_ILHSalesBaseConfiguration_ModifyAll

echo "*** Load data ... " 
call sf data import tree  --plan scripts\scratch-org-setup\data\ilh-sales-base-objects-data-plan.json
echo "*** Updating Person Account record type ...."
call sf apex run -f scripts\scratch-org-setup\apex\ILHSalesBaseObjects-UpdatePersonAccountRecordtype.apex
REM This feature was disabled. Will keep code for now in case it is enabled in the future. 
REM echo "*** Assign Account Contact Relation... "
REM call sf apex run -f scripts\scratch-org-setup\apex\ILHSalesBaseConfig-InsertAccountContactRelation.apex

echo "*** Update Campaign RecordType... "
call sf apex run -f scripts\scratch-org-setup\apex\ILHSalesBaseObjects-UpdateCampaignRecordtype.apex
echo "*** Insert Opportunities... "
call sf apex run -f scripts\scratch-org-setup\apex\ILHSalesBaseObjects-InsertOpportunities.apex

REM  Following script does not work until D2C Adminstrator Profile is setup.  Package is unable to deploy a new profile.
REM echo "*** Insert Admin User assigned to D2C Administrator Profile ****"
REM call sf apex run -f scripts\scratch-org-setup\apex\D2CBaseConfig_InsertD2CAdminUser.apex

echo **********  Installled Package ILH Sales Base Objects **********