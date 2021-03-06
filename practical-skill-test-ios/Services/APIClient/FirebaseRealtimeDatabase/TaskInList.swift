//
//  TaskData.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/03.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation
struct TaskInList: Codable, APIClientProtocol {
    typealias AssociatedType = [String: TaskInList]?
    static func jsonDecode(data: Data) throws -> AssociatedType {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .useDefaultKeys
        do {
            let result = try jsonDecoder.decode(AssociatedType.self, from: data)
            return result
        } catch DecodingError.dataCorrupted(_) {
            return nil
        }
    }

    static func createParams(title: String, description: String, createdAt: String?, updatedAt: String) -> Data? {
        var hash = [
            "title": title,
            "description": description,
            "updatedAt": updatedAt
        ]
        if let createdAt = createdAt {
            hash["createdAt"] = createdAt
        }
        let params = try? JSONSerialization.data(withJSONObject: hash, options: .prettyPrinted)
        return params
    }

    var title: String
    var description: String
    var createdAt: String
    var updatedAt: String
}

struct TaskList {
    var tasks: [Task]
    mutating func change(of taskId: String, to task: UpdatedTask) -> Int? {
        guard let index = (tasks.map { $0.id }).firstIndex(of: taskId) else { return nil }
        let updatedTask = Task(
            id: tasks[index].id,
            title: task.title ?? tasks[index].title,
            description: task.description ?? tasks[index].description,
            createdAt: tasks[index].createdAt,
            updatedAt: task.updatedAt
        )
        tasks[index] = updatedTask
        return index
    }

    mutating func delete(of taskID: String) -> Int? {
        guard let index = (tasks.map { $0.id }).firstIndex(of: taskID) else { return nil }
        tasks.remove(at: index)
        return index
    }

    struct Task: Equatable {
        var id: String
        var title: String
        var description: String
        var createdAt: String
        var updatedAt: String
    }

    /// TaskのorderはFirabase Realtime DatebaseのJSONの仕様上順番が保証されない。
    /// そのためcreatedAtをDateに変換してsort
    init(data: [String: TaskInList]?) {
        guard let data = data else {
            tasks = []
            return
        }
        tasks = data.map { Task(id: $0.key, title: $0.value.title, description: $0.value.description, createdAt: $0.value.createdAt, updatedAt: $0.value.updatedAt) }
        let formatter = DateFormatter()
        tasks = tasks.sorted(by: {formatter.dateByDefaultLocale(from: $0.createdAt)! < formatter.dateByDefaultLocale(from: $1.createdAt)!})
    }
}
