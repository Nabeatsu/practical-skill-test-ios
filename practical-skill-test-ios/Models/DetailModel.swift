//
//  DetailModel.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/08.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation
import UIKit

class DetailModel: NSObject, TaskManagible {
    var task: TaskList.Task!
    var firebaseDBClient = FirebaseDBClient()
    weak var textViewDelegate: UITextViewDelegate?
}
