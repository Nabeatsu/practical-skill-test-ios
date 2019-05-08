//
//  HomeModel.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/04.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation
import UIKit

class HomeModel: NSObject {
    var taskList: TaskList?
    var firebaseDBClient = FirebaseDBClient()
    weak var textViewDelegate: UITextViewDelegate?

    /// - TODO: この部分も切り出せる. protocolに
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

    func deleteTask(id: String, completionHandler: @escaping(Int) -> Void, errorCompletion: @escaping (String) -> Void) {
        firebaseDBClient.delete(id: id) { [weak self] errorOrResult in
            guard let weakSelf = self else { return }
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
                guard let index = weakSelf.taskList?.delete(of: id) else { return }
                completionHandler(index)
            }
        }
    }
}

extension HomeModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section != 1 else { return 1 }
        guard let list = taskList?.tasks else { return 0 }
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let taskList = taskList, !taskList.tasks.isEmpty else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.nibName, for: indexPath) as! TaskCell
            cell.task = taskList.tasks[indexPath.row]
            cell.textViewDelegate = textViewDelegate
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: FormCell.nibName, for: indexPath) as! FormCell
            cell.textViewDelegate = textViewDelegate
            return cell
        default:
            return UITableViewCell()
        }
    }
}
