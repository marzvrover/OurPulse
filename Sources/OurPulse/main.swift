import DotEnv
import Foundation
import NaturalLanguage
import Rainbow

var env: () = try DotEnv.load(path: ".env")

TwitterAPI.authorization_secrets["bearer_token"] = ProcessInfo.processInfo.environment["TWITTER_BEARER_TOKEN"]!

var query = "#DragRace"

print("Analyzing \(query)".green)

var tweets = TwitterAPI.search(query: query)!

let score = analyzeTweets(tweets, verbose: true)

print("Total Sentiment: \(String(format: "%.0f", score * 100))%")

func analyzeTweet(_ tweet: Tweet) -> Double {
    let tagger = NLTagger(tagSchemes: [.tokenType, .sentimentScore, .nameType])

    tagger.string = tweet.text

    var scores: [Double] = []

    tagger.enumerateTags(in: tweet.text.startIndex ..< tweet.text.endIndex, unit: .paragraph,
                         scheme: .sentimentScore, options: []) { sentiment, _ in
        
        if let sentimentScore = sentiment {
            scores.append(Double(sentimentScore.rawValue)!)
        }
        
        return true
    }

    return scores.average
}

func analyzeTweets(_ tweets: [Tweet], verbose: Bool = false) -> Double {
    var scores: [Double] = []

    for tweet in tweets {
        scores.append(analyzeTweet(tweet))
        if verbose {
            print("Tweet: ".green
                    + "\(tweet.text)".lightBlue
                    + "\nSentiment: ".green
                    + "\(String(format: "%.0f", scores.last! * 100))%".red)
        }
    }

    return scores.average
}
