//
//  PxAPI.swift
//  Challenge
//
//  Created by Paul Floussov on 2017-04-05.
//  Copyright © 2017 Paul Floussov. All rights reserved.
//

import Foundation
import Moya

let pxProvider = RxMoyaProvider<FiveHundredPx>(plugins: [NetworkLoggerPlugin()])

public enum FiveHundredPx {
    case popularPhotos()
}

extension FiveHundredPx: TargetType {
    public var baseURL: URL { return URL(string: "https://api.500px.com")! }
    
    public var path: String {
        switch self {
        case .popularPhotos():
            return "/v1/photos"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .popularPhotos:
            return .get
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .popularPhotos():
            return ["consumer_key": "w9pJJi1BUapVhDWXZz8PXVF2ynjKEbyfy38waDGM",
                    "exclude":"nude",
                    "image_size":"6,21"]
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    public var task: Task {
        switch self {
        case .popularPhotos:
            return .request
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .popularPhotos:
            return "{}".data(using: String.Encoding.utf8)!
        }
    }
}
