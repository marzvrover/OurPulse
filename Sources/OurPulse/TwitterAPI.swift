import Foundation
import SwiftyJSON

enum TwitterAuthorizationType {
    case BearerToken
}

struct Tweet {
    var id: String
    var text: String
}

struct TwitterAPI {
    static let api_url = "https://api.twitter.com/2/"
    static var authorization_type: TwitterAuthorizationType = TwitterAuthorizationType.BearerToken
    static var authorization_secrets: [String: String] = [:]

    static func search(query: String,
                max_results: Int = 10,
                expansions: [String]? = nil,
                tweetFields: [String]? = nil,
                userFields: [String]? = nil) -> [Tweet]?
    {
        let search_url = TwitterAPI.api_url + "tweets/search/recent"

        var url_parts = URLComponents.init(string: search_url)!

        url_parts.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "max_results", value: String(max_results)),
        ]

        if expansions != nil {
            url_parts.queryItems?.append(URLQueryItem(name: "expansions",
                                                      value: expansions!.joined(separator: ",")))
        }

        if tweetFields != nil {
            url_parts.queryItems?.append(URLQueryItem(name: "tweet.fields",
                                                      value: tweetFields!.joined(separator: ",")))
        }

        if userFields != nil {
            url_parts.queryItems?.append(URLQueryItem(name: "user.fields",
                                                      value: userFields!.joined(separator: ",")))
        }

        let sem = DispatchSemaphore.init(value: 0)

        var data: Data?
        var response: URLResponse?
        var error: Error?

        TwitterAPI.fetchPoll(url: url_parts.url!) { localData, localResponse, localError in
            defer {
                sem.signal()
            }
            data = localData
            response = localResponse
            error = localError
        }

        sem.wait()

        guard error == nil else {
            dump(error)
            dump(response)
            return nil
        }

        do {
            var tweets: [Tweet] = []

            let json = try JSON(data: data!)

            for (_, item) in json["data"] {
                tweets.append(Tweet(id: item["id"].string!, text: item["text"].string!))
            }

            return tweets
        } catch {
            return nil
        }
    }

    static func fetchPoll(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let config = URLSessionConfiguration.default

        switch authorization_type {
            case .BearerToken:
                let auth_value = "Bearer \(authorization_secrets["bearer_token"]!)"
                config.httpAdditionalHeaders = ["Authorization": auth_value]
        }
        
        let session: URLSession = URLSession(configuration: config)
        
        let task = session.dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
}
