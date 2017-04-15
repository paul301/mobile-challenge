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
    var images: [Image]!
    var width: Int!
    var height: Int!
    
    
    // MARK: JSON
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        images      <- map["images"]
        width       <- map["width"]
        height      <- map["height"]
    }
    
}
