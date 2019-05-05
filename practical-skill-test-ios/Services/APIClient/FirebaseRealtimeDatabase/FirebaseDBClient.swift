//
//  RESTClient.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/06.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation

struct FirebaseDBClient {
    func get(completion: @escaping(GetAPIResponse) -> Void) {
        guard let uid = AuthClient.currentUser?.uid else {
            fatalError("cannot get uid")
        }
        TaskData.fetch(
            method: .get,
            apiPath: "https://practical-skill-test-ios.firebaseio.com/tasks/\(uid).json?print=pretty") { errorOrResult in
                completion(errorOrResult)
        }
    }
    func post(title: String, description: String, completion: @escaping(PostAPIResponse) -> Void) {
        let now = Date()
        let formatter = DateFormatter()
        guard let dateString = formatter.stringByDefaultLocale(from: now) else { fatalError("Logic Error") }
        guard let params = TaskData.createParams(title: title, description: description, createdAt: dateString, updatedAt: dateString) else { return }
        guard let uid = AuthClient.currentUser?.uid else {
            fatalError("cannot get uid")
        }
        TaskId.fetch(
            method: .post(payload: params),
            apiPath: "https://practical-skill-test-ios.firebaseio.com/tasks/\(uid).json") { errorOrResult in
                completion(errorOrResult)
        }
    }

    /// - TODO: 未実装
    func putch(data: Data?, completion: @escaping(GetAPIResponse) -> Void) {

    }

    /// - TODO: 未実装
    func delete(data: Data?, completion: @escaping(GetAPIResponse) -> Void) {

    }
}
