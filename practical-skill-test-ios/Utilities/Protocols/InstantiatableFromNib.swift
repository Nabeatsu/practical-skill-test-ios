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
        guard let view = Bundle.main.loadNibNamed(Self.nibName, owner: self, options: nil)?.first as? UIView else {
            fatalError("cannot load Nib. names of xib and .swift files may not match")
        }
        view.frame = self.frame
        self.addSubview(view)
    }
}
