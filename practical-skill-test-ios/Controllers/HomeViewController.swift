//
//  HomeViewController.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/02.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.estimatedRowHeight = 1000
            tableView.rowHeight = UITableView.automaticDimension
            tableView.dataSource = dataSource
            tableView.register(UINib(nibName: TaskCell.nibName, bundle: nil), forCellReuseIdentifier: TaskCell.nibName)
        }
    }

    var dataSource = HomeModel()
    let authClient = AuthClient()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTasks()
    }

    private func createTask(title: String, description: String) {
        dataSource.firebaseDBClient.post(title: title, description: description) { [weak self] errorOrResult in
            guard let _ = self else { return }
            switch errorOrResult {
            case let .left(error):
                switch error {
                case let .left(connectionError):
                    fatalError("\(connectionError)")
                case let .right(transformError):
                    fatalError("\(transformError)")
                }
            case let .right(result):
                print("中身: \(String(describing: result))")
            }
        }
    }

    private func loadTasks() {
        dataSource.firebaseDBClient.get { [weak self] errorOrResult in
            guard let weakSelf = self else { return }

            switch errorOrResult {
            case let .left(error):
                print("error: \(error)")
                switch error {
                case let .left(connectionError):
                    let alert = UIAlertController(title: "コネクションエラー", message: "\(connectionError)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
                    weakSelf.present(alert, animated: true)
                case let .right(transformError):
                    let alert = UIAlertController(title: "トランスフォームエラー", message: "\(transformError)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
                    weakSelf.present(alert, animated: true)
                }
            case let .right(result):
                weakSelf.dataSource.taskList = TaskList(data: result)
            }
            DispatchQueue.main.async {
                weakSelf.tableView.reloadData()
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate {

}
