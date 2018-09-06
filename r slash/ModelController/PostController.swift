//
//  PostController.swift
//  r slash
//
//  Created by Jason Goodney on 9/4/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

// TODO: - Keep current page for refreshing

class PostController {
    
    static let shared = PostController() ; private init() {}
    
    var posts: [Post]?
    var nextPage: (name: String, value: String)?
    var currentPage: (name: String, value: String)?
    var prevPage: (name: String, value: String)?
    var count = 0
    
    func fetchPosts(by subreddit: String, page: (name: String, value: String)?, completion: @escaping ([Post]?, Error?) -> Void) {

        guard let baseURL = URL(string: RedditURL.baseString) else { return }
        let subredditURL: URL = baseURL.appendingPathComponent("r").appendingPathComponent(subreddit)
        var components: URLComponents?
        let countQueryitem = URLQueryItem(name: "count", value: "\(count)")
        
        if let page = page {
            let pageQueryItem = URLQueryItem(name: page.name, value: page.value)
            components = URLComponents(url: subredditURL, resolvingAgainstBaseURL: true)
            components?.queryItems = [countQueryitem, pageQueryItem]
        }
        
        var jsonURL: URL
        
        if let pageURL = components?.url {
            jsonURL = pageURL.appendingPathExtension("json")
            
        } else {
            jsonURL = subredditURL.appendingPathExtension("json")
            
        }
        
        URLSession.shared.dataTask(with: jsonURL) { (data, _, error) in

            do {
                if let error =  error { throw error }
                guard let data = data else { throw NSError() }
                
                let jsonDictionary = try JSONDecoder().decode(JSONDictionary.self, from: data)
                
                if let nextPage = jsonDictionary.data.nextPage {
                    self.nextPage = (name: "after", value: nextPage)
                }
                
                if let prevPage = jsonDictionary.data.prevPage {
                    self.prevPage = (name: "before", value: prevPage)
                }
                
                self.posts = jsonDictionary.data.children.compactMap({ $0.post })

                completion(self.posts, nil)
                
            } catch let error {
                print("😳\nThere was an error in \(#function): \(error)\n\n\(error.localizedDescription)\n👿")
                completion(nil, error)
            }
        }.resume()
    }
    
    func fetchImage(at urlString: String, completion: @escaping (UIImage?, Error?) -> Void) {
        guard let imageURL = URL(string: urlString) else { return }
                
        URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
            
            do {
                if let error = error { throw error }
                guard let data = data,
                    let image = UIImage(data: data) else { throw NSError() }
                
                completion(image, nil)
            } catch let error {
                print("😳\nThere was an error in \(#function): \(error)\n\n\(error.localizedDescription)\n👿")
                completion(nil, error)
            }            
        }.resume()
    }
}

















