//
//  TaskCell.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/05.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell, InstantiatableFromNib {
    @IBOutlet private weak var taskNameView: UITextView!
    @IBOutlet private weak var taskDetailButton: UIButton!
    @IBAction private func tappedTaskDetailButton(_ sender: UIButton) {

    }
    var index: Int!
    var textViewDelegate: UITextViewDelegate? {
        didSet {
            guard let textViewDelegate = textViewDelegate else { return }
            taskNameView.delegate = textViewDelegate
        }
    }
    weak var dataSource: TaskCellDataSource? {
        didSet {
            setLayout()
        }
    }

    private func setLayout() {
        guard let taskList = dataSource?.taskList else { return }
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.taskNameView.text = taskList.tasks[weakSelf.index].title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

protocol TaskCellDataSource: AnyObject {
    var taskList: TaskList? { get set }
}
protocol TaskCellDelegate: AnyObject {

}
