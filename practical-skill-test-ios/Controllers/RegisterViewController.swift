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
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    let authClient = AuthClient()
    var editingField: UITextField?
    @IBAction private func didTapSignUpButton() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let name = nameTextField.text ?? ""
        authClient.signUp(email: email, password: password, name: name)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        authClient.delegate = self
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    

}

extension RegisterViewController: AuthDelegate {}
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        editingField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let editingField = editingField else { return true }
        editingField.resignFirstResponder()
        return true
        
        
    }
}

