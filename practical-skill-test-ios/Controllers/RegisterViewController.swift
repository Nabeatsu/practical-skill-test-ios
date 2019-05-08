//
//  ViewController.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/01.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth

class RegisterViewController: UIViewController {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView! {
        didSet {
            indicatorView.hidesWhenStopped = true
            indicatorView.style = .gray
        }
    }
    func randomString(length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }

    let authClient = AuthClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        authClient.delegate = self
        indicatorView.startAnimating()
        let email = "\(randomString(length: 15))@gmail.com"
        let password = "14781478"
        let name = "hoge"
        authClient.signUp(email: email, password: password, name: name)
    }

}

extension RegisterViewController: AuthDelegate {
    func signUpCompletion() {
        indicatorView.stopAnimating()
        guard let storyboard = storyboard else { return }
        let nextVC = storyboard.instantiateViewController(withIdentifier: "Home")
        present(nextVC, animated: true, completion: nil)
    }
}
