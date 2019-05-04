//
//  AuthDelegate.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/01.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

protocol AuthDelegate: AnyObject {
    func handle(error: Error)
    func signUpCompletion()
    func signInCompletion()
    func signOutCompletion()
}

extension AuthDelegate where Self: UIViewController {
    func handle(error: Error) {
        var message = "エラー発生"
        guard let errorCode = AuthErrorCode(rawValue: (error as NSError).code) else { return }
        switch errorCode {
        case .networkError:
            message = "ネットワークへの接続に失敗しました"
        case .userNotFound:
            message = "ユーザーが見つかりません"
        case .invalidEmail:
            message = "メールアドレスが不正です"
        case .emailAlreadyInUse:
            message = "このメールアドレスはすでに使用されています"
        case .userDisabled:
            message = "このアカウントは無効です"
        case .weakPassword:
            message = "脆弱なパスワードが使用されています"
        case .userTokenExpired:
            message = "トークンが期限切れになっています。この端末で再度ログインする必要があります。"
        case .internalError:
            message = "内部エラー: \(error.localizedDescription)"
        case .wrongPassword:
            message = "パスワードが違います"
        default:
            message = "想定されていないエラー: \(error.localizedDescription)"
        }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func signUpCompletion() {
        guard let storyboard = storyboard else { return }
        let nextVC = storyboard.instantiateViewController(withIdentifier: "Home")
        present(nextVC, animated: true, completion: nil)
    }

    func signInCompletion() {
        guard let storyboard = storyboard else { return }
        let nextVC = storyboard.instantiateViewController(withIdentifier: "Home")
        present(nextVC, animated: true, completion: nil)
    }

    func signOutCompletion() {
        guard let storyboard = storyboard else { return }
        let nextVC = storyboard.instantiateViewController(withIdentifier: "まだ決めてない")
        present(nextVC, animated: true, completion: nil)
    }
}
