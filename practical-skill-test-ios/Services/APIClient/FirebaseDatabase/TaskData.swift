//
//  TaskData.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/03.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation
struct TaskData: Codable, APIClientDelegate {
    typealias AssociatedType = [String: TaskData]
    static func jsonDecode(data: Data) throws -> [String: TaskData] {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .useDefaultKeys
        let result = try JSONDecoder().decode([String: TaskData].self, from: data)
        return result
    }
    
    var title: String
    var description: String
    var createdAt: String
    var updatedAt: String
}

struct TaskList {
    var tasks: [Task]
    struct Task {
        var id: String
        var title: String
        var description: String
        var createdAt: String
        var updatedAt: String
    }
    
    
    /// TaskのorderはFirabase Realtime Datebaseの仕様上順番が保証されない。
    /// そのためupdateAtをDateに変換してsort
    /// - TODO: ソートの際にforced unwrappingしているので適切にエラー処理
    init(data: [String: TaskData]) {
        tasks = data.map { Task(id: $0.key, title: $0.value.title, description: $0.value.description, createdAt: $0.value.createdAt, updatedAt: $0.value.updatedAt)}
        let f = DateFormatter()
        tasks = tasks.sorted(by: {f.dateByDefaultLocale(from:$0.updatedAt)! < f.dateByDefaultLocale(from: $1.updatedAt)!} )
    }
}
