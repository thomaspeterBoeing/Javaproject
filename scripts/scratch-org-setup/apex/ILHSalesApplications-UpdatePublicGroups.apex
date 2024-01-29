List <Group> gr  = [SELECT Id, DeveloperName, Type FROM Group];

for(Group g1: gr){
  If (g1.DeveloperName == 'ILHSales' && g1.Type == 'Role and Internal Subordinates')
  {
     for(Group g2: gr){
      If(g2.DeveloperName == 'ViewAllAffiliationAccounts_R' ||
         g2.DeveloperName == 'ViewILHSalesListViews'){
        GroupMember gm = new GroupMember();
        gm.GroupId = g2.Id;
        gm.UserOrGroupID = g1.Id;
        insert gm;
      }
     }
  }

  If (g1.DeveloperName == 'SalesPlanner' && g1.Type == 'Role')
  {
    for(Group g2: gr){
      If(g2.DeveloperName == 'ViewSalesPlannerListViews' ||
         g2.DeveloperName == 'ViewAllILHMarketingCampaigns_Full' ||
         g2.DeveloperName == 'ViewAllILHSalesOpportunities_R' ||
         g2.DeveloperName == 'ViewAllConsumerAccounts_R')
      {
          GroupMember gm = new GroupMember();
          gm.GroupId = g2.Id;
          gm.UserOrGroupID = g1.Id;
          insert gm;
      }  
    }       
  }
  If (g1.DeveloperName == 'RetentionManager' && g1.Type == 'Role and Internal Subordinates'){
    for(Group g2: gr){
      If(g2.DeveloperName == 'ViewILHSalesListViews' ||
        g2.DeveloperName == 'ViewILHSalesListViews' ||
        g2.DeveloperName == 'ViewAllConsumerAccounts_RE' ||
        g2.DeveloperName == 'ViewAllILHMarketingCampaigns_R')
      {
          GroupMember gm = new GroupMember();
          gm.GroupId = g2.Id;
          gm.UserOrGroupID = g1.Id;
          insert gm;
      }
    }  
  }
}
