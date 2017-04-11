//
//  Photo.swift
//  PxChallenge
//
//  Created by Paul Floussov on 2017-04-10.
//  Copyright © 2017 Paul Floussov. All rights reserved.
//

import Foundation
import ObjectMapper

struct Photo: Mappable {
    
    var id: Int!
    var name: String!
    var imageUrl: String!
    
    // MARK: JSON
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        id            <- map["id"]
        name          <- map["name"]
        imageUrl      <- map["image_url"]
    }
    
}
