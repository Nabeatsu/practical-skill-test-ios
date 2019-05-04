//
//  Date+extension.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/04.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation

extension DateFormatter {
    enum Templete: String {
        case full = "yyyy/MM/dd HH:mm:ss" // 2017/1/1 12:39:22
    }
    /// - Parameter templete: 入出力に使いたいテンプレート
    func set(_ templete: Templete) {
        dateFormat = DateFormatter.dateFormat(fromTemplate: templete.rawValue, options: 0, locale: .current)
    }
    func stringByDefaultLocale(from date: Date) -> String? {
        locale = Locale(identifier: "en_US_POSIX")
        set(.full)
        return string(from: date)
    }

    /// - Parameter string: yyyy/MM//dd HH:mm:ssの形式
    func dateByDefaultLocale(from string: String) -> Date? {
        locale = Locale(identifier: "en_US_POSIX")
        dateFormat = "yyyy.MM.dd HH:mm:ss"
        return date(from: string)
    }
}
