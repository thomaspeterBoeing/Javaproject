

@REM This script will install package version for D2C Core Base Configuration package.
@REM Test data is also generated along with test admin user account is created if selected.  
@REM  !!!!  This should only be used for scratch org setup.  !!!!!!!
@REM -------------------------------------------------------------------------------------------------------
echo off
echo "Install D2C Core Base Configuration Version"
set /p packageversionId=Enter Package Version ID to install:
call sf package install --package %packageversionId% --installation-key d2c-xe35G@Y --wait 2  

call sf org assign permset --name Admin_D2CBaseConfiguration_ModifyAll

echo "*** Load data ... " 
call sf data import tree  --plan scripts\scratch-org-setup\data\d2c-core-base-configuration-data-plan.json
echo "*** Updating Account record type ..."
call sf apex run -f scripts\scratch-org-setup\apex\D2CBaseConfig_UpdateAccountRecordtype.apex

echo "*** Test Data Loaded for D2C Core Base Configuration Package :) ***"