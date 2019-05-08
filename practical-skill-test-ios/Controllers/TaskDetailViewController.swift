//
//  TaskDetailViewController.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/08.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!

    var task: TaskList.Task? {
        didSet {
            guard let task = task else { return }
            DispatchQueue.main.async {
                self.nameTextView.text = task.title
                self.descriptionTextView.text = task.description
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func tappedCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    deinit {
        #if DEBUG
        print("called deinit: \(self)")
        #endif
    }

}

extension TaskDetailViewController: UITextViewDelegate {

}
