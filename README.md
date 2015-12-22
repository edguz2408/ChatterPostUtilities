## Synopsis
ChatterPostUtilities is an APEX class I developed for making chatter post an easy way, by using this class you won't need to implement Salesforce's ConnectApi components, all you need here are strings.

## Example
ChatterPostUtilities main method chatterPostFactoryBatchable receives a list of Map<Id, List<String>> so let's say you need a chatter post with no capabilities and you want the @mention to be located before the chatter post body you only need to follow the example below, remember the chatter post body will be organized according to the order in which you add the strings in the map's list.
```javascript
/* The code below will generate a chatter with no capabilities */

Id parentId; //This would be the chatter post parent record, it could be anything from a Sobject to a user's wall
List<Map<Id, List<String>>> result = New List<Map<Id, List<String>>>{
            new Map<Id, List<String>>{testAcct.Id => new List<String>{
                String.valueOf(userInfo.getUserId()), 'Test Post'}}
        };
        
ChatterPostUtilities.chatterPostFactoryBatchable(result, ChatterPostUtilities.CapabilityType.None);

/* The code below will generate a chatter post with a link capability */

Id parentId; //This would be the chatter post parent record, it could be anything from a Sobject to a user's wall
List<Map<Id, List<String>>> values = new List<Map<Id, List<String>>>{
new Map<Id, List<String>>{parentId => new List<String> {'Test Link', 'https://na14.salesforce.com/' + parentId}}};

ChatterPostUtilities.chatterPostFactoryBatchable(values, ChatterPostUtilities.CapabilityType.Link);

/* The code below will generate a chatter post with a Poll capability */

List<Map<Id, List<String>>> values = new List<Map<Id, List<String>>>{
new Map<Id, List<String>>{userInfo.getUserId() => new List<String> {'Do you like Salesforce?', 'Yes, I love it',
'No, I hate it'}}};

ChatterPostUtilities.chatterPostFactoryBatchable(values, ChatterPostUtilities.CapabilityType.Poll);
```

## Motivation
Whenever I had to work with chatter posts I had to implement the same stuff so I decided I would write an utility class on which I have all chatter post related logic and components so I can re-use them, this class is intelligent enough to know when you're trying to @mention someone or you just wanna add a single string.

## Installation
##### Just click the button below

<a href="https://githubsfdeploy.herokuapp.com?owner=edguz2408&repo=ChatterPostUtilities">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

## API Reference
ChatterPostUtilities contains the following public methods;

```javascript 
chatterPostFactoryBatchable(List<Map<Id, List<String>>> mChatterPostVals, CapabilityType capType)
createChatterPostComment(map<Id, List<String>> values)

//ChatterPostUtilities contains the following enum;

public enum CapabilityType {None, Link, Poll}
```
