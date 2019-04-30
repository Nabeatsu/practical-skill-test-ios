//
//  AuthClient.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/01.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthClient: NSObject {
    
    weak var delegate: AuthDelegate?
    static var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    static var isSignedIn: Bool {
        if let _ = currentUser {
            return true
        } else {
            return false
        }
    }
    
    func showError(_ error: Error?) {
        guard let delegate = delegate, let error = error else { return }
        delegate.handle(error: error)
    }
    
    func signUp(email: String, password: String, name: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let weakSelf = self else { return }
            if let user = result?.user {
                weakSelf.update(displayName: name, of: user)
            }
            weakSelf.showError(error)
        }
    }
    
    private func update(displayName name: String, of user: User) {
        let request = user.createProfileChangeRequest()
        request.displayName = name
        request.commitChanges() { [weak self] error in
            guard let weakSelf = self else { return }
            if error == nil {
                weakSelf.sendEmailVerification(to: user)
            }
            weakSelf.showError(error)
        }
    }
    
    private func sendEmailVerification(to user: User) {
        user.sendEmailVerification() { [weak self] error in
            guard let weakSelf = self, let delegate = weakSelf.delegate else { return }
            if error == nil {
                delegate.signUpCompletion()
            }
            weakSelf.showError(error)
        }
    }
    
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let weakSelf = self, let delegate = weakSelf.delegate else { return }
            if let _ = result?.user {
                delegate.signInCompletion()
            }
            weakSelf.showError(error)
        }
    }
    
    func signOut() {
        guard let delegate = delegate else { return }
        do {
            try Auth.auth().signOut()
        } catch let error {
            delegate.handle(error: error)
            return
        }
        delegate.signOutCompletion()
    }
}
