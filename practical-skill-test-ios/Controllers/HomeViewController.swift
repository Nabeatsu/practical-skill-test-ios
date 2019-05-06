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

    func createTask(title: String, description: String) {
        let showError: (String) -> Void = { [weak self] errorMessage in
            guard let weakSelf = self else { return }
            let alert = UIAlertController(title: "タスク作成失敗", message: "\(errorMessage)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
            weakSelf.present(alert, animated: true, completion: nil)
        }

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
            errorCompletion: showError
        )
    }

    private func loadTasks() {
        let showError: (String) -> Void = { [weak self] errorMessage in
            guard let weakSelf = self else { return }
            let alert = UIAlertController(title: "ロード失敗", message: "\(errorMessage)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
            weakSelf.present(alert, animated: true, completion: nil)
        }

        let completionHandler: ([String: TaskData]?) -> Void = { [weak self] result in
            guard let weakSelf = self else { return }
            weakSelf.dataSource.taskList = TaskList(data: result)
            DispatchQueue.main.async {
                weakSelf.tableView.reloadData()
            }
        }
        dataSource.loadTasks(completionHandler, showError)
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
