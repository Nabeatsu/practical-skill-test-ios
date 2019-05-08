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
    var textViewDelegate: UITextViewDelegate? {
        didSet {
            guard let textViewDelegate = textViewDelegate else { return }
            taskNameView.delegate = textViewDelegate
        }
    }

    var task: TaskList.Task? {
        didSet {
            guard let task = task else { return }
            setLayout(task)
        }
    }

    private func setLayout(_ task: TaskList.Task) {
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.taskNameView.text = task.title
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

protocol TaskCellDelegate: AnyObject {

}
