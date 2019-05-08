//
//  HomeModel.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/04.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation
import UIKit

class HomeModel: NSObject, TaskManagible {
    var taskList: TaskList?
    var firebaseDBClient = FirebaseDBClient()
    weak var textFieldDelegate: UITextFieldDelegate?
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
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: FormCell.nibName, for: indexPath) as! FormCell
            cell.textFieldDelegate = textFieldDelegate

            return cell
        default:
            return UITableViewCell()
        }
    }
}
