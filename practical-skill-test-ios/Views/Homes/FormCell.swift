//
//  FormCell.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/06.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import UIKit

class FormCell: UITableViewCell, InstantiatableFromNib {
    @IBOutlet weak private var formTextView: UITextView!
    weak var textViewDelegate: UITextViewDelegate? {
        didSet {
            guard let textViewDelegate = textViewDelegate else { return }
            formTextView.delegate = textViewDelegate
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
