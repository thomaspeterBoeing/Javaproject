echo off
REM ------------------------------------------------------------------------------------------------------
REM This script will install all packages in the correct order for your scratch org.  
REM Test data is also generated along with test admin user account is created if selected.  
REM  !!!!  This should only be used for scratch org setup.  !!!!!!!
REM -------------------------------------------------------------------------------------------------------

set /p DevHub= Enter the alias for the authorized dev hub:

REM Scratch Orgs may need profiles created before running packages.  Research if this can be scripted.
REM For now Scratch orgs should be setup manually and profiles created before running this script
:: set /p ScratchOrgYN= Have you already setup a scratch org (Y/N)
set /p InstallationKey= Enter Installation Key for packages: 
:: if /I %ScratchOrgYN% == Y goto :LoadSO

:: set /p ScratchOrgName=Name of Scratch Org: 
:: set /p NumberOfDays=Number of Days for Scratch Org:
:: echo "*** Creating scratch Org..." %ScratchOrgName%
:: call sf org create scratch --set-default --definition-file config/project-scratch-def.json --alias %ScratchOrgName%  --duration-days %NumberOfDays% --wait 10

:LoadSO
rem call sf project deploy start --source-dir "d2c-org/d2c-core/unpackaged-configurations"
rem if %ERRORLEVEL% NEQ 0 goto :Done
call scripts\scratch-org-setup\setup-jobs\setup-d2c-core-base-objects.bat %DevHub% %InstallationKey%
call scripts\scratch-org-setup\setup-jobs\setup-ilh-sales-base-objects.bat %DevHub% %InstallationKey%
call scripts\scratch-org-setup\setup-jobs\setup-d2c-core-base-code.bat %DevHub% %InstallationKey%
call scripts\scratch-org-setup\setup-jobs\setup-d2c-core-error-handling-framework.bat %DevHub% %InstallationKey%
call scripts\scratch-org-setup\setup-jobs\setup-ilh-sales-base-code.bat %DevHub% %InstallationKey%
call scripts\scratch-org-setup\setup-jobs\setup-ilh-sales-consumer-search.bat %DevHub% %InstallationKey%
call scripts\scratch-org-setup\setup-jobs\setup-ilh-sales-consumer-opportunity-automation.bat %DevHub% %InstallationKey%
call scripts\scratch-org-setup\setup-jobs\setup-ilh-sales-policy-summary.bat %DevHub% %InstallationKey%
call scripts\scratch-org-setup\setup-jobs\setup-ilh-sales-consumer-update.bat %DevHub% %InstallationKey%
REM call scripts\scratch-org-setup\setup-jobs\setup-ilh-sales-marketing-history.bat %DevHub% %InstallationKey%
call scripts\scratch-org-setup\setup-jobs\setup-ilh-sales-applications.bat %DevHub% %InstallationKey%
call sf project deploy start --source-dir "d2c-org/ilh-sales/post-install-unpackaged"

echo @@@@@@@@@@@@@@@@@  SCRATCH ORG LOAD - COMPLETED   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

:Done

