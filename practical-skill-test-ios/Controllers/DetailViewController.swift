//
//  TaskDetailViewController.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/08.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var titleLabel: UILabel!

    @IBOutlet weak private var descriptionTextView: UITextView!
    var editingView: UITextView?
    var dataSource = DetailModel()
    weak var delegate: HomeAndDetailSyncDelegate?
    var lastOffset: CGPoint?
    var overlap: CGFloat = 0.0
    var moveYC: CGFloat = 0.0
    var lastOffsetY: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.delegate = self
        setLayout()
        // Do any additional setup after loading the view.
    }

    func setLayout() {
        titleLabel.text = dataSource.task.title
        descriptionTextView.text = dataSource.task.description
    }
    @IBAction func tappedCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

    deinit {
        #if DEBUG
        print("called deinit: \(self)")
        #endif
    }

    private func updateTask(id: String, title: String?, description: String?) {
        let completionHandler: (UpdatedTask) -> Void = { [weak self] result in
            guard let weakSelf = self else { return }
            weakSelf.dataSource.task = TaskList.Task(
                id: weakSelf.dataSource.task.id,
                title: result.title ?? weakSelf.dataSource.task.title,
                description: result.description ?? weakSelf.dataSource.task.description,
                createdAt: weakSelf.dataSource.task.createdAt,
                updatedAt: result.updatedAt)
            DispatchQueue.main.async {
                weakSelf.setLayout()
            }
            guard let delegate = weakSelf.delegate else { return }
            delegate.sync(of: weakSelf.dataSource.task.id, to: result)
        }
        dataSource.updateTask(id: id, title: title, description: description, completionHandler: completionHandler, errorCompletion: getErrorCompletion(title: "cannot update the task"))
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

}

extension DetailViewController: UITextViewDelegate {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(self.keyboardChangeFrame(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        notification.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardChangeFrame(_ notification: Notification) {
    }

    @objc func keyboardWillShow(_ notification: Notification) {
    }

    @objc func keyboardDidHide(_ notification: Notification) {
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        editingView = textView
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        editingView = textView
        lastOffset = scrollView.contentOffset
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        editingView = nil
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        guard let text = textView.text, text != "" else { return true }
        updateTask(id: dataSource.task.id, title: titleLabel.text, description: descriptionTextView.text)
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}

/// HomeViewController と DetailViewControllerの間でタスクのデータの同期を行う
protocol HomeAndDetailSyncDelegate: AnyObject {
    var tableView: UITableView! { get set }
    func sync(of taskId: String, to task: UpdatedTask)
}

extension HomeAndDetailSyncDelegate where Self: HomeViewController {
    func sync(of taskId: String, to task: UpdatedTask) {
        guard let index = dataSource.taskList?.change(of: taskId, to: task) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
