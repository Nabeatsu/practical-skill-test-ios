//
//  UpdatedTask.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/07.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation
struct UpdatedTask: Codable, APIClientProtocol, Equatable {
    typealias AssociatedType = UpdatedTask
    static func jsonDecode(data: Data) throws -> AssociatedType {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .useDefaultKeys
        do {
            let result = try jsonDecoder.decode(AssociatedType.self, from: data)
            return result
        }
    }

    static func createParams(title: String?, description: String?, updatedAt: String) -> Data? {
        var hash = [
            "updatedAt": updatedAt
        ]
        if let title = title, title != "" {
            hash["title"] = title
        }

        if let description = description, description != "" {
            hash["description"] = description
        }
        let params = try? JSONSerialization.data(withJSONObject: hash, options: .prettyPrinted)
        return params
    }
    var title: String?
    var description: String?
    var updatedAt: String
}
