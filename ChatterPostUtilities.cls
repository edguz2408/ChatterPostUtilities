/*******************************************
Class Name:             ChatterPostUtilities
Purpose:                Provide chatter posts functionalities
Author:                 Edwin Guzman
Created Date:           10/27/2014
*************************************************************/
public class ChatterPostUtilities {
    
    private static List<ConnectApi.BatchResult> saveResults;
    
    public static List<ConnectApi.BatchResult> chatterPostFactoryBatchable(List<Map<Id, List<String>>> mChatterPostVals, CapabilityType capType){        
                       
        List<ConnectApi.BatchInput> feedsToSend = new List<ConnectApi.BatchInput>();
        Map<Id, List<ConnectApi.MessageSegmentInput>> segments = new Map<Id, List<ConnectApi.MessageSegmentInput>>();
        Map<Id, ConnectApi.FeedElementCapabilitiesInput> capabilitiesMap = new Map<Id, ConnectApi.FeedElementCapabilitiesInput>(); 
        Map<Id, List<String>> valsForCapabilities = new Map<Id, List<String>>();
        Map<Id, List<String>> valsForText = new Map<Id, List<String>>(); 
        
        for(Map<Id, List<String>> val : mChatterPostVals){
            for(Id recordId : val.keySet()){
                if(capType == CapabilityType.None){
                    segments = getChatterSegments(val);
                }else if(capType != CapabilityType.None){
                    for(String strVal : val.get(recordId)){
                        if(capType == CapabilityType.Link){
                            if(strVal.contains('http')){
                                valsForCapabilities.put(recordId, new List<String>{'Link:' + strVal});                               
                            } else {
                                if(valsForText.isEmpty()){
                                    valsForText.put(recordId, new List<String>{strVal});
                                } else {
                                    valsForText.get(recordId).add(strVal);
                                }
                            }
                        } else if(capType == CapabilityType.Poll){
                            if(val.get(recordId).size() < 3)
                                throw new PollChatterPostException('There must be at least two choices');
                            
                            if(valsForText.isEmpty()){
                                valsForText.put(recordId, new List<String>{strVal});
                            } else {
                                if(valsForCapabilities.isEmpty())
                                    valsForCapabilities.put(recordId, new List<String>{'Choice:' + strVal});
                                else
                                    valsForCapabilities.get(recordId).add('Choice:' + strVal);
                            }
                        }
                       
                    }                   
                }
                
                if(!valsForCapabilities.isEmpty())
                    capabilitiesMap = getCapabilities(valsForCapabilities);
                if(!valsForText.isEmpty())
                    segments = getChatterSegments(valsForText);
                
                if(segments.containsKey(recordId)){
                    ConnectApi.FeedItemInput feed = new ConnectApi.FeedItemInput(); 
                    feed.body = new ConnectApi.MessageBodyInput();                
                    feed.visibility = connectapi.FeedItemVisibilityType.AllUsers;                
                    feed.subjectId = recordId;                   
                    
                    if(!capabilitiesMap.isEmpty()){
                        if(capabilitiesMap.containsKey(recordId)){
                           System.debug('Feed Item:: ' + feed); 
                           System.debug('Link Input:: ' + capabilitiesMap.get(recordId));
                           feed.capabilities = capabilitiesMap.get(recordId); 
                        }                        	
                    }
                    
                    feed.body.messageSegments = segments.get(recordId);
                    System.debug('Segment ===> ' + segments.get(recordId));
                    
                    if(val.containsKey(recordId)){
                        feedsToSend.add(new ConnectApi.BatchInput(feed));
                    }
                }
            }
        }
        
         if(!feedsToSend.isEmpty()){
            System.debug('feeds to send ' + feedsToSend);
            sendChatterPosts(feedsToSend); 
        } 
        return saveResults;
    }
    
