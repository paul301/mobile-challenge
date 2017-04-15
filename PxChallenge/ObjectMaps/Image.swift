//
//  Image.swift
//  PxChallenge
//
//  Created by Paul Floussov on 2017-04-13.
//  Copyright © 2017 Paul Floussov. All rights reserved.
//

import Foundation
import ObjectMapper

struct Image: Mappable {
    
    var size: Int!
    var url: String!
    
    // MARK: JSON
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        size  <- map["size"]
        url   <- map["https_url"]
    }
}
