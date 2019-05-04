//
//  InstantiatableFromNib.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/05.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation
import UIKit
protocol InstantiatableFromNib {
    static var nibName: String { get }
}

extension InstantiatableFromNib where Self: UIView {
    static var nibName: String { return String(describing: Self.self) }
    func loadNib() {
        let view = Bundle.main.loadNibNamed(Self.nibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.frame
        self.addSubview(view)
    }
}
