public with sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name FROM Account LIMIT 10];
    }

    public static void updateAvgCaseResolutionDays(List<Id> accountIds){
        Integer totalDays = 0, totalCases = 0;
        List<Account> accs = new List<Account>();
        
        List<Case> caseObjs = [SELECT Id,AccountId, CreatedDate, ClosedDate
                               FROM Case
                               WHERE IsClosed=true
                               AND AccountId in :accountIds];
        
        // retrive all the cases for this account
        for(Id accountId : accountIds){
            // get resolution days for each account (ClosedDate - CreatedDate)
            for(Case caseObj : caseObjs){
                if (caseObj.AccountId==accountId)
                {
                    // increase number of cases
                    totalCases++;
                    // get duration in days and add it to totalDays
                    totalDays += caseObj.CreatedDate.date().daysBetween(caseObj.ClosedDate.date());  
                }
            }
            
            Decimal resolutionDays = totalDays/totalCases;
            // update account object
            Account acc = new Account(Id=accountId, Avg_Case_Resolution_Days__c = resolutionDays);
            accs.add(acc);
        }
        
        update accs;
    }    
}