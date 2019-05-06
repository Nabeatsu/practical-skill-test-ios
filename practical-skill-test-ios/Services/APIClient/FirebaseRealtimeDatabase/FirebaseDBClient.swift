//
//  RESTClient.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/06.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation

class FirebaseDBClient {
    var timeStamp: String?
    func get(completion: @escaping(GetAPIResponse) -> Void) {
        guard let uid = AuthClient.currentUser?.uid else {
            fatalError("cannot get uid")
        }
        TaskInList.fetch(
            method: .get,
            apiPath: "https://practical-skill-test-ios.firebaseio.com/tasks/\(uid).json?print=pretty") { errorOrResult in
                completion(errorOrResult)
        }
    }
    func post(title: String, description: String, completion: @escaping(PostAPIResponse) -> Void) {
        let now = Date()
        let formatter = DateFormatter()
        guard let dateString = formatter.stringByDefaultLocale(from: now) else { fatalError("can not convert: Logic Failure") }
        timeStamp = dateString
        guard let params = TaskInList.createParams(title: title, description: description, createdAt: dateString, updatedAt: dateString) else { return }
        guard let uid = AuthClient.currentUser?.uid else {
            fatalError("cannot get uid")
        }

        TaskId.fetch(
            method: .post(payload: params),
            apiPath: "https://practical-skill-test-ios.firebaseio.com/tasks/\(uid).json") { errorOrResult in
                completion(errorOrResult)
        }
    }

    func patch(id: String, title: String?, description: String?, completion: @escaping(PatchAPIResponse) -> Void) {
        let now = Date()
        let formatter = DateFormatter()
        guard let dateString = formatter.stringByDefaultLocale(from: now) else { fatalError("can not convert: Logic Failure") }
        guard let params = UpdatedTask.createParams(title: title, description: description, updatedAt: dateString) else { return }
        guard let uid = AuthClient.currentUser?.uid else {
            fatalError("cannnot get uid: Logic Failure")
        }
        UpdatedTask.fetch(
            method: .patch(payload: params),
            apiPath: "https://practical-skill-test-ios.firebaseio.com/tasks/\(uid)/\(id).json") { errorResult in
                completion(errorResult)
        }
    }

    /// - TODO: 未実装
    func delete(data: Data?, completion: @escaping(GetAPIResponse) -> Void) {

    }
}
