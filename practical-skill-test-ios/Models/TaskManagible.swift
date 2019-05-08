//
//  TaskManagible.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/08.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation
protocol TaskManagible: TaskCreatable & TaskUpdatable & TaskLoadable & TaskDeletable {
}

protocol FirebaseDBClientHaving {
    var firebaseDBClient: FirebaseDBClient { get set }
}

protocol TaskCreatable: FirebaseDBClientHaving {
    func createTask(title: String, description: String, completionHandler: @escaping (TaskList.Task) -> Void, errorCompletion: @escaping (String) -> Void)
}

extension TaskCreatable where Self: NSObject {
    func createTask(title: String, description: String, completionHandler: @escaping (TaskList.Task) -> Void, errorCompletion: @escaping (String) -> Void) {
        firebaseDBClient.post(title: title, description: description) { [weak self] errorOrResult in
            guard let weakSelf = self else { return }
            switch errorOrResult {
            case let .left(error):
                switch error {
                case let .left(connectionError):
                    errorCompletion("connectionError: \(connectionError)")
                case let .right(transformError):
                    errorCompletion("transformError: \(transformError)")
                }
            case let .right(result):
                guard let timeStamp = weakSelf.firebaseDBClient.timeStamp else { return }
                let task = TaskList.Task(id: result.name, title: title, description: description, createdAt: timeStamp, updatedAt: timeStamp)
                DispatchQueue.main.async {
                    completionHandler(task)
                }
            }
        }
    }
}

protocol TaskUpdatable: FirebaseDBClientHaving {
    func updateTask(id: String, title: String?, description: String?, completionHandler: @escaping(UpdatedTask) -> Void, errorCompletion: @escaping (String) -> Void)
}

extension TaskUpdatable where Self: NSObject {
    func updateTask(id: String, title: String?, description: String?, completionHandler: @escaping(UpdatedTask) -> Void, errorCompletion: @escaping (String) -> Void) {
        firebaseDBClient.patch(id: id, title: title, description: description) { errorOrResult in
            switch errorOrResult {
            case let .left(error):
                switch error {
                case let .left(connectionError):
                    errorCompletion("connectionError: \(connectionError)")
                case let .right(transformError):
                    errorCompletion("transformError: \(transformError)")
                }
            case let .right(result):
                completionHandler(result)
            }
        }
    }
}

protocol TaskLoadable: FirebaseDBClientHaving {
    func loadTasks(_ completionHandler: @escaping ([String: TaskInList]?) -> Void, _ errorCompletion: @escaping (String) -> Void)
}

extension TaskLoadable where Self: NSObject {
    func loadTasks(_ completionHandler: @escaping ([String: TaskInList]?) -> Void, _ errorCompletion: @escaping (String) -> Void) {
        firebaseDBClient.get {errorOrResult in
            switch errorOrResult {
            case let .left(error):
                print("error: \(error)")
                switch error {
                case let .left(connectionError):
                    errorCompletion("connectionError: \(connectionError)")
                case let .right(transformError):
                    errorCompletion("connectionError: \(transformError)")
                }
            case let .right(result):
                completionHandler(result)
            }
        }
    }
}

protocol TaskDeletable: FirebaseDBClientHaving {
    func deleteTask(id: String, completionHandler: @escaping() -> Void, errorCompletion: @escaping (String) -> Void)
}

extension TaskDeletable where Self: NSObject {
    func deleteTask(id: String, completionHandler: @escaping() -> Void, errorCompletion: @escaping (String) -> Void) {
        firebaseDBClient.delete(id: id) { errorOrResult in
            switch errorOrResult {
            case let .left(error):
                switch error {
                case let .left(connectionError):
                    errorCompletion("connectionError: \(connectionError)")
                case let .right(transformError):
                    switch transformError {
                    case .noContent:

                        errorCompletion("想定していないエラー no content)")
                    case .malformedData(let debugInfo):
                        errorCompletion("想定していないエラー debugInfo: \(debugInfo)")
                    case .unexpectedStatusCode(let debugInfo):
                        errorCompletion("想定していないエラー。debugInfo: \(debugInfo)")
                    }

                }
            case let .right(result):
                if let result = result {
                    errorCompletion("不明なレスポンス\(String(describing: result))")
                    return
                }
                completionHandler()
            }
        }
    }
}
