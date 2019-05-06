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
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.textViewDelegate = self
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
        dataSource.loadTasks(completionHandler, getErrorCompletion(title: "cannnot create task"))
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

    private func updateTask(index: Int, id: String, title: String?, description: String?) {
        let completionHandler: (UpdatedTask) -> Void = { [weak self] result in
            guard let weakSelf = self else { return }
            weakSelf.dataSource.taskList?.change(of: id, to: result)
            let indexPath = IndexPath(row: index, section: 0)
            DispatchQueue.main.async {
                weakSelf.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }

        dataSource.updateTask(id: id, title: title, description: description, completionHandler: completionHandler, errorCompletion: getErrorCompletion(title: "cannot update task"))
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
        // ここで追加
        guard let text = textView.text, text != "" else { return true }
        if let index = (textView.superview?.superview as? TaskCell)?.index {
            guard let id = dataSource.taskList?.tasks[index].id else { return true }
            updateTask(index: index, id: id, title: textView.text, description: nil)
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
}
