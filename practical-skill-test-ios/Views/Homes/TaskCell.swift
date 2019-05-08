//
//  TaskCell.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/05.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell, InstantiatableFromNib {
    @IBOutlet private weak var taskNameLabel: UILabel!
    var task: TaskList.Task? {
        didSet {
            guard let task = task else { return }
            setLayout(task)
        }
    }

    private func setLayout(_ task: TaskList.Task) {
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.taskNameLabel.text = task.title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }
}

protocol TaskCellDelegate: AnyObject {

}
