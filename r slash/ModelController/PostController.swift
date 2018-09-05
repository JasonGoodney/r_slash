//
//  PostController.swift
//  r slash
//
//  Created by Jason Goodney on 9/4/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

class PostController {
    
    static let shared = PostController(); private init() {}
    
    var posts: [Post]?
    
    func fetchPosts(by subreddit: String,  completion: @escaping ([Post]?, Error?) -> Void) {
        
        guard let baseURL = URL(string: RedditURL.baseString) else { return }
        let subredditURL = baseURL.appendingPathComponent("r").appendingPathComponent(subreddit)
        let subredditJSONURL = subredditURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: subredditJSONURL) { (data, _, error) in

            do {
                if let error =  error { throw error }
                guard let data = data else { throw NSError() }
                
                let jsonDictionary = try JSONDecoder().decode(JSONDictionary.self, from: data)
                
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

















