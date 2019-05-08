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
            tableView.estimatedRowHeight = 100
            tableView.rowHeight = UITableView.automaticDimension
            tableView.dataSource = dataSource
            tableView.register(UINib(nibName: TaskCell.nibName, bundle: nil), forCellReuseIdentifier: TaskCell.nibName)
            tableView.register(UINib(nibName: FormCell.nibName, bundle: nil), forCellReuseIdentifier: FormCell.nibName)
        }
    }

    var editingView: UITextView?
    var dataSource = HomeModel()
    let authClient = AuthClient()
    var refreshControl: UIRefreshControl!
    let semaphore = DispatchSemaphore(value: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "再読込")
        refreshControl.addTarget(self, action: #selector(HomeViewController.refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        dataSource.textViewDelegate = self
        loadTasks()
    }

    @objc func refresh() {
        dataSource.taskList = nil
        refreshControl.beginRefreshing()
        DispatchQueue.global().async {
            self.loadTasks()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.semaphore.signal()
            }
        }
        semaphore.wait()
        semaphore.signal()
        refreshControl.endRefreshing()
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
                weakSelf.editingView?.text = ""
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

extension HomeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        editingView = textView
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        editingView = nil
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        guard let text = textView.text, text != "" else { return true }
        if let id = (textView.superview?.superview as? TaskCell)?.task?.id {
            updateTask(id: id, title: textView.text, description: nil)
            return true
        }
        textView.text = ""
        createTask(title: text, description: "")

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        UIView.setAnimationsEnabled(false)
        textView.sizeToFit()
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
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
        let detailAction = UIContextualAction(style: .normal, title: "詳細") { [weak self] (_, _, success) in
            guard let weakSelf = self,
                let storyboard = weakSelf.storyboard else { return }
            let nextVC = storyboard.instantiateViewController(withIdentifier: "Detail") as! TaskDetailViewController
            nextVC.task = weakSelf.dataSource.taskList?.tasks[indexPath.row]
            weakSelf.present(nextVC, animated: true)

            success(true)
        }
        detailAction.backgroundColor = .purple
        return UISwipeActionsConfiguration(actions: [detailAction])
    }
}
