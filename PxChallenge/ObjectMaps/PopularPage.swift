//
//  PopularPage.swift
//  PxChallenge
//
//  Created by Paul Floussov on 2017-04-10.
//  Copyright © 2017 Paul Floussov. All rights reserved.
//

import Foundation
import ObjectMapper

struct PopularPage: Mappable {
    
    var currentPage: Int!
    var totalPages: Int!
    var photos: [Photo]!
    
    // MARK: JSON
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        currentPage   <- map["current_page"]
        totalPages    <- map["total_pages"]
        photos        <- map["photos"]
    }
    
}
