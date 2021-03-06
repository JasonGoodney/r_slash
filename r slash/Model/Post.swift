//
//  Post.swift
//  r slash
//
//  Created by Jason Goodney on 9/4/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import Foundation

struct Post: Decodable, Equatable {
    let title: String
    let thumbnailEndpoint: String
    let numberOfUpvotes: Int
    let numberOfComments: Int
    let permalink: String
    
    private enum CodingKeys: String, CodingKey {
        case title
        case permalink
        case thumbnailEndpoint = "thumbnail"
        case numberOfUpvotes = "ups"
        case numberOfComments = "num_comments"
    }
}

struct JSONDictionary: Decodable {
    let data: DataDictionary
    
    struct DataDictionary: Decodable {
        let children: [PostDictionary]
        let nextPage: String?
        let prevPage: String?
        
        private enum CodingKeys: String, CodingKey {
            case children
            case nextPage = "after"
            case prevPage = "before"
        }
        
        struct PostDictionary: Decodable {
            let post: Post
            
            private enum CodingKeys: String, CodingKey {
                case post = "data"
            }
        }
    }
}
