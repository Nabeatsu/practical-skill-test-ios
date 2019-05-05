//
//  TaskId.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/03.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation

struct TaskId: Codable, APIClientProtocol {
    typealias AssociatedType = TaskId
    static func jsonDecode(data: Data) throws -> AssociatedType {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .useDefaultKeys
        do {
            let result = try jsonDecoder.decode(AssociatedType.self, from: data)
            return result
        }
    }

    var name: String
}
