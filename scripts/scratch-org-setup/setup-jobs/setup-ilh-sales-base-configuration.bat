

@REM This script will install package version for ILH Sales Base Configuration package.
@REM Test data is also generated along with test admin user account is created if selected.  
@REM  !!!!  This should only be used for scratch org setup.  !!!!!!!
@REM -------------------------------------------------------------------------------------------------------
echo off
echo "Install D2C Core Base Configuration Version"
@REM set /p packageversionId=Enter Package Version ID to install:
@REM call sf package install --package %packageversionId% --installation-key d2c-xe35G@Y --wait 2  

call sf org assign permset --name Admin_ILHSalesBaseConfiguration_ModifyAll

echo "*** Load data ... " 
call sf data import tree  --plan scripts\scratch-org-setup\data\ilh-sales-base-configuration-data-plan.json
echo "*** Updating Person Account record type ...."
call sf apex run -f scripts\scratch-org-setup\apex\ILHSalesBaseConfig-UpdatePersonAccountRecordtype.apex
echo "*** Assign Account Contact Relation... "
call sf apex run -f scripts\scratch-org-setup\apex\ILHSalesBaseConfig-InsertAccountContactRelation.apex
echo "*** Update Campaign RecordType... "
call sf apex run -f scripts\scratch-org-setup\apex\ILHSalesBaseConfig-UpdateCampaignRecordtype.apex
echo "*** Insert Opportunities... "
call sf apex run -f scripts\scratch-org-setup\apex\ILHSalesBaseConfig-InsertOpportunities.apex

@REM  Following script does not work until D2C Adminstrator Profile is setup.  Package is unable to deploy a new profile.
@REM echo "*** Insert Admin User assigned to D2C Administrator Profile ****"
@REM call sf apex run -f scripts\scratch-org-setup\apex\D2CBaseConfig_InsertD2CAdminUser.apex
echo "*** Test Data Loaded for D2C Core Base Configuration Package :) ***"