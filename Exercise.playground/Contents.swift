/*:

## Fueled Swift Exercise

A blogging platform stores the following information that is available through separate API endpoints:
+ user accounts
+ blog posts for each user
+ comments for each blog post

### Objective
The organization needs to identify the 3 most engaging bloggers on the platform. Using only Swift and the Foundation library, output the top 3 users with the highest average number of comments per post in the following format:

&nbsp;&nbsp;&nbsp; `[name]` - `[id]`, Score: `[average_comments]`

Instead of connecting to a remote API, we are providing this data in form of JSON files, which have been made accessible through a custom Resource enum with a `data` method that provides the contents of the file.

### What we're looking to evaluate
1. How you choose to model your data
2. How you transform the provided JSON data to your data model
3. How you use your models to calculate this average value
4. How you use this data point to sort the users

*/

import Foundation

/*:
1. First, start by modeling the data objects that will be used.
*/
struct Comments: Codable {
  let postID: Int
  let id: Int

  private enum CodingKeys: String, CodingKey {
    case postID = "postId"
    case id
  }
}

struct Posts: Codable {
  let userID: Int
  let id: Int

  private enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case id
  }
}


struct Users: Codable {
  let id: Int
  let name: String
  let username: String
}


/*:
2. Next, decode the JSON source using `Resource.users.data()`.
*/

//Getting resources from the json files
guard let commentsURL = Bundle.main.url(forResource: "\(Resource.comments)", withExtension: "json") else{
    fatalError("Error in commentsURL")
}
guard let postsURL = Bundle.main.url(forResource: "\(Resource.posts)", withExtension: "json") else{
    fatalError("Error in postsURL")
}
guard let usersURL = Bundle.main.url(forResource: "\(Resource.users)", withExtension: "json") else{
    fatalError("Error in usersURL")
}

//Getting data for the models
guard let commentsData = try? Data(contentsOf: commentsURL) else{
    fatalError("Error comments content")
}
guard let postsData = try? Data(contentsOf: postsURL) else{
    fatalError("Error post content")
}
guard let usersData = try? Data(contentsOf: usersURL) else{
    fatalError("Error user content")
}

//Decoding json files
let decoder = JSONDecoder()
guard let comments = try? decoder.decode([Comments].self, from: commentsData) else{
    fatalError("decoding comments failed")
}
guard let posts = try? decoder.decode([Posts].self, from: postsData) else{
    fatalError("decoding posts failed")
}
guard let users = try? decoder.decode([Users].self, from: usersData) else{
    fatalError("decoding users failed")
}

/*:
3. Next, use your populated models to calculate the average number of comments per user.
*/

var countComments: [Int: Int] = [:] //[postID: occurrence]
var countUserAvgs: [String: Float] = [:] //[name: score]


//Counting the number of comments for each post
for item in comments{
    countComments[item.postID] = (countComments[item.postID] ?? 0) + 1
    
}

//Sorting the dictionary in descending order
let firstDict = countComments.sorted(by: {$0.key < $1.key})


var avgs: [Float] = []

var userSum = 0
var userAvg = 0
var count = 0
var convertToFloat = Float(0)

//Calculating the average number of comments per post
for i in firstDict{
    userSum = i.value + userSum
    convertToFloat = Float(userSum)
    count = count + 1
    if count == 10{
        avgs.append(convertToFloat/10.0)
        count = 0
        userSum = 0
    }
}


/*:
4. Finally, use your calculated metric to find the 3 most engaging bloggers, sort order, and output the result.
*/

//Populating the dictionary with the key(blogger's name) and value(Score)
for (index, item) in users.enumerated(){
    countUserAvgs[item.name] = avgs[index]
}

//Formatting the output of the dictionary in descending order
let sorted = countUserAvgs.sorted(by: {$0.value > $1.value})
for (key, value) in sorted{
    print("Name:",key, ",","Score:", value)
    
}
