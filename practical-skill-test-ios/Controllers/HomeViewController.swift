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
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.request(method: .get) { [weak self] errorOrResult in
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
