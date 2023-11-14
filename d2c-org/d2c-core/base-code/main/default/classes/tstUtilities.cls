@isTest
public with sharing class tstUtilities {
    

    static testmethod void testfmtphoneisblnk(){
        String phonenum=' ';
        String fmtphone=Utilities.formatPhone(phonenum);
        Assert.areEqual(fmtphone,phonenum);
    }
    
    static testmethod void testfmtphoneis10digit(){
        String phonenum='123-123-1234';
        String fmtphone=Utilities.formatPhone(phonenum);
        Assert.areEqual(fmtphone,'(123) 123-1234');
    }
    static testmethod void testfmtphoneis11digit(){
        String phonenum='1123-123-1234';
        String fmtphone=Utilities.formatPhone(phonenum);
        Assert.areEqual(fmtphone,'(123) 123-1234');
    }
    static testmethod void testfmtphoneisnot10or11digit(){
        String phonenum='1123123123412';
        String fmtphone=Utilities.formatPhone(phonenum);
        Assert.areEqual(fmtphone,'1123123123412');
    }
    
    static testmethod void testremovephformatting(){
        String phonenum='(122)123-1234';
        String fmtphone=Utilities.removeAllPhoneFormatting(phonenum);
        Assert.areEqual(fmtphone,'1221231234');
    }
    static testmethod void dateformatswitch(){
        String dat='12/13/2013';
        String fmtdat=Utilities.DateFormatSwitchMMDDYYYTtoYYYYMMDD(dat);
        Assert.areEqual(fmtdat,'2013-12-13');
    }
    static testmethod void dateformatswitchsingledigit(){
        String dat='1/1/2013';
        String fmtdat=Utilities.DateFormatSwitchMMDDYYYTtoYYYYMMDD(dat);
        Assert.areEqual(fmtdat,'2013-01-01');
    }
    static testmethod void dateformatswitchnullcheck(){
        String dat='01012013';
        String fmtdat=Utilities.DateFormatSwitchMMDDYYYTtoYYYYMMDD(dat);
        Assert.isnull(fmtdat);
    }
    
}