/*******************************************
Class Name:             ChatterPostUtilitiesTest
Purpose:                Test class for ChatterPostUtilities class  
Author:                 Edwin Guzman
Created Date:           11/5/2014
*************************************************************/
@isTest(seeAllData=true)
public class ChatterPostUtilitiesTest {
	         
    static Account createAccount(){      
        
        // Create an Account
        Account acc=new Account(Name='Test Account', 
                                BillingStreet='Test Street',                                
                                BillingCity='Test',                                
                                BillingPostalCode='UTEST1 1UT'
                               );
        insert acc;
        System.assert(acc != null, 'Account record cannot be null');
      
        
        return acc;
    }
    
    public static testmethod void shouldMakeRecordChatterPost(){
      
        Account testAcct = createAccount();
        
        List<Map<Id, List<String>>> result = New List<Map<Id, List<String>>>{
            new Map<Id, List<String>>{testAcct.Id => new List<String>{
                String.valueOf(userInfo.getUserId()), 'Test Post'}}
        };
        System.Assert(ChatterPostUtilities.chatterPostFactoryBatchable(result, ChatterPostUtilities.CapabilityType.None).isEmpty() == false
                     ,'Chatter post must be inserted');
    }
    
    public static testmethod void shouldMakeChatterPostWithLinkCapability(){
        
        Account testAcct = createAccount();
        
        List<Map<Id, List<String>>> values = new List<Map<Id, List<String>>>{
        new Map<Id, List<String>>{testAcct.Id => new List<String> {'Test Link', 'https://na14.salesforce.com/' + testAcct.Id}}};
            
         System.Assert(ChatterPostUtilities.chatterPostFactoryBatchable(values, ChatterPostUtilities.CapabilityType.Link).isEmpty() == false
                     ,'Chatter post must be inserted');
    }
    
    public static testmethod void shouldMakeChatterPostWithPollCapability(){
        
      List<Map<Id, List<String>>> values = new List<Map<Id, List<String>>>{
          new Map<Id, List<String>>{userInfo.getUserId() => new List<String> {'Do you like Salesforce?', 'Yes, I love it',
    	  'No, I hate it'}}};
       
      System.Assert(ChatterPostUtilities.chatterPostFactoryBatchable(values, ChatterPostUtilities.CapabilityType.Poll).isEmpty() == false
                     ,'Chatter post must be inserted');
    }
    
    public static testmethod void shouldGenerateChatterPostComment(){
        
        test.startTest();
        
        Account testAcct = createAccount();        
        
        List<Map<Id, List<String>>> result = new List<Map<Id, List<String>>>{new Map<Id, List<String>>
        {testAcct.Id =>new List<String>{'Test Chatter Post Verbiage'}}}; 
            
            if(!result.isEmpty()){                                        
                ConnectApi.FeedItem feed = (ConnectApi.FeedItem)ChatterPostUtilities.chatterPostFactoryBatchable(
                    result, ChatterPostUtilities.CapabilityType.None
                )[0].getResult();
                
                    ChatterPostUtilities.createChatterPostComment(New Map<Id, List<String>>{
                    feed.Id => new List<String> {'Test Comment'}}
                                                             );
                
                System.assertEquals(false, feed == null);
            }
        
        test.stopTest();
    }
    
}