**How to setup scratch org.**

Step 1.  Create your local Repo.

Step 2.  Authorize the Dev Hub   
    
    - In Command Pallete use the option SFDX:Authorize Dev Hub.

    - Remember the Alias that you set.  This will be needed in 
    future steps.

Step 3.  Create a Scratch Org

    - In Command Pallete use the option SFDX: Create a Default Scratch Org.
    - Choose Default for definition file, 
    - Name it.  
    - Choose 1 - 30 for number of days.  (If you will be creating several scratch orgs choose a lower number of days.  Our org has a 100 limit)

Step 4.  Setup profiles.

    Profiles don't install correctly.  Manually create profiles before installing meta data.

    - Create profiles cloning from Minimum Access - Salesforce
        - D2C Administrator
        - ILH Sales Agent
Step 5  Run Scripts to Load Scratch Org.

    - Run scripts for the packages you would like to install.  If you are doing these individually you will need to do them in order.  
    Each script has the dependencies listed in the comments. 

    - To load all packages use the .bat file in Setup-jobs labeled setup-install-all-packages.

    - When running scripts you will need to enter the Alias for the Dev Hub you authorized and the installation key.

    - Installation Key is: d2c-xe35G@Y