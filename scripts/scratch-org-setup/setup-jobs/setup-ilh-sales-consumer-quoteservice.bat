
echo off
REM This script will install package version for ILH Sales Rate Page. 
REM  !!!!  This should only be used for scratch org setup.  !!!!!!!
REM
REM  Dependencies:   None
REM -------------------------------------------------------------------------------------------------------

call sf project deploy start --source-dir "d2c-org/ilh-sales/consumer-quoteservice"