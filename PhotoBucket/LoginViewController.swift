//
//  LoginViewController.swift
//  PhotoBucket
//
//  Created by CSSE Department on 5/16/20.
//  Copyright © 2020 CSSE Department. All rights reserved.
//

import UIKit
import FirebaseAuth
import Rosefire
class LoginViewController:UIViewController{
    
    let listsegueIdentifier = "ShowListSegue"
    let REGISTRY_TOKEN = "2b34437b-cadc-452e-8949-705923c8e904"
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBAction func pressedLoginNewUser(_ sender: Any) {
        let email = UsernameTextField.text!
        let pass = PasswordTextField.text!
        Auth.auth().signIn(withEmail: email, password: pass) { (authResult, error) in
            if let error = error{
                print("Error login user \(error)")
                return
            }
            self.performSegue(withIdentifier: self.listsegueIdentifier, sender: self)
        }
    }
    @IBAction func pressedSignUpUser(_ sender: Any) {
             let email = UsernameTextField.text!
             let pass = PasswordTextField.text!
             
             Auth.auth().createUser(withEmail: email, password: pass) { (authResult, error) in
                 if let error = error{
                     print("Error creating new user \(error)")
                     return
                 }
                 self.performSegue(withIdentifier: self.listsegueIdentifier, sender: self)
             }
    }
    
    @IBAction func pressedRoseFireLogin(_ sender: Any) {
        Rosefire.sharedDelegate().uiDelegate = self
        Rosefire.sharedDelegate().signIn(registryToken: REGISTRY_TOKEN) { (err, result) in
          if let err = err {
            print("Rosefire sign in error! \(err)")
            return
          }
          
          Auth.auth().signIn(withCustomToken: result!.token) { (authResult, error) in
            if let error = error {
              print("Firebase sign in error! \(error)")
              return
            }
            self.performSegue(withIdentifier: self.listsegueIdentifier, sender: self)
          }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        UsernameTextField.placeholder = "Email"
        PasswordTextField.placeholder = "Password"
        //GIDSignIn.sharedInstance()?.presentingViewController = self
        //signInButton.style = .wide
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(Auth.auth().currentUser != nil)
        {
            self.performSegue(withIdentifier: self.listsegueIdentifier, sender: self)
        }
    }
}