    private static Map<Id, List<ConnectApi.MessageSegmentInput>> getChatterSegments(Map<Id, List<String>> values){
        Map<Id, List<ConnectApi.MessageSegmentInput>> result = new Map<Id, List<ConnectApi.MessageSegmentInput>>();
        String linkStr;
        
        for(Id recordId : values.keySet()){           
            result.put(recordId, new List<ConnectApi.MessageSegmentInput>()); 
            for(String mapValue : values.get(recordId)){
                if(mapValue != null && mapValue != ''){                    
                    System.debug('Map Value ===>' + mapValue);
                    if(mapValue.startsWith('005')){
                        try{
                            Id mentionId = Id.valueOf(mapValue);
                            ConnectApi.MentionSegmentInput chatterMention = new ConnectApi.MentionSegmentInput();
                            chatterMention.Id = mentionId;
                            result.get(recordId).add(chatterMention);
                            System.debug('Chatter mention ===> ' + result.get(recordId));
                        } catch(StringException ex){
                            System.debug('String Exception ' + ex.getMessage());                               
                            mapValue = '-' + mapValue.substring(0, mapValue.length());
                        }
                    }
                    if(!mapValue.startsWith('005')){
                        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();                                                
                        textSegment.text = ' ';                        
                        textSegment.text += mapValue;
                        textSegment.text += ' ';                        
                        result.get(recordId).add(textSegment);    
                    }                   
                }
            }
        }
        System.debug('Result ===> '  + result);
        return result;
    }
    
    private static Map<Id, ConnectApi.FeedElementCapabilitiesInput> getCapabilities(Map<Id, List<String>> values){
        Map<Id, ConnectApi.FeedElementCapabilitiesInput> result = new Map<Id, ConnectApi.FeedElementCapabilitiesInput>();
        List<String> choices = new List<String>();
        
        for(Id recordId : values.keySet()){
            ConnectApi.FeedElementCapabilitiesInput capInput = new ConnectApi.FeedElementCapabilitiesInput();             
            for(String mapValue : values.get(recordId)){
                if(mapValue.startsWith('Link:')){ 
                    mapValue = mapValue.remove('Link:');
                    capInput.link = new ConnectApi.LinkCapabilityInput();
                    capInput.link.urlName = 'Link to Record';
                    capInput.link.url = mapValue;                   
                } else if (mapValue.startsWith('Choice:')){
                    if(capInput.poll == null)
                        capInput.poll = new ConnectApi.PollCapabilityInput();          
                    
                    mapValue = mapValue.remove('Choice:'); 
                    choices.add(mapValue);
                   
                }
            }
            if(!choices.isEmpty())
                capInput.poll.choices = choices;
            if(capInput != null)
                result.put(recordId, capInput);
        }
        System.debug('Result ===> '  + result);
        return result;
    }
    
    static boolean sendChatterPosts(List<ConnectApi.BatchInput> feeds){
        boolean result = false;
        saveResults = new List<ConnectApi.BatchResult>();
        
        if(!feeds.isEmpty()){
            System.debug('Feeds ===> ' + feeds);                        
            try{                            
                saveResults = ConnectApi.ChatterFeeds.postFeedElementBatch(null, feeds);                  
                result = true;    
            }catch(Exception ex){
                System.debug(ex.getMessage());
            }            
        }
        return result;
    }
    public static void createChatterPostComment(map<Id, List<String>> values){
        
        Map<Id, ConnectApi.CommentInput>  commentsToSend = new Map<Id, ConnectApi.CommentInput>();
        Map<Id, List<ConnectApi.MessageSegmentInput>> segments = getChatterSegments(values);
        
        for(Id parentId : values.keySet()){
            if(segments.containsKey(parentId)){
                ConnectApi.CommentInput input = new ConnectApi.CommentInput();
                input.body = new ConnectApi.MessageBodyInput();
                
                input.body.messageSegments = segments.get(parentId);
                commentsToSend.put(parentId, input);                
                
            }
            
        }
        
        if(commentsToSend.isEmpty() == false){
            for(Id parentId : commentsToSend.keySet()){                
                ConnectApi.ChatterFeeds.postCommentToFeedElement(null, parentId, commentsToSend.get(parentId), null);                
            }
        }
        
    }
    
    public enum CapabilityType {None, Link, Poll}
    private class PollChatterPostException Extends Exception { }
    
}
