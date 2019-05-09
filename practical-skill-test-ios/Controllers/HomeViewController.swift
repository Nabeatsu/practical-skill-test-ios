//
//  HomeViewController.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/02.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak internal var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.estimatedRowHeight = 1000
            tableView.rowHeight = UITableView.automaticDimension
            tableView.dataSource = dataSource
            tableView.register(UINib(nibName: TaskCell.nibName, bundle: nil), forCellReuseIdentifier: TaskCell.nibName)
            tableView.register(UINib(nibName: FormCell.nibName, bundle: nil), forCellReuseIdentifier: FormCell.nibName)
        }
    }

    var editingField: UITextField?
    var dataSource = HomeModel()
    let authClient = AuthClient()
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.textFieldDelegate = self
        loadTasks()
    }

    private func getErrorCompletion(title: String) -> (String) -> Void {
        let showError: (String) -> Void = { [weak self] errorMessage in
            guard let weakSelf = self else { return }
            let alert = UIAlertController(title: title, message: "\(errorMessage)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
            weakSelf.present(alert, animated: true, completion: nil)
        }
        return showError
    }

    private func loadTasks() {
        let completionHandler: ([String: TaskInList]?) -> Void = { [weak self] result in
            guard let weakSelf = self else { return }
            weakSelf.dataSource.taskList = TaskList(data: result)
            DispatchQueue.main.async {
                weakSelf.tableView.reloadData()
            }
        }
        dataSource.loadTasks(completionHandler, getErrorCompletion(title: "cannnot create the task"))
    }

    private func createTask(title: String, description: String) {
        let completionHandler: (TaskList.Task) -> Void = { [weak self] task in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async {
                weakSelf.editingField?.text = ""
                weakSelf.tableView.beginUpdates()
                let latRowIndex = weakSelf.tableView.numberOfRows(inSection: 0)
                let indexPath = IndexPath(row: latRowIndex, section: 0)
                weakSelf.tableView.insertRows(at: [indexPath], with: .automatic)
                weakSelf.dataSource.taskList?.tasks.append(task)
                weakSelf.tableView.endUpdates()
                weakSelf.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        dataSource.createTask(
            title: title,
            description: description,
            completionHandler: completionHandler,
            errorCompletion: getErrorCompletion(title: "cannnot load the tasklist")
        )
    }

    private func deleteTask(id: String) {
        let completionHandler: () -> Void = { [weak self] in
            guard let weakSelf = self else { return }
            guard let index = weakSelf.dataSource.taskList?.delete(of: id) else { return }
            let indexPath = IndexPath(row: index, section: 0)
            DispatchQueue.main.async {
                weakSelf.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }

        dataSource.deleteTask(id: id, completionHandler: completionHandler, errorCompletion: getErrorCompletion(title: "cannnot delete the task"))
    }

    private func updateTask(id: String, title: String?, description: String?) {
        let completionHandler: (UpdatedTask) -> Void = { [weak self] result in
            guard let weakSelf = self else { return }
            guard let index = weakSelf.dataSource.taskList?.change(of: id, to: result) else { return }
            let indexPath = IndexPath(row: index, section: 0)
            DispatchQueue.main.async {
                weakSelf.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }

        dataSource.updateTask(id: id, title: title, description: description, completionHandler: completionHandler, errorCompletion: getErrorCompletion(title: "cannot update the task"))
    }
}

extension HomeViewController: UITextFieldDelegate {
    override func viewWillAppear(_ animated: Bool) {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(HomeViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(HomeViewController.keyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboard = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboard.height, right: 0)
        let indexPath = IndexPath(row: 0, section: 1)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    @objc func keyboardDidHide(_ notification: Notification) {
        tableView.contentInset = UIEdgeInsets.zero
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        editingField = nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.trimmingCharacters(in: .whitespaces) != "" else {
            textField.resignFirstResponder()
            textField.text = nil
            return true
        }
        textField.text = nil
        createTask(title: text, description: "")
        textField.resignFirstResponder()
        return true
    }

}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let closeAction = UIContextualAction(style: .destructive, title: "完了") {[weak self] (_, _, success) in
            guard let weakSelf = self else { return }
            guard let id = weakSelf.dataSource.taskList?.tasks[indexPath.row].id else { return }
            weakSelf.deleteTask(id: id)
            success(true)
        }
        closeAction.backgroundColor = .blue
        return UISwipeActionsConfiguration(actions: [closeAction])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let detailAction = UIContextualAction(style: .normal, title: "変更") { [weak self] (_, _, success) in
            guard let weakSelf = self,
                let storyboard = weakSelf.storyboard else { return }
            let vcName: VCList = .detail
            guard let nextVC = storyboard.instantiateViewController(withIdentifier: vcName.rawValue) as? DetailViewController else {
                fatalError("cannot initialize. storyboard ID and VCList's rawValue may not match")
            }
            nextVC.dataSource.task = weakSelf.dataSource.taskList?.tasks[indexPath.row]
            nextVC.delegate = self
            weakSelf.present(nextVC, animated: true)

            success(true)
        }
        detailAction.backgroundColor = .purple
        return UISwipeActionsConfiguration(actions: [detailAction])
    }
}

extension HomeViewController: HomeAndDetailSyncDelegate {}
