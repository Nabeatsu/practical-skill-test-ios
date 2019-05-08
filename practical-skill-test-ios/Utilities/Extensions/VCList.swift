//
//  VCList.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/09.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation
enum VCList: String {
    case home = "Home"
    case detail = "Detail"

    func getStoryBoardName() -> String {
        switch self {
        default:
            return "Main"
        }
    }
}
